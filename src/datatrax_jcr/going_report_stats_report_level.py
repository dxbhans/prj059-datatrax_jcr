"""Build the reference-style, report-level Going Report status graph."""
from __future__ import annotations

import json
from pathlib import Path
import pandas as pd

from datatrax_jcr.going_report_stats import JCR_COURSES, summarise, write_chart
from datatrax_jcr.report_selection import select_primary_reports

OUT = Path("data/config")
VALUE_PATTERN = r"(?<!\d)\d{1,2}\.\d+(?!\d)"

def build(start_year: int = 2021, end_year: int = 2026) -> tuple[pd.DataFrame, pd.DataFrame, dict]:
    reports = pd.read_parquet(OUT / "jcr_going_reports.parquet").copy()
    reports["created_at"] = pd.to_datetime(reports["created_at"], errors="coerce")
    reports["updated_at"] = pd.to_datetime(reports["updated_at"], errors="coerce")
    reports["race_date"] = pd.to_datetime(reports["race_date"], errors="coerce").dt.date
    reports["created_date"] = reports["created_at"].dt.date
    reports["course_name"] = reports["course_name"].astype(str).str.strip().str.title()
    reports = reports[reports["created_at"].dt.year.between(start_year, end_year)].copy()

    cal = pd.read_parquet(OUT / "jcr_bha_fixture_calendar.parquet").copy()
    cal["race_date"] = pd.to_datetime(cal["meeting_date"], errors="coerce").dt.date
    cal["course_name"] = cal["canonical_name"].astype(str).str.strip().str.title()
    cal = cal.groupby(["course_id", "race_date", "course_name"], as_index=False).agg(
        surface=("bha_surface", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()})))
    )
    cal["declaration_date_2"] = cal["race_date"].map(lambda d: d - pd.Timedelta(days=2))
    cal["declaration_date_3"] = cal["race_date"].map(lambda d: d - pd.Timedelta(days=3))
    reports = reports.merge(cal[["course_id", "race_date", "surface", "declaration_date_2", "declaration_date_3"]], on=["course_id", "race_date"], how="left")
    reports = reports[reports["course_name"].isin(JCR_COURSES)].copy()
    reports = reports[~reports["course_name"].eq("Kempton Park") | ~reports["surface"].str.contains("AWT", na=False)].copy()

    readings = pd.read_parquet(OUT / "jcr_stick_readings.parquet").copy()
    readings["created_date"] = pd.to_datetime(readings["created_at"], errors="coerce").dt.date
    readings["course_name"] = readings["course_name"].astype(str).str.strip().str.title()
    keys = readings[["created_date", "course_name"]].drop_duplicates().assign(readings_uploaded=True)
    reports = reports.merge(keys, on=["created_date", "course_name"], how="left")
    reports["readings_uploaded"] = reports["readings_uploaded"].fillna(False)
    reports["going_value_published"] = reports["stick_comments"].fillna("").astype(str).str.contains(VALUE_PATTERN, regex=True)
    reports["qualifying_day"] = (
        reports["created_date"].eq(reports["race_date"])
        | reports["created_date"].eq(reports["declaration_date_2"])
        | reports["created_date"].eq(reports["declaration_date_3"])
    )

    eligible = reports[reports["qualifying_day"]].copy()
    latest = select_primary_reports(reports, ["course_id", "race_date"])
    meetings = eligible.groupby(["course_id", "course_name", "race_date"], as_index=False).agg(
        report_count=("report_id", "nunique"),
        official_going_present=("official_going", lambda s: s.fillna("").astype(str).str.strip().ne("").any()),
        going_value_published=("going_value_published", "any"),
        readings_uploaded=("readings_uploaded", "any"),
    )
    meetings = meetings.merge(latest[["course_id", "race_date", "abandoned"]], on=["course_id", "race_date"], how="left")
    meetings["abandoned_meeting"] = meetings["abandoned"].fillna(0).astype(bool)
    meetings["status"] = "Blue"
    green = (~meetings.abandoned_meeting & meetings.official_going_present & meetings.going_value_published & meetings.readings_uploaded)
    orange = (~meetings.abandoned_meeting & meetings.official_going_present & meetings.going_value_published & ~meetings.readings_uploaded)
    blue = (~meetings.abandoned_meeting & ~meetings.going_value_published)
    meetings.loc[green, "status"] = "Green"
    meetings.loc[orange, "status"] = "Orange"
    meetings.loc[blue, "status"] = "Blue"
    meetings.loc[meetings.abandoned_meeting, "status"] = "Red"
    summary = summarise(meetings)
    report = {
        "analysis_period": [f"{start_year}-01-01", f"{end_year}-12-31"], "logic": "Reference date matching with meeting-level aggregation",
        "filter": "report created_at year; race-day or two- or three-day declaration-day evidence; readings matched by creation date/course, then any qualifying report counts for the meeting",
        "kempton_awt_excluded": True, "meeting_count": int(len(meetings)),
        "status_counts": {k: int(meetings["status"].eq(k).sum()) for k in ["Green", "Orange", "Blue", "Red"]},
        "outputs": [f"jcr_going_report_stats_meeting_level_{start_year}_{end_year}.parquet", f"jcr_going_report_stats_meeting_level_{start_year}_{end_year}_summary.csv"]
    }
    return meetings, summary, report

def main():
    reports, summary, report = build()
    stem = "jcr_going_report_stats_meeting_level_2021_2026"
    reports.to_parquet(OUT / f"{stem}.parquet", index=False)
    summary.to_parquet(OUT / f"{stem}_summary.parquet", index=False)
    summary.to_csv(OUT / f"{stem}_summary.csv", index=False)
    write_chart(summary, OUT / f"{stem}.svg")
    (OUT / f"{stem}_report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    print(summary.to_string(index=False))

if __name__ == "__main__":
    main()
