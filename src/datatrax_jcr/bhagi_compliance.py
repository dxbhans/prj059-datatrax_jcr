"""Calculate meeting-level BHAGI evidence and Turf-scope outputs."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd

from datatrax_jcr.report_selection import select_primary_reports


OUT = Path("data/config")
RULE_SOURCE = "https://media.britishhorseracing.com/bha/Rules/BHAGI/Section3_The_Racecourse.pdf"
START = pd.Timestamp("2021-01-01")
END = pd.Timestamp("2027-01-01")


def has_text(value: object) -> bool:
    return pd.notna(value) and bool(str(value).strip())


def report_day_fields(reports: pd.DataFrame, role: str) -> pd.DataFrame:
    """Return the selected report for each meeting/timepoint with evidence fields."""
    if reports.empty:
        return pd.DataFrame(columns=["course_id", "race_date"])
    selected = select_primary_reports(reports, ["course_id", "race_date", "day_role"])
    prefix = role + "_"
    selected = selected.rename(columns={
        "report_id": prefix + "report_id",
        "report_state": prefix + "report_state",
        "author_type": prefix + "report_author_type",
        "make_day": prefix + "report_make_date",
        "updated_at": prefix + "report_updated_at",
        "official_going": prefix + "official_going",
        "watering": prefix + "watering",
        "rails": prefix + "rails",
        "stalls": prefix + "stalls",
    })
    selected[prefix + "going_report_present"] = True
    selected[prefix + "official_going_reported"] = selected[prefix + "official_going"].map(has_text)
    for field in ["watering", "rails", "stalls"]:
        selected[prefix + field + "_available"] = selected[prefix + field].map(has_text)
    keep = ["course_id", "race_date"] + [c for c in selected if c.startswith(prefix)]
    return selected[keep]


def main() -> None:
    reconciliation = pd.read_parquet(OUT / "jcr_meeting_status_reconciliation.parquet")
    reconciliation["race_date"] = pd.to_datetime(reconciliation["race_date"], errors="coerce").dt.date
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
    meetings = (reconciliation.merge(courses, on="course_id", how="left")
                .merge(bha, on=["course_id", "race_date"], how="left")
                .merge(tt, on=["course_id", "race_date"], how="left"))
    actual = meetings.loc[meetings["resolved_status"].eq("reported_as_run")].copy()
    actual = actual.loc[pd.to_datetime(actual["race_date"], errors="coerce").between(START, END, inclusive="left")].copy()
    actual["surface"] = actual["bha_surface"].replace("", pd.NA)
    tt_codes = actual["tt_race_type_code"].fillna("").map(lambda v: {part.strip() for part in str(v).split(";")})
    actual.loc[actual["surface"].isna() & tt_codes.map(lambda codes: "2" in codes), "surface"] = "Turf"
    actual.loc[actual["surface"].isna() & tt_codes.map(lambda codes: "4" in codes), "surface"] = "AWT"
    actual["surface_source"] = actual["bha_surface"].map(lambda v: "BHA fixture calendar" if has_text(v) else pd.NA)
    actual.loc[actual["surface_source"].isna() & tt_codes.map(lambda codes: bool(codes & {"2", "4"})), "surface_source"] = "TT Maps race_type_code"
    surface_tokens = actual["surface"].fillna("").map(lambda v: {part.strip() for part in str(v).split(";")})
    has_turf = surface_tokens.map(lambda values: "Turf" in values)
    has_awt = surface_tokens.map(lambda values: "AWT" in values)
    actual["scope_status"] = "unresolved_surface"
    actual.loc[has_awt & ~has_turf, "scope_status"] = "excluded_AWT_only"
    actual.loc[has_turf, "scope_status"] = "scored_Turf"
    scope_cols = ["course_id", "canonical_name", "race_date", "surface", "surface_source", "scope_status", "resolved_status"]
    actual[scope_cols].rename(columns={"canonical_name": "course_name"}).to_parquet(OUT / "jcr_bhagi_scope.parquet", index=False)
    turf = actual.loc[actual["scope_status"].eq("scored_Turf")].copy()

    reports = pd.read_parquet(OUT / "jcr_going_reports.parquet").copy()
    reports["race_date"] = pd.to_datetime(reports["race_date"], errors="coerce").dt.date
    reports["make_day"] = pd.to_datetime(reports["make_date"], errors="coerce").dt.date
    # A report is evidence for its target meeting date and its make-date timepoint.
    reports["day_role"] = "other"
    reports.loc[reports["make_day"].eq(reports["race_date"]), "day_role"] = "race_day"
    dec_dates = reports["race_date"].map(
        lambda d: {d - pd.Timedelta(days=2), d - pd.Timedelta(days=3)} if pd.notna(d) else set()
    )
    reports.loc[[day in dates for day, dates in zip(reports["make_day"], dec_dates)], "day_role"] = "declaration_day"
    reports = reports.loc[reports["race_date"].between(START.date(), (END - pd.Timedelta(days=1)).date())]

    # Report fields come only from the selected last-published report for that
    # meeting/timepoint (or the latest available report if none was published).
    for role in ["declaration_day", "race_day"]:
        turf = turf.merge(report_day_fields(reports.loc[reports["day_role"].eq(role)], role),
                          on=["course_id", "race_date"], how="left")
    turf["declaration_day_proxy_dates"] = turf["race_date"].map(
        lambda d: f"{d - pd.Timedelta(days=3)} or {d - pd.Timedelta(days=2)}" if pd.notna(d) else ""
    )

    # Measurement evidence is independent of selected report contents. Collapse
    # exact repeated report datasets by course, meeting, make-date, map and the
    # complete waypoint/value signature, then count each unique dataset once.
    sticks = pd.read_parquet(OUT / "jcr_stick_readings.parquet")
    sticks["race_date"] = pd.to_datetime(sticks["race_date"], errors="coerce").dt.date
    sticks["measurement_date"] = pd.to_datetime(sticks["source_make_date"], errors="coerce").dt.date
    sticks = sticks.merge(reports[["report_id", "day_role", "race_date", "make_day"]].drop_duplicates("report_id"),
                          left_on="going_report_id", right_on="report_id", how="left", suffixes=("", "_report"))
    sticks["meeting_date"] = sticks["race_date_report"]
    sticks["day_role"] = "other"
    sticks.loc[sticks["measurement_date"].eq(sticks["meeting_date"]), "day_role"] = "race_day"
    sticks.loc[sticks["measurement_date"].isin(sticks["meeting_date"] - pd.Timedelta(days=2)) |
                sticks["measurement_date"].isin(sticks["meeting_date"] - pd.Timedelta(days=3)), "day_role"] = "declaration_day"
    sticks = sticks.loc[sticks["day_role"].isin(["declaration_day", "race_day"])].copy()
    sticks["_value_signature"] = sticks[["way_point", "shear", "penetrate", "index", "going"]].astype("string").fillna("<NA>").agg("|".join, axis=1)
    datasets = (sticks.groupby(["course_id", "meeting_date", "day_role", "measurement_date", "map_id", "going_report_id"], as_index=False)
                .agg(_signature=("_value_signature", lambda s: "||".join(sorted(s))), reading_rows=("reading_id", "nunique")))
    datasets = datasets.drop_duplicates(["course_id", "meeting_date", "day_role", "measurement_date", "map_id", "_signature"])
    ds_summary = datasets.groupby(["course_id", "meeting_date", "day_role"], as_index=False).agg(
        unique_stick_dataset_count=("_signature", "size"), unique_stick_reading_rows=("reading_rows", "sum"),
        stick_measurement_dates=("measurement_date", lambda s: "; ".join(sorted(map(str, set(s))))),
    )
    for role in ["declaration_day", "race_day"]:
        part = ds_summary.loc[ds_summary["day_role"].eq(role)].drop(columns="day_role").rename(columns={
            "meeting_date": "race_date",
            "unique_stick_dataset_count": role + "_unique_stick_dataset_count",
            "unique_stick_reading_rows": role + "_unique_stick_reading_rows",
            "stick_measurement_dates": role + "_stick_measurement_dates",
        })
        turf = turf.merge(part, on=["course_id", "race_date"], how="left")

    bool_columns = [c for c in turf if c.endswith("_going_report_present") or c.endswith("_official_going_reported") or c.endswith("_available")]
    for col in bool_columns:
        turf[col] = turf[col].fillna(False).astype(bool)
    for role in ["declaration_day", "race_day"]:
        count_col = role + "_unique_stick_dataset_count"
        turf[count_col] = turf[count_col].fillna(0).astype(int)
        turf[role + "_goingstick_present"] = turf[count_col].gt(0)
        turf[role + "_goingstick_downloaded"] = turf[role + "_goingstick_present"]
        for col in [role + "_unique_stick_reading_rows"]:
            turf[col] = turf[col].fillna(0).astype(int)

    turf["abandonment_correctly_recorded"] = turf["resolved_status"].eq("reported_as_run") & turf["abandoned_report_count"].fillna(0).eq(0)
    turf["all_requested_information_available"] = turf[["race_day_watering_available", "race_day_rails_available", "race_day_stalls_available"]].all(axis=1)
    turf["compliance_flags"] = ""
    checks = [
        ("declaration-day report missing", ~turf["declaration_day_going_report_present"]),
        ("race-day report missing", ~turf["race_day_going_report_present"]),
        ("declaration-day GoingStick evidence missing", ~turf["declaration_day_goingstick_present"]),
        ("race-day GoingStick evidence missing", ~turf["race_day_goingstick_present"]),
        ("dec official going missing", ~turf["declaration_day_official_going_reported"]),
        ("race meeting official going missing", ~turf["race_day_official_going_reported"]),
        ("watering, rails and stalls information missing", ~turf["all_requested_information_available"]),
    ]
    for label, condition in checks:
        turf.loc[condition, "compliance_flags"] = turf.loc[condition, "compliance_flags"].map(
            lambda current, label=label: "; ".join(filter(None, [current, label])))
    turf["compliance_level"] = turf["compliance_flags"].replace("", "Full")
    turf["overall_compliance_category"] = turf["compliance_level"]

    output = turf.rename(columns={"canonical_name": "course_name"})
    output.to_parquet(OUT / "jcr_bhagi_compliance.parquet", index=False)
    scope_counts = actual["scope_status"].value_counts().to_dict()
    indicator_cols = [c for c in output if c.endswith("_going_report_present") or c.endswith("_goingstick_present") or c.endswith("_official_going_reported") or c.endswith("_available")]
    report = {
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(), "rule_source": RULE_SOURCE,
        "analysis_period": ["2021-01-01", "2026-12-31"],
        "declaration_day_convention": "Proxy: report make_date two or three calendar days before its target race_date; actual declaration-closing dates are not present in the extract.",
        "report_selection_rule": "For each course, target meeting date and timepoint, use the latest report_state=published by updated_at/report_id; if none is published, use the latest available report.",
        "stick_evidence_rule": "GoingStick evidence is evaluated independently from selected report fields using the linked report make_date and unique report datasets; exact repeated datasets are counted once.",
        "population_definition": "Actual meetings resolved_status=reported_as_run in 2021-2026; score Turf, separately report AWT-only and unresolved-surface meetings.",
        "actual_meeting_count_all_surfaces": int(len(actual)), "turf_actual_meeting_count": int(len(output)),
        "scope_status_counts": {str(k): int(v) for k, v in scope_counts.items()},
        "indicator_counts": {c: int(output[c].sum()) for c in indicator_cols},
        "compliance_level_counts": {str(k): int(v) for k, v in output["compliance_level"].value_counts().items()},
        "compliance_flag_counts": {label: int(output["compliance_flags"].str.contains(label, regex=False).sum()) for label, _ in checks},
        "outputs": ["jcr_bhagi_scope.parquet", "jcr_bhagi_compliance.parquet", "jcr_bhagi_compliance_report.json"],
    }
    (OUT / "jcr_bhagi_compliance_report.json").write_text(json.dumps(report, indent=2, default=str) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, default=str))


if __name__ == "__main__":
    main()
