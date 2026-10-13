"""Refresh the JCR Going Report cache from the read-only TT Hub database."""

from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import pymysql
from dotenv import load_dotenv


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "data" / "config"
REPORT_PATH = OUT / "jcr_going_report_import_report.json"
STATUS_PATH = OUT / "jcr_going_report_import_status.parquet"
CACHE_PATH = OUT / "jcr_going_reports.parquet"
SOURCE = "tthub.going_reports joined to tthub.maps and tthub.courses"
START_CREATED_AT = "2021-01-01"
END_CREATED_AT_EXCLUSIVE = "2027-01-01"


def fetch_reports(course_ids: list[int]) -> pd.DataFrame:
    load_dotenv(ROOT / ".env")
    connection = pymysql.connect(
        host=os.environ["TURFTRAX_DB_HOST"],
        port=int(os.getenv("TURFTRAX_DB_PORT", "3306")),
        user=os.environ["TURFTRAX_DB_USER"],
        password=os.environ["TURFTRAX_DB_PASSWORD"],
        database=os.getenv("TURFTRAX_DB_NAME", "tthub"),
        connect_timeout=30,
        read_timeout=300,
        cursorclass=pymysql.cursors.DictCursor,
    )
    placeholders = ", ".join(["%s"] * len(course_ids))
    sql = f"""
        SELECT
            g.id AS report_id,
            c.id AS course_id,
            TRIM(c.name) AS course_name,
            m.id AS map_id,
            m.label AS map_label,
            g.make_date,
            DATE(g.race_date) AS race_date,
            g.official_going,
            g.additional_comments,
            g.weather_comments,
            g.stick_comments,
            g.archived,
            g.status,
            g.type,
            g.complete,
            g.waypoint_map,
            g.zone_map,
            g.uploaded_map,
            g.watering,
            g.rails,
            g.stalls,
            g.version,
            g.default_map,
            g.pdf_path,
            g.meeting_description,
            g.pdf_created,
            g.created_at,
            g.updated_at,
            g.deleted_at,
            g.abandoned,
            g.user_id,
            u.user AS hub_user,
            u.first_name,
            u.last_name,
            role.name AS hub_role,
            u.deleted_at AS user_deleted_at,
            g.clerk_name,
            CASE
                WHEN g.deleted_at IS NOT NULL THEN 'deleted'
                WHEN COALESCE(g.archived, 0) = 1 THEN 'archived'
                WHEN COALESCE(g.status, 0) = 1 THEN 'published'
                ELSE 'unpublished'
            END AS report_state
        FROM going_reports AS g
        JOIN maps AS m ON m.id = g.map_id
        JOIN courses AS c ON c.id = m.course_id
        LEFT JOIN users AS u ON u.id = g.user_id
        LEFT JOIN roles AS role ON role.id = u.role_id
        WHERE c.id IN ({placeholders})
          AND g.created_at >= %s
          AND g.created_at < %s
        ORDER BY c.id, g.race_date, g.make_date, g.id
    """
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                sql,
                [*course_ids, START_CREATED_AT, END_CREATED_AT_EXCLUSIVE],
            )
            return pd.DataFrame(cursor.fetchall())
    finally:
        connection.close()


def enrich_reports(frame: pd.DataFrame, extracted_at: str) -> pd.DataFrame:
    if frame.empty:
        raise RuntimeError("The TT Hub Going Report query returned no rows; existing cache was not changed")

    text_columns = ["waypoint_map", "zone_map", "uploaded_map", "pdf_path", "clerk_name", "hub_user"]
    for column in text_columns:
        frame[column] = frame[column].astype("string")

    def has_value(column: str) -> pd.Series:
        return frame[column].fillna("").str.strip().ne("")

    frame["asset_waypoint_ref"] = has_value("waypoint_map")
    frame["asset_zone_ref"] = has_value("zone_map")
    frame["asset_uploaded_map_ref"] = has_value("uploaded_map")
    frame["asset_pdf_ref"] = has_value("pdf_path")
    frame["author_type"] = "clerk_entry"
    no_clerk = ~has_value("clerk_name")
    auto_clerk = frame["clerk_name"].fillna("").str.strip().str.casefold().eq("tt auto-updater")
    frame.loc[no_clerk, "author_type"] = "no_clerk_name"
    frame.loc[auto_clerk, "author_type"] = "tt_auto_updater"
    frame["user_id_match"] = frame["user_id"].notna() & frame["hub_user"].notna()
    frame["clerk_name_match_status"] = "clerk_name_not_exact_hub_match"
    frame.loc[no_clerk, "clerk_name_match_status"] = "no_clerk_name"
    exact_user_match = (
        has_value("clerk_name")
        & frame["clerk_name"].fillna("").str.strip().str.casefold().eq(
            frame["hub_user"].fillna("").str.strip().str.casefold()
        )
    )
    frame.loc[exact_user_match, "clerk_name_match_status"] = "clerk_name_matches_hub_user"

    group_size = frame.groupby(["map_id", "race_date"], dropna=False)["report_id"].transform("size")
    frame["same_map_date_group_size"] = group_size.astype("int64")
    frame["same_map_date_group"] = group_size.gt(1)
    frame["duplicate_group_count"] = group_size.astype("int64")
    # Repeated reports for a map/date are review groups, not verified duplicates.
    frame["duplicate_candidate"] = False
    frame["source"] = SOURCE
    frame["extracted_at_utc"] = extracted_at

    ordered_columns = [
        "report_id", "course_id", "course_name", "map_id", "map_label", "make_date", "race_date",
        "official_going", "additional_comments", "weather_comments", "stick_comments", "archived", "status",
        "type", "complete", "waypoint_map", "zone_map", "uploaded_map", "watering", "rails", "stalls",
        "version", "default_map", "pdf_path", "meeting_description", "pdf_created", "created_at", "updated_at",
        "deleted_at", "abandoned", "duplicate_group_count", "duplicate_candidate", "asset_waypoint_ref",
        "asset_zone_ref", "asset_uploaded_map_ref", "asset_pdf_ref", "report_state", "source", "extracted_at_utc",
        "same_map_date_group_size", "same_map_date_group", "user_id", "hub_user", "first_name", "last_name",
        "hub_role", "user_deleted_at", "clerk_name", "author_type", "user_id_match", "clerk_name_match_status",
    ]
    return frame[ordered_columns].sort_values(["course_id", "race_date", "report_id"], na_position="last")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    courses_path = OUT / "jcr_courses.parquet"
    if not courses_path.exists():
        raise FileNotFoundError(f"Missing validated JCR course scope: {courses_path}")
    courses = pd.read_parquet(courses_path)
    course_ids = sorted({int(value) for value in courses["course_id"].dropna()})
    if not course_ids:
        raise RuntimeError("No validated JCR course IDs found; existing cache was not changed")

    extracted_at = datetime.now(timezone.utc).isoformat()
    reports = enrich_reports(fetch_reports(course_ids), extracted_at)
    reports["_report_year"] = pd.to_datetime(reports["created_at"], errors="coerce").dt.year
    status = (
        reports.groupby(["course_name", "course_id", "_report_year"], dropna=False)
        .agg(
            reports=("report_id", "nunique"),
            maps=("map_id", "nunique"),
            published=("report_state", lambda s: int((s == "published").sum())),
            archived=("report_state", lambda s: int((s == "archived").sum())),
            deleted=("report_state", lambda s: int((s == "deleted").sum())),
            duplicate_candidates=("duplicate_candidate", "sum"),
            waypoint_map_refs=("asset_waypoint_ref", "sum"),
            zone_map_refs=("asset_zone_ref", "sum"),
            pdf_refs=("asset_pdf_ref", "sum"),
        )
        .reset_index()
        .rename(columns={"_report_year": "year"})
    )

    cache_tmp = CACHE_PATH.with_suffix(".parquet.tmp")
    status_tmp = STATUS_PATH.with_suffix(".parquet.tmp")
    report_tmp = REPORT_PATH.with_suffix(".json.tmp")
    reports.drop(columns="_report_year").to_parquet(cache_tmp, index=False)
    status.to_parquet(status_tmp, index=False)
    report = {
        "analysis_period": [START_CREATED_AT, "2026-12-31"],
        "analysis_period_basis": "going_reports.created_at",
        "extracted_at_utc": extracted_at,
        "course_count": int(reports["course_id"].nunique()),
        "report_count": int(reports["report_id"].nunique()),
        "map_count": int(reports["map_id"].nunique()),
        "created_at_min": str(pd.to_datetime(reports["created_at"], errors="coerce").min()),
        "created_at_max": str(pd.to_datetime(reports["created_at"], errors="coerce").max()),
        "race_date_min": str(pd.to_datetime(reports["race_date"], errors="coerce").min().date()),
        "race_date_max": str(pd.to_datetime(reports["race_date"], errors="coerce").max().date()),
        "reports_missing_race_date": int(reports["race_date"].isna().sum()),
        "published_count": int((reports["report_state"] == "published").sum()),
        "unpublished_count": int((reports["report_state"] == "unpublished").sum()),
        "archived_count": int((reports["report_state"] == "archived").sum()),
        "deleted_count": int((reports["report_state"] == "deleted").sum()),
        "complete_count": int(pd.to_numeric(reports["complete"], errors="coerce").fillna(0).eq(1).sum()),
        "abandoned_count": int(pd.to_numeric(reports["abandoned"], errors="coerce").fillna(0).eq(1).sum()),
        "waypoint_map_reference_count": int(reports["asset_waypoint_ref"].sum()),
        "zone_map_reference_count": int(reports["asset_zone_ref"].sum()),
        "uploaded_map_reference_count": int(reports["asset_uploaded_map_ref"].sum()),
        "pdf_reference_count": int(reports["asset_pdf_ref"].sum()),
        "same_map_date_group_record_count": int(reports["same_map_date_group"].sum()),
        "same_map_date_group_count": int(
            reports.loc[reports["same_map_date_group"]].groupby(["map_id", "race_date"], dropna=False).ngroups
        ),
        "author_type_counts": {str(k): int(v) for k, v in reports["author_type"].value_counts(dropna=False).items()},
        "courses_without_reports": sorted(set(courses["course_id"].astype(int)) - set(reports["course_id"].astype(int))),
        "cache": str(CACHE_PATH.relative_to(ROOT)),
        "status_cache": str(STATUS_PATH.relative_to(ROOT)),
        "interpretation": "Multiple reports for a map/date are retained as revision/history groups. They are not removed or classified as duplicate downloads without dataset-fingerprint evidence.",
    }
    report_tmp.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    cache_tmp.replace(CACHE_PATH)
    status_tmp.replace(STATUS_PATH)
    report_tmp.replace(REPORT_PATH)
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
