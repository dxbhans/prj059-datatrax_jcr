"""Build the course-by-year Going Report table included by Phase 1."""

from __future__ import annotations

from pathlib import Path

import pandas as pd


OUT = Path("data/config")
YEARS = list(range(2021, 2027))


def main() -> None:
    stats_path = OUT / "jcr_going_report_stats_2021_2026.parquet"
    cache_path = OUT / "jcr_going_reports.parquet"
    if stats_path.exists():
        data = pd.read_parquet(stats_path)
        data["report_year"] = pd.to_datetime(data["race_date"], errors="coerce").dt.year
        counts = data.groupby(["course_name", "report_year"], as_index=False)["report_count"].sum()
        counts = counts.rename(columns={"report_count": "reports"})
    elif cache_path.exists():
        data = pd.read_parquet(cache_path)
        data["report_year"] = pd.to_datetime(data["race_date"], errors="coerce").dt.year
        counts = data.groupby(["course_name", "report_year"], as_index=False).size()
        counts = counts.rename(columns={"size": "reports"})
    else:
        raise FileNotFoundError("Neither six-year report statistics nor the Going Report cache exists")

    table = counts.pivot(index="course_name", columns="report_year", values="reports").fillna(0)
    table = table.reindex(columns=YEARS, fill_value=0).sort_index().astype(int)
    table["Total"] = table.sum(axis=1)
    lines = [
        "| Course | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 | Total |",
        "|---|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for course, row in table.iterrows():
        values = [f"{int(row[year]):,}" for year in YEARS] + [f"{int(row['Total']):,}"]
        lines.append(f"| {course} | " + " | ".join(values) + " |")
    totals = table.sum(axis=0)
    values = [f"**{int(totals[year]):,}**" for year in YEARS] + [f"**{int(totals['Total']):,}**"]
    lines.append("| **Total** | " + " | ".join(values) + " |")
    (OUT / "jcr_going_report_course_year_table.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print({"source": str(stats_path if stats_path.exists() else cache_path), "output": "jcr_going_report_course_year_table.md", "rows": len(table)})


if __name__ == "__main__":
    main()
