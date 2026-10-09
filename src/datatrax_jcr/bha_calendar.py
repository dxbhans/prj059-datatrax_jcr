"""Parse ARC BHA fixture workbooks and compare them with TT Maps calendar."""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd


OUT = Path("data/config")
CALENDAR_ROOT = Path("/home/linadmin/Projects/prj057-datatrax_arc/resources/2009 - 2024 BHA  Racing Calendars")
YEARS = range(2021, 2026)
JCR_ALIASES = {
    "aintree": "Aintree", "carlisle": "Carlisle", "cheltenham": "Cheltenham",
    "epsom downs": "Epsom Downs", "exeter": "Exeter", "haydock park": "Haydock Park",
    "huntingdon": "Huntingdon", "kempton park": "Kempton Park", "market rasen": "Market Rasen",
    "newmarket": "Newmarket", "nottingham": "Nottingham", "sandown park": "Sandown Park",
    "warwick": "Warwick", "wincanton": "Wincanton",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> None:
    courses = pd.read_parquet(OUT / "jcr_courses.parquet")
    frames = []
    source_manifest = []
    for year in YEARS:
        path = CALENDAR_ROOT / f"{year} Calendar BHA" / f"BHA MASTER {year}_Fixture_List.xlsx"
        if not path.exists():
            raise FileNotFoundError(path)
        frame = pd.read_excel(path, sheet_name="List", engine="openpyxl")
        frame.columns = frame.columns.str.strip().str.lower()
        frame["source_file"] = path.name
        frame["source_sha256"] = sha256(path)
        frames.append(frame)
        source_manifest.append({"file": str(path), "sha256": sha256(path), "rows": len(frame)})
    bha = pd.concat(frames, ignore_index=True)
    bha["meeting_date"] = pd.to_datetime(bha["date"], errors="coerce").dt.date
    bha["course_source"] = bha["course"].astype("string").str.strip()
    bha["course_key"] = bha["course_source"].str.casefold().str.replace(r"\s+", " ", regex=True)
    bha["canonical_name"] = bha["course_key"].map(JCR_ALIASES)
    bha = bha[bha["canonical_name"].notna() & bha["meeting_date"].notna()].copy()
    course_map = courses.set_index("canonical_name")["course_id"].to_dict()
    bha["course_id"] = bha["canonical_name"].map(course_map)
    bha["bha_surface"] = bha.get("surface", pd.Series(index=bha.index, dtype="string")).astype("string").str.strip()
    bha["bha_race_code"] = bha.get("code", pd.Series(index=bha.index, dtype="string")).astype("string").str.strip()
    bha.to_parquet(OUT / "jcr_bha_fixture_calendar.parquet", index=False)

    bha_summary = bha.groupby(["course_id", "canonical_name", "meeting_date"], dropna=False).agg(
        bha_fixture_row_count=("source_file", "size"),
        bha_surfaces=("bha_surface", lambda s: ";".join(sorted({str(v) for v in s.dropna() if str(v).strip()}))),
        bha_race_codes=("bha_race_code", lambda s: ";".join(sorted({str(v) for v in s.dropna() if str(v).strip()}))),
        bha_source_files=("source_file", lambda s: ";".join(sorted(set(s)))),
    ).reset_index()
    tt = pd.read_parquet(OUT / "jcr_tt_maps_calendar.parquet")
    tt_summary = tt.groupby(["course_id", "race_date"], dropna=False).agg(
        tt_maps_calendar_row_count=("calendar_id", "nunique"),
        tt_maps_status=("calendar_status", lambda s: ";".join(sorted(set(s)))),
        tt_maps_notes=("note", lambda s: "; ".join(sorted({str(v) for v in s.dropna() if str(v).strip()}))),
        tt_maps_race_type_codes=("race_type_code", lambda s: ";".join(sorted({str(v) for v in s.dropna()}))),
    ).reset_index().rename(columns={"race_date": "meeting_date"})
    result = bha_summary.merge(tt_summary, on=["course_id", "meeting_date"], how="outer")
    result["comparison_status"] = "matched"
    result.loc[result["tt_maps_calendar_row_count"].isna(), "comparison_status"] = "bha_only"
    result.loc[result["bha_fixture_row_count"].isna(), "comparison_status"] = "tt_maps_only"
    result.loc[result["bha_fixture_row_count"].gt(1) & result["tt_maps_calendar_row_count"].notna(), "comparison_status"] = "multiple_bha_rows"
    result.loc[result["tt_maps_calendar_row_count"].gt(1) & result["bha_fixture_row_count"].notna(), "comparison_status"] = "multiple_tt_maps_rows"
    result["course_name"] = result["canonical_name"].combine_first(result["course_id"].map(dict(zip(courses.course_id, courses.canonical_name))))
    result.to_parquet(OUT / "jcr_bha_calendar_comparison.parquet", index=False)

    report = {
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_project": "/home/linadmin/Projects/prj057-datatrax_arc",
        "parser_convention": "BHA MASTER {year}_Fixture_List.xlsx, sheet List; Date/Course normalized as ARC loader does",
        "analysis_period": ["2021-01-01", "2025-12-31"],
        "source_manifest": source_manifest,
        "bha_source_rows_all_courses": int(sum(len(frame) for frame in frames)),
        "bha_jcr_fixture_rows": int(len(bha)),
        "bha_jcr_course_date_count": int(len(bha_summary)),
        "tt_maps_course_date_count": int(len(tt_summary)),
        "comparison_course_date_count": int(len(result)),
        "comparison_status_counts": result["comparison_status"].value_counts().to_dict(),
        "bha_only_count": int((result["comparison_status"] == "bha_only").sum()),
        "tt_maps_only_count": int((result["comparison_status"] == "tt_maps_only").sum()),
        "course_id_basis": "JCR canonical course names mapped to existing TT Hub course IDs; TT Maps/TT Hub IDs already matched for all 14 courses.",
        "outputs": ["jcr_bha_fixture_calendar.parquet", "jcr_bha_calendar_comparison.parquet"],
    }
    (OUT / "jcr_bha_calendar_comparison_report.json").write_text(json.dumps(report, indent=2, default=str) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, default=str))


if __name__ == "__main__":
    main()
