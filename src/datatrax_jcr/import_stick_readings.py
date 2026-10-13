"""Import JCR GoingStick readings for the complete Phase 1 analysis period."""

from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import pymysql
from dotenv import load_dotenv


OUT = Path("data/config")
JCR_COURSES = [
    "Aintree", "Carlisle", "Cheltenham", "Exeter", "Epsom Downs",
    "Haydock Park", "Huntingdon", "Kempton Park", "Market Rasen",
    "Newmarket", "Nottingham", "Sandown Park", "Warwick", "Wincanton",
]


def main() -> None:
    load_dotenv(".env")
    conn = pymysql.connect(
        host=os.environ["TURFTRAX_DB_HOST"],
        port=int(os.getenv("TURFTRAX_DB_PORT", "3306")),
        user=os.environ["TURFTRAX_DB_USER"],
        password=os.environ["TURFTRAX_DB_PASSWORD"],
        database=os.getenv("TURFTRAX_DB_NAME", "tthub"),
        connect_timeout=30,
        read_timeout=180,
        cursorclass=pymysql.cursors.DictCursor,
    )
    placeholders = ", ".join(["%s"] * len(JCR_COURSES))
    sql = """
        SELECT
            s.id AS reading_id,
            s.going_report_id,
            s.way_point,
            s.shear,
            s.penetrate,
            s.index,
            s.going,
            s.created_at,
            s.updated_at,
            g.map_id,
            UPPER(TRIM(c.name)) AS course_name,
            m.label AS map_label,
            DATE(g.race_date) AS race_date,
            g.make_date AS source_make_date,
            g.created_at AS source_report_created_at,
            g.updated_at AS source_report_updated_at,
            COALESCE(g.archived, 0) AS archived,
            COALESCE(g.status, 0) AS status,
            g.deleted_at AS report_deleted_at,
            COALESCE(g.abandoned, 0) AS abandoned,
            g.id AS report_id,
            c.id AS course_id,
            CASE
                WHEN g.deleted_at IS NOT NULL THEN 'deleted'
                WHEN COALESCE(g.archived, 0) = 1 THEN 'archived'
                WHEN COALESCE(g.status, 0) = 1 THEN 'published'
                ELSE 'unpublished'
            END AS report_state
        FROM stick_readings AS s
        JOIN going_reports AS g ON g.id = s.going_report_id
        JOIN maps AS m ON m.id = g.map_id
        JOIN courses AS c ON c.id = m.course_id
        WHERE {date_condition}
          AND LOWER(TRIM(c.name)) IN ({placeholders})
        ORDER BY c.name, g.race_date, g.id, s.id
    """
    try:
        with conn.cursor() as cur:
            course_params = [c.lower() for c in JCR_COURSES]
            cur.execute(sql.format(date_condition="g.race_date >= %s AND g.race_date < %s", placeholders=placeholders), ["2021-01-01", "2027-01-01", *course_params])
            rows = cur.fetchall()
            cur.execute(sql.format(date_condition="g.race_date IS NULL AND g.make_date >= %s AND g.make_date < %s", placeholders=placeholders), ["2021-01-01", "2027-01-01", *course_params])
            rows.extend(cur.fetchall())
            frame = pd.DataFrame(rows)
    finally:
        conn.close()
    if frame.empty:
        raise RuntimeError("The six-year JCR stick-reading query returned no rows")
    frame["author_type"] = "unknown"
    extracted = datetime.now(timezone.utc).isoformat()
    frame["extracted_at_utc"] = extracted
    for column in ["shear", "penetrate", "index"]:
        numeric = pd.to_numeric(frame[column], errors="coerce")
        frame[f"{column}_missing_or_non_numeric"] = numeric.isna()
        frame[f"{column}_out_of_range"] = numeric.lt(0) | numeric.gt(15)
        frame[f"{column}_boundary_0_or_15"] = numeric.isin([0, 15])
    frame["unexpected_waypoint"] = False
    frame["duplicate_report_waypoint"] = frame.duplicated(["going_report_id", "way_point"], keep=False)
    columns = [
        "reading_id", "going_report_id", "way_point", "shear", "penetrate", "index", "going",
        "created_at", "updated_at", "map_id", "course_name", "map_label", "race_date", "source_make_date",
        "source_report_created_at", "source_report_updated_at", "archived",
        "status", "report_deleted_at", "abandoned", "report_id", "course_id", "report_state", "author_type",
        "shear_missing_or_non_numeric", "shear_out_of_range", "shear_boundary_0_or_15",
        "penetrate_missing_or_non_numeric", "penetrate_out_of_range", "penetrate_boundary_0_or_15",
        "index_missing_or_non_numeric", "index_out_of_range", "index_boundary_0_or_15",
        "unexpected_waypoint", "duplicate_report_waypoint", "extracted_at_utc",
    ]
    frame[columns].to_parquet(OUT / "jcr_stick_readings.parquet", index=False)
    effective_date = pd.to_datetime(frame["race_date"], errors="coerce").fillna(
        pd.to_datetime(frame["source_make_date"], errors="coerce")
    )
    report = {
        "analysis_period": ["2021-01-01", "2026-12-31"],
        "extracted_at_utc": extracted,
        "reading_rows": int(len(frame)),
        "course_count": int(frame["course_id"].nunique()),
        "race_date_missing_report_count": int(frame.loc[frame["race_date"].isna(), "report_id"].nunique()),
        "rows_included_by_make_date_fallback": int(frame["race_date"].isna().sum()),
        "effective_date_min": str(effective_date.min().date()),
        "effective_date_max": str(effective_date.max().date()),
        "outputs": ["data/config/jcr_stick_readings.parquet"],
    }
    (OUT / "jcr_stick_reading_import_report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
