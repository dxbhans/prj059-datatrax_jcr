"""Extract and classify JCR Going Report meeting statistics."""

from __future__ import annotations

import json
import os
import re
import argparse
from html import escape
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
# The current 2026 extract has no accompanying surface field. These are the
# Kempton Turf/Jump dates in the extract; all other Kempton dates are AWT.
# Keep this explicit until the 2026 TT Maps surface extract is refreshed.
KEMPTON_TURF_DATES = {
    2026: {"2026-01-10", "2026-02-21", "2026-03-14", "2026-03-23", "2026-10-18"},
}


COLOURS = {
    "Green": "#008000",
    "Orange": "#ED7D31",
    "Blue": "#4472C4",
    "Red": "#C00000",
}
VALUE_PATTERN = re.compile(r"(?<!\d)\d{1,2}\.\d+(?!\d)")


def fetch_reports(year: int) -> pd.DataFrame:
    load_dotenv(".env")
    connection = pymysql.connect(
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
    sql = f"""
        SELECT
            c.id AS course_id,
            TRIM(c.name) AS course_name,
            DATE(g.race_date) AS race_date,
            g.id AS report_id,
            g.updated_at,
            g.created_at,
            COALESCE(g.abandoned, 0) AS abandoned,
            g.status,
            g.official_going,
            g.stick_comments,
            COUNT(DISTINCT s.id) AS stick_reading_count
        FROM going_reports AS g
        JOIN maps AS m ON m.id = g.map_id
        JOIN courses AS c ON c.id = m.course_id
        LEFT JOIN stick_readings AS s ON s.going_report_id = g.id
        WHERE YEAR(g.race_date) = %s
          AND LOWER(TRIM(c.name)) IN ({placeholders})
        GROUP BY c.id, c.name, DATE(g.race_date), g.id, g.updated_at,
                 g.created_at, g.abandoned, g.status, g.official_going,
                 g.stick_comments
        ORDER BY c.name, race_date, g.updated_at, g.id
    """
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql, [year, *[course.lower() for course in JCR_COURSES]])
            rows = cursor.fetchall()
    finally:
        connection.close()
    return pd.DataFrame(rows)


def classify(reports: pd.DataFrame, year: int) -> tuple[pd.DataFrame, pd.DataFrame, dict]:
    if reports.empty:
        raise RuntimeError(f"The {year} JCR Going Report query returned no rows")
    reports["course_name"] = reports["course_name"].str.title()
    reports["race_date"] = pd.to_datetime(reports["race_date"]).dt.date
    reports["updated_at"] = pd.to_datetime(reports["updated_at"], errors="coerce")
    reports["report_id"] = reports["report_id"].astype(int)
    reports["official_going_present"] = reports["official_going"].fillna("").astype(str).str.strip().ne("")
    reports["going_value_published"] = reports["stick_comments"].fillna("").astype(str).str.contains(VALUE_PATTERN)
    reports["readings_uploaded"] = reports["stick_reading_count"].fillna(0).gt(0)

    latest = (
        reports.sort_values(["course_id", "race_date", "updated_at", "report_id"])
        .drop_duplicates(["course_id", "race_date"], keep="last")
        [["course_id", "race_date", "abandoned", "report_id"]]
        .rename(columns={"abandoned": "latest_abandoned", "report_id": "latest_report_id"})
    )
    meetings = reports.groupby(["course_id", "course_name", "race_date"], as_index=False).agg(
        report_count=("report_id", "nunique"),
        official_going_present=("official_going_present", "any"),
        going_value_published=("going_value_published", "any"),
        readings_uploaded=("readings_uploaded", "any"),
        stick_reading_count=("stick_reading_count", "sum"),
        abandoned_report_count=("abandoned", "sum"),
    ).merge(latest, on=["course_id", "race_date"], how="left")

    meetings["abandoned_meeting"] = meetings["latest_abandoned"].astype(bool)
    meetings["status"] = "Blue"
    green = (~meetings["abandoned_meeting"] & meetings["official_going_present"] & meetings["going_value_published"] & meetings["readings_uploaded"])
    orange = (~meetings["abandoned_meeting"] & meetings["official_going_present"] & meetings["going_value_published"] & ~meetings["readings_uploaded"])
    blue = (~meetings["abandoned_meeting"] & ~meetings["going_value_published"])
    red = meetings["abandoned_meeting"]
    meetings.loc[green, "status"] = "Green"
    meetings.loc[orange, "status"] = "Orange"
    meetings.loc[blue, "status"] = "Blue"
    meetings.loc[red, "status"] = "Red"
    classified = green | orange | blue | red
    meetings["classification_exception"] = ~classified
    if meetings["classification_exception"].any():
        examples = meetings.loc[meetings["classification_exception"], ["course_name", "race_date", "official_going_present", "going_value_published", "readings_uploaded"]].to_dict("records")
        raise RuntimeError(f"Unclassified meetings require review: {examples[:10]}")

    order = pd.CategoricalDtype(JCR_COURSES, ordered=True)
    meetings["course_name"] = meetings["course_name"].astype(order)
    meetings = meetings.sort_values(["course_name", "race_date"]).reset_index(drop=True)
    summary = meetings.pivot_table(index="course_name", columns="status", values="race_date", aggfunc="count", fill_value=0).reindex(JCR_COURSES, fill_value=0)
    for status in ["Green", "Orange", "Blue", "Red"]:
        if status not in summary:
            summary[status] = 0
    summary = summary[["Green", "Orange", "Blue", "Red"]].reset_index()
    summary["total_meetings"] = summary[["Green", "Orange", "Blue", "Red"]].sum(axis=1)
    report = {
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(),
        "year": year,
        "course_count": len(JCR_COURSES),
        "course_names": JCR_COURSES,
        "meeting_count": int(len(meetings)),
        "report_count": int(reports["report_id"].nunique()),
        "race_date_min": str(meetings["race_date"].min()),
        "race_date_max": str(meetings["race_date"].max()),
        "status_counts": {k: int(v) for k, v in meetings["status"].value_counts().to_dict().items()},
        "definitions": {
            "Green": "Official Going and Going value(s) published in the report and readings uploaded.",
            "Orange": "Official Going and Going Stick value(s) published in the report but no readings uploaded.",
            "Blue": "No Going Stick value(s) published in the report.",
            "Red": "Abandoned meeting.",
        },
        "source": "TT Hub going_reports, stick_readings and courses/maps tables",
        "outputs": [f"jcr_going_report_stats_{year}.parquet", f"jcr_going_report_stats_{year}_summary.parquet", f"jcr_going_report_stats_{year}_report.json"],
    }
    return meetings, summary, report


def write_chart(summary: pd.DataFrame, path: Path) -> None:
    """Write the stacked meeting chart as a self-contained SVG using Python only."""
    width, height = 1400, 720
    left, right, top, bottom = 115, 35, 45, 185
    plot_width, plot_height = width - left - right, height - top - bottom
    y_max = 100
    y_step = 20
    colors = {"Green": "#008000", "Orange": "#ED7D31", "Blue": "#4472C4", "Red": "#C00000"}
    courses = summary["course_name"].tolist()
    bar_width = plot_width / len(courses) * 0.72
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">']
    parts.append('<rect width="100%" height="100%" fill="white"/>')
    parts.append('<style>text{font-family:Arial,sans-serif;fill:#222}.axis{font-size:16px}.label{font-size:14px;font-weight:bold;fill:white}.legend{font-size:16px}</style>')
    for tick in range(0, y_max + 1, y_step):
        y = top + plot_height - (tick / y_max) * plot_height
        parts.append(f'<line x1="{left}" x2="{width-right}" y1="{y:.1f}" y2="{y:.1f}" stroke="#D9E2F3" stroke-width="1"/>')
        parts.append(f'<text class="axis" x="{left-12}" y="{y+5:.1f}" text-anchor="end">{tick}</text>')
    parts.append(f'<line x1="{left}" x2="{left}" y1="{top}" y2="{top+plot_height}" stroke="#444"/>')
    parts.append(f'<line x1="{left}" x2="{width-right}" y1="{top+plot_height}" y2="{top+plot_height}" stroke="#444"/>')
    statuses = ["Green", "Orange", "Blue", "Red"]
    for index, row in summary.iterrows():
        x = left + (index + 0.5) * plot_width / len(courses) - bar_width / 2
        cumulative = 0.0
        total = float(row["total_meetings"])
        for status in statuses:
            value = (float(row[status]) / total * 100) if total else 0.0
            if value == 0:
                continue
            y1 = top + plot_height - ((cumulative + value) / y_max) * plot_height
            h = value / y_max * plot_height
            parts.append(f'<rect x="{x:.1f}" y="{y1:.1f}" width="{bar_width:.1f}" height="{h:.1f}" fill="{colors[status]}"/>')
            if h >= 22:
                parts.append(f'<text class="label" x="{x+bar_width/2:.1f}" y="{y1+h/2+5:.1f}" text-anchor="middle">{value:.0f}%</text>')
            cumulative += value
        label_x = x + bar_width / 2
        label_y = top + plot_height + 25
        parts.append(f'<text class="axis" x="{label_x:.1f}" y="{label_y}" text-anchor="end" transform="rotate(-45 {label_x:.1f} {label_y})">{escape(str(row["course_name"]))}</text>')
    legend_y = height - 48
    legend_x = left
    for status in statuses:
        parts.append(f'<rect x="{legend_x}" y="{legend_y-14}" width="18" height="18" fill="{colors[status]}"/>')
        parts.append(f'<text class="legend" x="{legend_x+26}" y="{legend_y}">{status}</text>')
        legend_x += 145
    parts.append('</svg>')
    path.write_text("\n".join(parts), encoding="utf-8")


def exclude_kempton_awt(meetings: pd.DataFrame, year: int) -> pd.DataFrame:
    """Remove Kempton AWT meetings from a classified meeting extract."""
    turf_dates = KEMPTON_TURF_DATES.get(year)
    if not turf_dates:
        raise RuntimeError(f"No Kempton surface classification is available for {year}")
    dates = pd.to_datetime(meetings["race_date"]).dt.strftime("%Y-%m-%d")
    keep = (meetings["course_name"].astype(str) != "Kempton Park") | dates.isin(turf_dates)
    return meetings.loc[keep].copy()


def summarise(meetings: pd.DataFrame) -> pd.DataFrame:
    summary = meetings.pivot_table(index="course_name", columns="status", values="race_date", aggfunc="count", fill_value=0).reindex(JCR_COURSES, fill_value=0)
    for status in ["Green", "Orange", "Blue", "Red"]:
        if status not in summary:
            summary[status] = 0
    summary = summary[["Green", "Orange", "Blue", "Red"]].reset_index()
    summary["total_meetings"] = summary[["Green", "Orange", "Blue", "Red"]].sum(axis=1)
    return summary


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--year", type=int, default=2026)
    args = parser.parse_args()
    year = args.year
    OUT.mkdir(parents=True, exist_ok=True)
    reports = fetch_reports(year)
    meetings, summary, report = classify(reports, year)
    stem = f"jcr_going_report_stats_{year}"
    meetings.to_parquet(OUT / f"{stem}.parquet", index=False)
    summary.to_parquet(OUT / f"{stem}_summary.parquet", index=False)
    summary.to_csv(OUT / f"{stem}_summary.csv", index=False)
    write_chart(summary, OUT / f"{stem}.svg")
    turf_meetings = exclude_kempton_awt(meetings, year)
    turf_summary = summarise(turf_meetings)
    turf_stem = f"jcr_going_report_stats_{year}_kempton_awt_excluded"
    turf_meetings.to_parquet(OUT / f"{turf_stem}.parquet", index=False)
    turf_summary.to_parquet(OUT / f"{turf_stem}_summary.parquet", index=False)
    turf_summary.to_csv(OUT / f"{turf_stem}_summary.csv", index=False)
    write_chart(turf_summary, OUT / f"{turf_stem}.svg")
    (OUT / f"{stem}_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()
