"""Join Going Report dates and timestamp provenance onto stick readings."""

from __future__ import annotations

import json
from pathlib import Path

import pandas as pd


OUT = Path("data/config")


def main() -> None:
    stick = pd.read_parquet(OUT / "jcr_stick_readings.parquet")
    reports = pd.read_parquet(OUT / "jcr_going_reports.parquet")
    report_columns = reports[
        ["report_id", "make_date", "created_at", "updated_at", "race_date"]
    ].rename(
        columns={
            "created_at": "report_created_at",
            "updated_at": "report_updated_at",
            "race_date": "report_race_date",
            "report_id": "joined_report_id",
        }
    )
    enriched = stick.merge(
        report_columns,
        left_on="going_report_id",
        right_on="joined_report_id",
        how="left",
        validate="many_to_one",
        suffixes=("", "_cache"),
    ).drop(columns=["joined_report_id"])
    for target, source in [
        ("make_date", "source_make_date"),
        ("report_created_at", "source_report_created_at"),
        ("report_updated_at", "source_report_updated_at"),
    ]:
        if source in enriched:
            enriched[target] = enriched[target].combine_first(enriched[source])
    if "report_race_date" in enriched and "race_date" in enriched:
        enriched["report_race_date"] = enriched["report_race_date"].combine_first(enriched["race_date"])
    enriched["make_date"] = pd.to_datetime(enriched["make_date"], errors="coerce").dt.date
    enriched["report_race_date"] = pd.to_datetime(
        enriched["report_race_date"], errors="coerce"
    ).dt.date
    enriched["make_to_stick_created_days"] = (
        pd.to_datetime(enriched["created_at"], errors="coerce").dt.normalize()
        - pd.to_datetime(enriched["make_date"], errors="coerce").dt.normalize()
    ).dt.days.astype("Int64")
    enriched["stick_created_equals_updated"] = enriched["created_at"].eq(enriched["updated_at"])
    enriched["report_created_equals_stick_created"] = enriched["report_created_at"].eq(enriched["created_at"])
    enriched.to_parquet(OUT / "jcr_stick_readings_enriched.parquet", index=False)

    report_level = (
        enriched.sort_values(["going_report_id", "created_at", "reading_id"])
        .drop_duplicates("going_report_id")
    )
    report_level.to_parquet(OUT / "jcr_stick_report_timestamp_qa.parquet", index=False)
    qa = {
        "stick_reading_rows": int(len(enriched)),
        "rows_with_joined_make_date": int(enriched["make_date"].notna().sum()),
        "rows_missing_joined_make_date": int(enriched["make_date"].isna().sum()),
        "stick_created_equals_updated_rows": int(enriched["stick_created_equals_updated"].sum()),
        "report_created_equals_stick_created_rows": int(enriched["report_created_equals_stick_created"].sum()),
        "report_created_differs_from_stick_created_rows": int((~enriched["report_created_equals_stick_created"]).sum()),
        "reports_with_stick_readings": int(enriched["going_report_id"].nunique()),
        "reports_with_matching_first_stick_timestamp": int(report_level["report_created_equals_stick_created"].sum()),
        "reports_with_different_first_stick_timestamp": int((~report_level["report_created_equals_stick_created"]).sum()),
        "make_to_stick_created_day_frequency": {
            str(key): int(value)
            for key, value in enriched["make_to_stick_created_days"].value_counts(dropna=False).sort_index().items()
        },
        "outputs": [
            "jcr_stick_readings_enriched.parquet",
            "jcr_stick_report_timestamp_qa.parquet",
        ],
    }
    (OUT / "jcr_stick_timestamp_qa_report.json").write_text(
        json.dumps(qa, indent=2, default=str) + "\n", encoding="utf-8"
    )
    print(json.dumps(qa, indent=2, default=str))


if __name__ == "__main__":
    main()
