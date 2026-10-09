"""Reconcile TT Maps calendar status with TT Hub Going Reports."""

from __future__ import annotations

import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import pymysql
from dotenv import load_dotenv


OUT = Path("data/config")


def connection(database: str):
    return pymysql.connect(
        host=os.environ["TURFTRAX_DB_HOST"],
        port=int(os.getenv("TURFTRAX_DB_PORT", "3306")),
        user=os.environ["TURFTRAX_DB_USER"],
        password=os.environ["TURFTRAX_DB_PASSWORD"],
        database=database,
        connect_timeout=20,
        read_timeout=90,
        cursorclass=pymysql.cursors.DictCursor,
    )


def calendar_status(note: object) -> str:
    value = "" if pd.isna(note) else str(note).casefold()
    if "cancelled" in value and "abandoned" in value:
        return "cancelled_abandoned"
    if "cancelled" in value:
        return "cancelled"
    if "replaced" in value or "rescheduled" in value:
        return "replaced_or_rescheduled"
    return "scheduled"


def main() -> None:
    load_dotenv(".env")
    courses = pd.read_parquet(OUT / "jcr_courses.parquet")
    reports = pd.read_parquet(OUT / "jcr_going_reports.parquet")
    course_ids = [int(value) for value in courses.course_id]
    placeholders = ",".join(["%s"] * len(course_ids))
    with connection("tthub") as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT id AS hub_course_id, name AS hub_name, country FROM courses WHERE id IN ({placeholders})", course_ids)
            hub = pd.DataFrame(cur.fetchall())
    with connection("ttmaps") as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT id AS tt_maps_course_id, name AS tt_maps_name, altname, country, isallweather FROM course WHERE id IN ({placeholders})", course_ids)
            tt_maps_courses = pd.DataFrame(cur.fetchall())
            cur.execute(f"""
                SELECT calendar_id, MeetingDate AS race_date, CourseId AS tt_maps_course_id,
                       Code AS race_type_code, note, isdeployment, created_at, updated_at
                FROM calendar
                WHERE CourseId IN ({placeholders})
                  AND MeetingDate BETWEEN '2021-01-01' AND '2025-12-31'
                ORDER BY MeetingDate, CourseId, calendar_id
            """, course_ids)
            calendar = pd.DataFrame(cur.fetchall())

    course_match = courses.rename(columns={"course_id": "hub_course_id", "hub_name": "jcr_hub_name"})[["hub_course_id", "canonical_name", "jcr_hub_name"]]
    course_match = course_match.merge(hub, on="hub_course_id", how="left").merge(tt_maps_courses, left_on="hub_course_id", right_on="tt_maps_course_id", how="left")
    course_match["hub_id_match_tt_maps_id"] = course_match["hub_course_id"].eq(course_match["tt_maps_course_id"])
    course_match["name_match"] = course_match.apply(lambda r: str(r["hub_name"]).casefold() == str(r["tt_maps_name"]).casefold(), axis=1)
    course_match["country_match"] = course_match["country_x"].eq(course_match["country_y"])
    course_match.to_parquet(OUT / "jcr_tt_maps_course_match.parquet", index=False)

    calendar["calendar_status"] = calendar["note"].map(calendar_status)
    calendar["course_id"] = calendar["tt_maps_course_id"]
    calendar["course_name"] = calendar["tt_maps_course_id"].map(dict(zip(course_match.hub_course_id, course_match.canonical_name)))
    calendar.to_parquet(OUT / "jcr_tt_maps_calendar.parquet", index=False)

    reports["race_date"] = pd.to_datetime(reports["race_date"]).dt.date
    report_group = reports.groupby(["course_id", "race_date"], dropna=False).agg(
        going_report_count=("report_id", "nunique"),
        non_abandoned_report_count=("abandoned", lambda s: int((s.fillna(0).astype(int) == 0).sum())),
        abandoned_report_count=("abandoned", lambda s: int((s.fillna(0).astype(int) == 1).sum())),
        published_report_count=("report_state", lambda s: int((s == "published").sum())),
    ).reset_index()
    report_group["report_observed_status"] = report_group.apply(
        lambda r: "reported_as_run" if r.non_abandoned_report_count and not r.abandoned_report_count
        else "reported_mixed" if r.non_abandoned_report_count and r.abandoned_report_count
        else "reported_as_abandoned", axis=1
    )
    latest = (
        reports.sort_values(["course_id", "race_date", "updated_at", "report_id"])
        .groupby(["course_id", "race_date"], as_index=False).tail(1)
        [["course_id", "race_date", "report_id", "updated_at", "abandoned", "report_state", "status", "author_type", "hub_user"]]
        .rename(columns={
            "report_id": "latest_report_id", "updated_at": "latest_report_updated_at",
            "abandoned": "latest_report_abandoned", "report_state": "latest_report_state",
            "status": "latest_report_status", "author_type": "latest_report_author_type",
            "hub_user": "latest_report_hub_user",
        })
    )
    planned = calendar.groupby(["course_id", "race_date"], dropna=False).agg(
        calendar_row_count=("calendar_id", "nunique"),
        calendar_status=("calendar_status", lambda s: ";".join(sorted(set(s)))),
        calendar_notes=("note", lambda s: "; ".join(sorted({str(v) for v in s.dropna() if str(v).strip()}))),
        race_type_codes=("race_type_code", lambda s: ";".join(sorted({str(v) for v in s.dropna()}))),
    ).reset_index()
    result = planned.merge(report_group, on=["course_id", "race_date"], how="outer").merge(latest, on=["course_id", "race_date"], how="left")
    result["planned_fixture"] = result["calendar_row_count"].fillna(0).gt(0)
    result["going_report_observed"] = result["going_report_count"].fillna(0).gt(0)
    result["resolved_status"] = result.apply(lambda r:
        "cancelled_or_abandoned" if "cancelled" in str(r.calendar_status) else
        "replaced_or_rescheduled" if "replaced_or_rescheduled" in str(r.calendar_status) else
        "reported_as_run" if r.going_report_observed and r.non_abandoned_report_count > 0 and r.abandoned_report_count == 0 else
        "reported_mixed" if r.going_report_observed and r.non_abandoned_report_count > 0 else
        "reported_as_abandoned" if r.going_report_observed else
        "planned_no_going_report", axis=1)
    result["confidence"] = result.apply(lambda r:
        "high" if r.resolved_status in {"cancelled_or_abandoned", "replaced_or_rescheduled"} else
        "medium" if r.going_report_observed else "low", axis=1)
    result["status_basis"] = result.apply(lambda r:
        "TT Maps calendar note" if r.resolved_status in {"cancelled_or_abandoned", "replaced_or_rescheduled"} else
        "TT Hub Going Report evidence" if r.going_report_observed else
        "TT Maps planned calendar only", axis=1)
    result.to_parquet(OUT / "jcr_meeting_status_reconciliation.parquet", index=False)

    report = {
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(),
        "analysis_period": ["2021-01-01", "2025-12-31"],
        "course_id_match_count": int(course_match["hub_id_match_tt_maps_id"].sum()),
        "course_count": int(len(course_match)),
        "course_name_match_count": int(course_match["name_match"].sum()),
        "calendar_row_count": int(len(calendar)),
        "calendar_course_date_count": int(len(planned)),
        "reconciliation_course_date_count": int(len(result)),
        "calendar_status_counts": calendar["calendar_status"].value_counts().to_dict(),
        "resolved_status_counts": result["resolved_status"].value_counts().to_dict(),
        "planned_without_going_report_count": int((result["resolved_status"] == "planned_no_going_report").sum()),
        "calendar_cancelled_or_replaced_count": int(result["resolved_status"].isin(["cancelled_or_abandoned", "replaced_or_rescheduled"]).sum()),
        "report_only_course_date_count": int(result["calendar_row_count"].isna().sum()),
        "report_only_status_counts": result[result["calendar_row_count"].isna()]["resolved_status"].value_counts().to_dict(),
        "report_only_course_date_count": int(result["calendar_row_count"].isna().sum()),
        "report_only_status_counts": result[result["calendar_row_count"].isna()]["resolved_status"].value_counts().to_dict(),
        "mixed_latest_report_author_type_counts": result[result["resolved_status"] == "reported_mixed"]["latest_report_author_type"].value_counts(dropna=False).to_dict(),
        "mixed_latest_report_status_counts": result[result["resolved_status"] == "reported_mixed"].assign(latest=lambda d: d["latest_report_abandoned"].map({0: "non_abandoned", 1: "abandoned"})).assign(latest_status=lambda d: d["latest"] + ":" + d["latest_report_state"].astype(str))["latest_status"].value_counts().to_dict(),
        "source_limit": "Calendar presence proves planned fixture; explicit cancellation/replacement notes provide status evidence. A planned row without a report remains unresolved rather than being called held.",
        "outputs": ["jcr_tt_maps_course_match.parquet", "jcr_tt_maps_calendar.parquet", "jcr_meeting_status_reconciliation.parquet"],
    }
    (OUT / "jcr_meeting_status_reconciliation_report.json").write_text(json.dumps(report, indent=2, default=str) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, default=str))


if __name__ == "__main__":
    main()
