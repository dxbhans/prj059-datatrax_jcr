"""Build the controlled JCR course-scope configuration from TT Hub."""

from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import pymysql
from dotenv import load_dotenv

JCR_COURSES = [
    "Aintree", "Carlisle", "Cheltenham", "Exeter", "Epsom Downs",
    "Haydock Park", "Huntingdon", "Kempton Park", "Market Rasen",
    "Newmarket", "Nottingham", "Sandown Park", "Warwick", "Wincanton",
]
SCOPE_URL = "https://www.thejockeyclub.co.uk/about-us/our-present/racecourses/"


def fetch_courses() -> pd.DataFrame:
    """Fetch the JCR course register and summary counts from TT Hub."""
    load_dotenv(".env")
    required = ["TURFTRAX_DB_HOST", "TURFTRAX_DB_USER", "TURFTRAX_DB_PASSWORD"]
    missing = [name for name in required if not os.getenv(name)]
    if missing:
        raise RuntimeError(f"Missing database settings: {', '.join(missing)}")

    placeholders = ", ".join(["%s"] * len(JCR_COURSES))
    sql = f"""
        SELECT
            c.id AS course_id,
            TRIM(c.name) AS hub_name,
            NULLIF(TRIM(c.alternative_name), '') AS aliases,
            TRIM(c.country) AS country,
            COALESCE(c.is_all_weather, 0) AS is_all_weather,
            COALESCE(c.no_maps, 0) AS hub_no_maps,
            COALESCE(m.map_count, 0) AS map_count,
            COALESCE(w.waypoint_count, 0) AS waypoint_count
        FROM courses AS c
        LEFT JOIN (
            SELECT course_id, COUNT(*) AS map_count
            FROM maps
            GROUP BY course_id
        ) AS m ON m.course_id = c.id
        LEFT JOIN (
            SELECT m.course_id, COUNT(w.id) AS waypoint_count
            FROM maps AS m
            LEFT JOIN waypoints AS w ON w.map_id = m.id
            GROUP BY m.course_id
        ) AS w ON w.course_id = c.id
        WHERE LOWER(TRIM(c.name)) IN ({placeholders})
        ORDER BY c.name
    """
    connection = pymysql.connect(
        host=os.environ["TURFTRAX_DB_HOST"],
        port=int(os.getenv("TURFTRAX_DB_PORT", "3306")),
        user=os.environ["TURFTRAX_DB_USER"],
        password=os.environ["TURFTRAX_DB_PASSWORD"],
        database=os.getenv("TURFTRAX_DB_NAME", "tthub"),
        connect_timeout=20,
        cursorclass=pymysql.cursors.DictCursor,
        read_timeout=60,
    )
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql, [name.lower() for name in JCR_COURSES])
            rows = cursor.fetchall()
    finally:
        connection.close()

    frame = pd.DataFrame(rows)
    if len(frame) != len(JCR_COURSES):
        found = set(frame["hub_name"].str.casefold()) if not frame.empty else set()
        missing_courses = [name for name in JCR_COURSES if name.casefold() not in found]
        raise RuntimeError(f"JCR scope mismatch; missing Hub courses: {missing_courses}")

    order = {name.casefold(): index for index, name in enumerate(JCR_COURSES, start=1)}
    frame["scope_order"] = frame["hub_name"].str.casefold().map(order)
    frame["canonical_name"] = frame["hub_name"].str.title()
    frame["included"] = True
    frame["scope_match_status"] = "matched_exact_name"
    frame["scope_source"] = SCOPE_URL
    frame["hub_source"] = "tthub.courses, tthub.maps, tthub.waypoints"
    frame["extracted_at_utc"] = datetime.now(timezone.utc).isoformat()
    frame["notes"] = frame["hub_no_maps"].map(
        lambda value: "Hub flags no_maps; map records are retained for review" if value else ""
    )
    return frame.sort_values("scope_order").reset_index(drop=True)


def main() -> None:
    output_dir = Path("data/config")
    output_dir.mkdir(parents=True, exist_ok=True)
    frame = fetch_courses()
    frame.to_parquet(output_dir / "jcr_courses.parquet", index=False)

    provenance = frame[[
        "course_id", "canonical_name", "scope_source", "hub_source",
        "scope_match_status", "extracted_at_utc", "notes",
    ]].copy()
    provenance["source_type"] = "website_scope_plus_tt_hub"
    provenance.to_parquet(output_dir / "jcr_course_provenance.parquet", index=False)

    report = {
        "scope_source": SCOPE_URL,
        "hub_database": os.getenv("TURFTRAX_DB_NAME", "tthub"),
        "extracted_at_utc": frame["extracted_at_utc"].iat[0],
        "course_count": int(len(frame)),
        "all_courses_matched": bool(len(frame) == len(JCR_COURSES)),
        "courses_with_hub_no_maps_flag": int(frame["hub_no_maps"].sum()),
        "total_maps": int(frame["map_count"].sum()),
        "total_waypoints": int(frame["waypoint_count"].sum()),
    }
    (output_dir / "jcr_course_scope_report.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
