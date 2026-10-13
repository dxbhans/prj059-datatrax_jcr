"""Calculate Turf-only BHAGI compliance measures for actual meetings."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd


OUT = Path("data/config")
RULE_SOURCE = "https://media.britishhorseracing.com/bha/Rules/BHAGI/Section3_The_Racecourse.pdf"


def nonblank(series: pd.Series) -> bool:
    return series.fillna("").astype(str).str.strip().ne("").any()


def main() -> None:
    reconciliation = pd.read_parquet(OUT / "jcr_meeting_status_reconciliation.parquet")
    courses = pd.read_parquet(OUT / "jcr_courses.parquet")[["course_id", "canonical_name"]]
    bha = pd.read_parquet(OUT / "jcr_bha_fixture_calendar.parquet")
    bha["race_date"] = pd.to_datetime(bha["meeting_date"], errors="coerce").dt.date
    bha = bha.groupby(["course_id", "race_date"], as_index=False).agg(
        bha_surface=("bha_surface", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
        bha_race_code=("bha_race_code", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
    )
    tt = pd.read_parquet(OUT / "jcr_tt_maps_calendar.parquet")
    tt["race_date"] = pd.to_datetime(tt["race_date"], errors="coerce").dt.date
    tt = tt.groupby(["course_id", "race_date"], as_index=False).agg(
        tt_race_type_code=("race_type_code", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
    )
    meetings = reconciliation.merge(courses, on="course_id", how="left").merge(bha, on=["course_id", "race_date"], how="left").merge(tt, on=["course_id", "race_date"], how="left")
    meetings = meetings[meetings["resolved_status"].eq("reported_as_run")].copy()
    meetings["surface"] = meetings["bha_surface"].replace("", pd.NA)
    meetings.loc[meetings["surface"].isna() & meetings["tt_race_type_code"].eq("2"), "surface"] = "Turf"
    meetings.loc[meetings["surface"].isna() & meetings["tt_race_type_code"].eq("4"), "surface"] = "AWT"
    meetings["surface_source"] = meetings["bha_surface"].map(lambda v: "BHA fixture calendar" if pd.notna(v) and str(v).strip() else pd.NA)
    meetings.loc[meetings["surface_source"].isna() & meetings["tt_race_type_code"].isin(["2", "4"]), "surface_source"] = "TT Maps race_type_code"
    excluded_awt = int(meetings["surface"].eq("AWT").sum())
    excluded_unknown = int(meetings["surface"].isna().sum())
    meetings = meetings[meetings["surface"].eq("Turf")].copy()

    reports = pd.read_parquet(OUT / "jcr_going_reports.parquet").copy()
    reports["race_date"] = pd.to_datetime(reports["race_date"], errors="coerce").dt.date
    reports["make_day"] = pd.to_datetime(reports["make_date"], errors="coerce").dt.date
    # Use the report's race_date as the target meeting date. This matters at
    # festivals, where a report made during one meeting can be the declaration
    # report for the following meeting.
    reports["day_role"] = "other"
    reports.loc[reports["make_day"].eq(reports["race_date"]), "day_role"] = "race_day"
    declaration_offsets = (2, 3)
    declaration_dates = [
        reports["race_date"].map(
            lambda d, offset=offset: d - pd.Timedelta(days=offset) if pd.notna(d) else d
        )
        for offset in declaration_offsets
    ]
    reports.loc[declaration_dates[0].eq(reports["make_day"]) | declaration_dates[1].eq(reports["make_day"]), "day_role"] = "declaration_day"
    stick = pd.read_parquet(OUT / "jcr_stick_readings.parquet").groupby("report_id", as_index=False).agg(stick_reading_count=("reading_id", "size"))
    reports = reports.merge(stick, on="report_id", how="left")
    reports["stick_reading_count"] = reports["stick_reading_count"].fillna(0)
    reports["official_going_present"] = reports["official_going"].fillna("").astype(str).str.strip().ne("")
    for field in ["watering", "rails", "stalls"]:
        reports[field + "_available"] = reports[field].fillna("").astype(str).str.strip().ne("")

    for role in ["declaration_day", "race_day"]:
        subset = reports[reports["day_role"].eq(role)]
        summary = subset.groupby(["course_id", "race_date"], as_index=False).agg(
            **{
                role + "_going_report_present": ("report_id", "size"),
                role + "_goingstick_present": ("stick_reading_count", lambda s: (s > 0).any()),
                role + "_official_going_reported": ("official_going_present", "any"),
                role + "_watering_available": ("watering_available", "any"),
                role + "_rails_available": ("rails_available", "any"),
                role + "_stalls_available": ("stalls_available", "any"),
                role + "_report_count": ("report_id", "size"),
            }
        )
        meetings = meetings.merge(summary, on=["course_id", "race_date"], how="left")

    bool_fields = [c for c in meetings.columns if c.endswith("_present") or c.endswith("_reported") or c.endswith("_available")]
    for field in bool_fields:
        meetings[field] = meetings[field].fillna(False).astype(bool)
    meetings["declaration_day_goingstick_downloaded"] = meetings["declaration_day_goingstick_present"]
    meetings["race_day_goingstick_downloaded"] = meetings["race_day_goingstick_present"]
    meetings["official_going_reported"] = meetings["race_day_official_going_reported"]
    meetings["watering_available"] = meetings["race_day_watering_available"]
    meetings["rails_available"] = meetings["race_day_rails_available"]
    meetings["stalls_available"] = meetings["race_day_stalls_available"]
    meetings["abandonment_correctly_recorded"] = meetings["resolved_status"].eq("reported_as_run") & meetings["abandoned_report_count"].fillna(0).eq(0)
    meetings["bhagi_core_compliant"] = meetings[["declaration_day_going_report_present", "race_day_going_report_present", "declaration_day_goingstick_downloaded", "race_day_goingstick_downloaded", "declaration_day_official_going_reported", "race_day_official_going_reported", "abandonment_correctly_recorded"]].all(axis=1)
    meetings["all_requested_information_available"] = meetings[["watering_available", "rails_available", "stalls_available"]].all(axis=1)
    meetings["compliance_flags"] = ""
    flag_rules = [
        ("no readings downloaded", ~meetings[["declaration_day_goingstick_present", "race_day_goingstick_present"]].all(axis=1)),
        ("dec official going missing", ~meetings["declaration_day_official_going_reported"]),
        ("race meeting official going missing", ~meetings["race_day_official_going_reported"]),
        ("watering, rails and stalls information missing", ~meetings["all_requested_information_available"]),
    ]
    for label, condition in flag_rules:
        meetings.loc[condition, "compliance_flags"] = meetings.loc[condition, "compliance_flags"].map(
            lambda current, label=label: "; ".join(filter(None, [current, label]))
        )
    meetings["compliance_level"] = "Full"
    meetings.loc[~meetings[["declaration_day_goingstick_present", "race_day_goingstick_present"]].all(axis=1), "compliance_level"] = "no readings downloaded"
    meetings.loc[meetings["compliance_level"].eq("Full") & ~meetings["declaration_day_official_going_reported"], "compliance_level"] = "dec official going missing"
    meetings.loc[meetings["compliance_level"].eq("Full") & ~meetings["race_day_official_going_reported"], "compliance_level"] = "race meeting official going missing"
    meetings.loc[meetings["compliance_level"].eq("Full") & ~meetings["all_requested_information_available"], "compliance_level"] = "watering, rails and stalls information missing"
    meetings["overall_compliance_category"] = meetings["compliance_level"]

    columns = ["course_id", "canonical_name", "race_date", "surface", "surface_source", "resolved_status", "going_report_count", "abandoned_report_count", "declaration_day_going_report_present", "race_day_going_report_present", "declaration_day_goingstick_present", "race_day_goingstick_present", "declaration_day_goingstick_downloaded", "race_day_goingstick_downloaded", "declaration_day_official_going_reported", "race_day_official_going_reported", "official_going_reported", "abandonment_correctly_recorded", "watering_available", "rails_available", "stalls_available", "compliance_level", "compliance_flags", "overall_compliance_category", "declaration_day_report_count", "race_day_report_count"]
    output = meetings[columns].rename(columns={"canonical_name": "course_name"})
    output.to_parquet(OUT / "jcr_bhagi_compliance.parquet", index=False)
    report = {
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(),
        "rule_source": RULE_SOURCE,
        "rule_reference": "BHAGI 3.2 paragraphs 21-24: official going, GoingStick before declarations and on race day, Going App records and update times.",
        "declaration_day_convention": "The extract has no declaration-closing date; declaration evidence is accepted when make_date is two or three calendar days before the report race_date. The report race_date remains the target meeting date, including festival sequences.",
        "population_definition": "Actual meetings are resolved_status=reported_as_run; AWT meetings are excluded and only Turf meetings are scored.",
        "actual_meeting_count_all_surfaces": int(len(reconciliation[reconciliation["resolved_status"].eq("reported_as_run")])),
        "turf_actual_meeting_count": int(len(output)),
        "excluded_awt_actual_meetings": excluded_awt,
        "excluded_unknown_surface_actual_meetings": excluded_unknown,
        "indicator_counts": {c: int(output[c].sum()) for c in columns if c.endswith("_present") or c.endswith("_reported") or c.endswith("_available") or c.endswith("_downloaded") or c == "abandonment_correctly_recorded"},
        "compliance_level_counts": output["compliance_level"].value_counts().to_dict(),
        "compliance_flag_counts": {label: int(output["compliance_flags"].str.contains(label, regex=False).sum()) for label, _ in flag_rules},
        "outputs": ["jcr_bhagi_compliance.parquet", "jcr_bhagi_compliance_report.json"],
    }
    (OUT / "jcr_bhagi_compliance_report.json").write_text(json.dumps(report, indent=2, default=str) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, default=str))


if __name__ == "__main__":
    main()
