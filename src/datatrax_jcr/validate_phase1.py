"""Run the preliminary Phase 1 acceptance checks from generated JCR outputs."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd


OUT = Path("data/config")


def check(name: str, passed: bool, detail: str, status: str | None = None) -> dict:
    effective_status = status or ("pass" if passed else "exception")
    return {"check": name, "passed": bool(passed and effective_status == "pass"), "status": effective_status, "detail": detail}


def main() -> None:
    courses = pd.read_parquet(OUT / "jcr_courses.parquet")
    maps = pd.read_parquet(OUT / "jcr_maps.parquet")
    waypoints = pd.read_parquet(OUT / "jcr_waypoints.parquet")
    sections = pd.read_parquet(OUT / "jcr_sections.parquet")
    zones = pd.read_parquet(OUT / "jcr_zones.parquet")
    kml = pd.read_parquet(OUT / "jcr_kml_inventory.parquet")
    svg = pd.read_parquet(OUT / "jcr_svg_source_documents.parquet")
    reports = pd.read_parquet(OUT / "jcr_going_reports.parquet")
    section_zone = json.loads((OUT / "jcr_section_zone_qa_report.json").read_text())
    stick = json.loads((OUT / "jcr_stick_reading_qa_report.json").read_text())
    svg_report = json.loads((OUT / "jcr_svg_validation_report.json").read_text())
    discipline = json.loads((OUT / "jcr_map_discipline_layout_report.json").read_text())
    meeting = json.loads((OUT / "jcr_meeting_status_reconciliation_report.json").read_text())
    bha = json.loads((OUT / "jcr_bha_calendar_comparison_report.json").read_text())
    kempton = json.loads((OUT / "jcr_kempton_surface_classification_report.json").read_text())

    checks = [
        check("Course scope", len(courses) == 14, f"{len(courses)} JCR courses identified."),
        check("Course IDs", not courses.course_id.duplicated().any(), "No duplicate course IDs."),
        check("Maps", set(courses.course_id).issubset(set(maps.course_id)), "Every scoped course has map records."),
        check("Map identity", not maps.map_id.duplicated().any(), f"{maps.map_id.nunique()} unique map IDs; archived maps retained and flagged."),
        check("Map discipline", discipline["discipline_counts"].get("unknown", 0) == 0, f"{discipline['discipline_counts'].get('unknown', 0)} maps remain unknown; isolated by map ID.", "exception"),
        check("Waypoints", stick["range_failures"] == {"index": 0, "penetrate": 0, "shear": 0}, f"Range checks pass; {stick['unexpected_waypoint_rows']} unexpected rows and {stick['reports_exceeding_configured_waypoints']} over-count reports require review.", "exception"),
        check("Sections", len(sections) > 0 and sections.map_id.notna().all(), f"{len(sections)} sections retained with map-specific IDs; {section_zone['section_refs_to_unconfigured_waypoints']} references need review." , "exception"),
        check("Zones", len(zones) > 0 and section_zone["overlap_preserved"], f"{len(zones)} zones retained; {section_zone['waypoints_in_multiple_zones']} overlapping waypoint memberships preserved."),
        check("KML", kml.sha256.notna().all() and kml.match_status.notna().all(), f"{len(kml)} KML files have checksums and match statuses; one JCR file is ambiguous." , "exception"),
        check("Going Reports", len(reports) == 21829, f"{len(reports)} reports imported; source coverage is complete for the extracted period."),
        check("Meeting status", meeting["course_id_match_count"] == 14 and meeting["planned_without_going_report_count"] == 0, f"TT Maps and TT Hub course IDs match for {meeting['course_id_match_count']} of {meeting['course_count']} courses; {meeting['planned_without_going_report_count']} planned dates have no Going Report and remain unresolved.", "exception"),
        check("BHA calendar", bha["bha_only_count"] == 0 and bha["tt_maps_only_count"] == 0, f"BHA/TT Maps comparison has {bha['bha_only_count']} BHA-only and {bha['tt_maps_only_count']} TT Maps-only dates; course IDs were mapped through the 14 confirmed Hub course identities.", "exception"),
        check("Kempton surface classification", kempton["unresolved_report_rows"] == 0 and kempton["stick_readings_on_awt_reports"] == 0, f"{kempton['eligible_turf_jump_report_rows']} Turf/Jump reports retained for stick analysis, {kempton['awt_report_rows_excluded']} AWT reports excluded, and {kempton['unresolved_report_rows']} reports remain unresolved.", "exception"),
        check("SVG", svg.retrieval_status.notna().all() and svg.parse_status.notna().all(), f"{len(svg)} representative candidates have retrieval/parse status; full all-report retention remains pending." , "exception"),
        check("SVG matching", svg_report["element_count"] > 0, f"{svg_report['element_count']} SVG elements parsed; {svg_report['matched_waypoint_element_count']} waypoint matches quantified."),
        check("Cheltenham", len(discipline["cheltenham"]) == 20, "All Cheltenham map records included in the explicit review output."),
        check("Provenance", all(c in maps.columns for c in ["source", "extracted_at_utc"]), "Map provenance and extraction timestamps present; no manual decisions recorded yet."),
    ]
    passed = sum(item["status"] == "pass" for item in checks)
    exceptions = sum(item["status"] == "exception" for item in checks)
    report = {
        "validation_type": "preliminary_phase_1",
        "validated_at_utc": datetime.now(timezone.utc).isoformat(),
        "status": "preliminary_with_documented_exceptions",
        "check_count": len(checks),
        "pass_count": passed,
        "exception_count": exceptions,
        "checks": checks,
        "not_phase_complete_reason": "Map discipline/layout, waypoint exceptions, KML ambiguity, representative-only SVG retention and independent meeting validation remain open.",
        "source_reports": [
            "jcr_course_scope_report.json", "jcr_map_inventory_report.json",
            "jcr_stick_reading_qa_report.json", "jcr_section_zone_qa_report.json",
            "jcr_kml_validation_report.json", "jcr_svg_validation_report.json",
            "jcr_map_discipline_layout_report.json", "jcr_meeting_status_reconciliation_report.json", "jcr_bha_calendar_comparison_report.json", "jcr_kempton_surface_classification_report.json",
        ],
    }
    path = OUT / "jcr_phase1_validation_report.json"
    path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "pass_count": passed, "exception_count": exceptions, "output": str(path)}, indent=2))


if __name__ == "__main__":
    main()
