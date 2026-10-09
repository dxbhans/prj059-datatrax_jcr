"""Build the versioned JCR Phase 1 configuration package."""

from __future__ import annotations

import hashlib
import json
import shutil
import zipfile
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import yaml


ROOT = Path("data/config")
PACKAGE = ROOT / "jcr_configuration_package"
VERSION = "phase-1-2026-10-09"

REQUIRED = [
    "jcr_courses.parquet", "jcr_maps.parquet", "jcr_waypoints.parquet",
    "jcr_sections.parquet", "jcr_zones.parquet", "jcr_waypoint_sections.parquet",
    "jcr_waypoint_zones.parquet", "jcr_kml_inventory.parquet", "jcr_kml_waypoints.parquet",
    "jcr_svg_source_documents.parquet", "jcr_svg_documents.parquet", "jcr_svg_elements.parquet",
    "jcr_map_discipline_layout.parquet", "jcr_section_zone_map_qa.parquet",
    "jcr_waypoint_compliance.parquet", "jcr_waypoint_map_qa.parquet",
    "jcr_stick_readings.parquet", "jcr_actual_meetings_preliminary.parquet",
    "jcr_going_reports.parquet", "jcr_going_report_authorship.parquet",
    "jcr_map_review.xlsx", "jcr_map_review_import_report.json",
    "jcr_map_discipline_layout_report.json", "jcr_phase1_validation_report.json",
    "jcr_tt_maps_course_match.parquet", "jcr_tt_maps_calendar.parquet",
    "jcr_meeting_status_reconciliation.parquet", "jcr_meeting_status_reconciliation_report.json",
    "jcr_meeting_date_review.xlsx", "jcr_meeting_date_review_report.json",
    "jcr_bha_fixture_calendar.parquet", "jcr_bha_calendar_comparison.parquet",
    "jcr_bha_calendar_comparison_report.json",
    "jcr_kempton_surface_classification.parquet", "jcr_kempton_surface_classification_report.json",
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> None:
    PACKAGE.mkdir(parents=True, exist_ok=True)
    for old in PACKAGE.iterdir():
        if old.is_file():
            old.unlink()
        elif old.is_dir():
            shutil.rmtree(old)

    missing = [name for name in REQUIRED if not (ROOT / name).exists()]
    if missing:
        raise RuntimeError(f"Missing required package inputs: {missing}")
    for name in REQUIRED:
        shutil.copy2(ROOT / name, PACKAGE / name)

    courses = pd.read_parquet(ROOT / "jcr_courses.parquet")
    maps = pd.read_parquet(ROOT / "jcr_maps.parquet")
    aliases = {
        "version": VERSION,
        "courses": [
            {"course_id": int(row.course_id), "canonical_name": row.canonical_name,
             "hub_name": row.hub_name, "aliases": [row.hub_name]}
            for row in courses.itertuples()
        ],
        "maps": [],
    }
    for row in maps.itertuples():
        values = [str(row.map_label).strip()]
        if pd.notna(row.track_names) and str(row.track_names).strip() not in values:
            values.append(str(row.track_names).strip())
        aliases["maps"].append({
            "map_id": int(row.map_id), "course_id": int(row.course_id),
            "canonical_label": str(row.map_label), "aliases": values,
            "confidence": "hub_metadata", "manual_decision": False,
        })
    (PACKAGE / "jcr_map_aliases.yml").write_text(yaml.safe_dump(aliases, sort_keys=False), encoding="utf-8")

    unresolved = json.loads((ROOT / "jcr_map_discipline_layout_report.json").read_text())
    metadata = {
        "configuration_version": VERSION,
        "created_at_utc": datetime.now(timezone.utc).isoformat(),
        "scope": "14 JCR courses; TT Hub configuration plus supplied KML and representative Going Report SVG assets",
        "package_members": REQUIRED + ["jcr_map_aliases.yml", "jcr_config_metadata.yml"],
        "source_files": {name: {"sha256": sha256(ROOT / name), "bytes": (ROOT / name).stat().st_size} for name in REQUIRED},
        "manual_decisions": [],
        "unresolved_issues": [
            "6 maps retain unknown discipline because they were not reviewed in the workbook.",
            "Cheltenham detailed layout review remains open; the general workbook assignment is applied.",
            "SVG retention is representative: one report per map/date; full all-report backfill remains pending.",
            "56 planned calendar course/date rows have no Going Report and remain unresolved; no race results were used.",
            "Kempton surface classification excludes 555 AWT reports from Going Stick analysis; 8 reports on four dates remain unresolved.",
        ],
        "reviewer": None,
        "review_date": None,
        "map_resolution_summary": unresolved,
        "svg_storage": "SVG local files remain under data/config/svg and are referenced by the SVG Parquet tables; they are not duplicated in this ZIP.",
    }
    (PACKAGE / "jcr_config_metadata.yml").write_text(yaml.safe_dump(metadata, sort_keys=False), encoding="utf-8")
    members = sorted(path.name for path in PACKAGE.iterdir() if path.is_file())
    manifest = {"version": VERSION, "created_at_utc": datetime.now(timezone.utc).isoformat(),
                "files": {name: {"sha256": sha256(PACKAGE / name), "bytes": (PACKAGE / name).stat().st_size} for name in members}}
    (PACKAGE / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    archive = ROOT / f"jcr_configuration_package_{VERSION}.zip"
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as target:
        for path in sorted(PACKAGE.iterdir()):
            if path.is_file():
                target.write(path, arcname=f"{PACKAGE.name}/{path.name}")
    print(json.dumps({"package": str(PACKAGE), "archive": str(archive), "member_count": len(members) + 1,
                      "archive_bytes": archive.stat().st_size, "version": VERSION}, indent=2))


if __name__ == "__main__":
    main()
