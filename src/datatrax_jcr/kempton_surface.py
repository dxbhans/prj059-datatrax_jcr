"""Classify Kempton Going Reports as Turf/Jump or AWT/Flat."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd


OUT = Path("data/config")
KEMPTON_COURSE_ID = 28
TT_CODE_CLASS = {"2": ("Turf", "Jump"), "4": ("AWT", "Flat")}


def main() -> None:
    reports = pd.read_parquet(OUT / "jcr_going_reports.parquet")
    reports = reports[reports["course_id"].eq(KEMPTON_COURSE_ID)].copy()
    reports["meeting_date"] = pd.to_datetime(reports["race_date"], errors="coerce").dt.date

    bha = pd.read_parquet(OUT / "jcr_bha_fixture_calendar.parquet")
    bha = bha[bha["course_id"].eq(KEMPTON_COURSE_ID)].copy()
    bha["meeting_date"] = pd.to_datetime(bha["meeting_date"], errors="coerce").dt.date
    bha_summary = bha.groupby("meeting_date", as_index=False).agg(
        bha_surfaces=("bha_surface", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
        bha_race_codes=("bha_race_code", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
    )

    tt = pd.read_parquet(OUT / "jcr_tt_maps_calendar.parquet")
    tt = tt[tt["course_id"].eq(KEMPTON_COURSE_ID)].copy()
    tt["meeting_date"] = pd.to_datetime(tt["race_date"], errors="coerce").dt.date
    tt_summary = tt.groupby("meeting_date", as_index=False).agg(
        tt_maps_race_type_codes=("race_type_code", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
        tt_maps_calendar_rows=("calendar_id", "nunique"),
    )

    result = reports.merge(bha_summary, on="meeting_date", how="left").merge(tt_summary, on="meeting_date", how="left")
    result["surface_classification"] = pd.NA
    result["discipline"] = pd.NA
    result["classification_source"] = pd.NA
    result["classification_status"] = "unresolved"

    bha_surface = result["bha_surfaces"].fillna("")
    result.loc[bha_surface.eq("AWT"), ["surface_classification", "discipline", "classification_source", "classification_status"]] = ["AWT", "Flat", "BHA fixture calendar", "classified"]
    result.loc[bha_surface.eq("Turf"), ["surface_classification", "discipline", "classification_source", "classification_status"]] = ["Turf", "Jump", "BHA fixture calendar", "classified"]

    fallback = result["classification_status"].eq("unresolved")
    for code, (surface, discipline) in TT_CODE_CLASS.items():
        mask = fallback & result["tt_maps_race_type_codes"].fillna("").eq(code)
        result.loc[mask, ["surface_classification", "discipline", "classification_source", "classification_status"]] = [surface, discipline, "TT Maps race_type_code", "classified_fallback"]

    stick = pd.read_parquet(OUT / "jcr_stick_readings.parquet")
    stick = stick[stick["course_id"].eq(KEMPTON_COURSE_ID)]
    stick_summary = stick.groupby("report_id", as_index=False).agg(stick_reading_count=("reading_id", "size"))
    result = result.merge(stick_summary, on="report_id", how="left")
    result["stick_reading_count"] = result["stick_reading_count"].fillna(0).astype(int)
    result["stick_analysis_eligible"] = result["surface_classification"].eq("Turf") & result["discipline"].eq("Jump")
    result["stick_exclusion_reason"] = result["surface_classification"].map({"AWT": "AWT tracks are not tested with the Going Stick", "Turf": pd.NA}).fillna("Surface not confirmed by BHA or TT Maps")
    result.to_parquet(OUT / "jcr_kempton_surface_classification.parquet", index=False)

    classified = result[result["classification_status"].isin(["classified", "classified_fallback"])]
    report = {
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(),
        "course_id": KEMPTON_COURSE_ID,
        "course_name": "Kempton Park",
        "classification_priority": ["BHA fixture calendar", "TT Maps race_type_code", "unresolved operational review"],
        "report_rows": int(len(result)),
        "report_dates": int(result["meeting_date"].nunique()),
        "classification_status_counts": result["classification_status"].value_counts().to_dict(),
        "surface_counts": {("unresolved" if pd.isna(k) else str(k)): int(v) for k, v in result["surface_classification"].value_counts(dropna=False).items()},
        "eligible_turf_jump_report_rows": int(result["stick_analysis_eligible"].sum()),
        "awt_report_rows_excluded": int(result["surface_classification"].eq("AWT").sum()),
        "unresolved_report_rows": int(result["classification_status"].eq("unresolved").sum()),
        "unresolved_dates": sorted(str(v) for v in result.loc[result["classification_status"].eq("unresolved"), "meeting_date"].dropna().unique()),
        "kempton_stick_readings": int(len(stick)),
        "stick_reports": int(stick["report_id"].nunique()),
        "stick_dates": int(stick["race_date"].nunique()),
        "stick_readings_on_awt_reports": int(result.loc[result["surface_classification"].eq("AWT"), "stick_reading_count"].sum()),
        "outputs": ["jcr_kempton_surface_classification.parquet", "jcr_kempton_surface_classification_report.json"],
    }
    (OUT / "jcr_kempton_surface_classification_report.json").write_text(json.dumps(report, indent=2, default=str) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, default=str))


if __name__ == "__main__":
    main()
