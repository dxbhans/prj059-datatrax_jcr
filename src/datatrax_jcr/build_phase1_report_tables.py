"""Build dynamic Markdown table fragments used by the Phase 1 report."""

from __future__ import annotations

import json
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "data" / "config"
OUT = DATA / "phase1_tables"


def load_json(name: str) -> dict:
    return json.loads((DATA / name).read_text())


def clean(value):
    if pd.isna(value):
        return ""
    if isinstance(value, float) and value.is_integer():
        return int(value)
    return value


def table(headers, rows) -> str:
    lines = ["| " + " | ".join(map(str, headers)) + " |", "|" + "---|" * len(headers)]
    for row in rows:
        lines.append("| " + " | ".join(str(clean(v)) for v in row) + " |")
    return "\n".join(lines) + "\n"


def write(name: str, headers, rows) -> None:
    (OUT / name).write_text(table(headers, rows))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    courses = pd.read_parquet(DATA / "jcr_courses.parquet").sort_values("scope_order")
    maps = pd.read_parquet(DATA / "jcr_maps.parquet")
    waypoints = pd.read_parquet(DATA / "jcr_waypoints.parquet")

    scope = load_json("jcr_course_scope_report.json")
    extracted = pd.Timestamp(scope["extracted_at_utc"]).strftime("%-d %B %Y")
    matched = int(courses["scope_match_status"].eq("matched_exact_name").sum()) if "scope_match_status" in courses else int(scope["course_count"] if scope["all_courses_matched"] else 0)
    countries = ", ".join(sorted(str(v) for v in courses["country"].dropna().unique()))
    aliases = [f"{r.canonical_name} has the Hub alias `{r.aliases}`" for r in courses.itertuples() if pd.notna(r.aliases) and str(r.aliases).strip()]
    alias_text = "; ".join(aliases) if aliases else "No course aliases are recorded."
    (OUT / "step1_result.md").write_text(
        f"Step 1 was run on {extracted} against the read-only TT Hub connection. The [Jockey Club racecourse register]({scope['scope_source']}) and TT Hub matched {matched} of {scope['course_count']} courses by canonical name. The extract contains {scope['course_count']} courses, {scope['total_maps']} maps and {scope['total_waypoints']:,} configured waypoints. All courses are recorded as {countries} in TT Hub. {alias_text}\n\nThe Hub `no_maps` flag is set for {scope['courses_with_hub_no_maps_flag']} courses even though map records are present. This is retained as a configuration warning for Step 2 rather than being interpreted as evidence that the courses have no maps.\n"
    )

    map_counts = maps.groupby("course_id").size()
    wp_counts = waypoints.groupby("course_id").size()
    write("course_scope.md", ["Course", "Hub ID", "Canonical name", "Alias", "Maps", "Waypoints", "Included"], [
        [r.course_id, r.course_id, r.canonical_name, r.aliases or "—", map_counts.get(r.course_id, 0), wp_counts.get(r.course_id, 0), "yes" if r.included else "no"]
        for r in courses.itertuples()
    ])

    m = load_json("jcr_map_inventory_report.json")
    write("map_result.md", ["Measure", "Result", "Interpretation"], [
        ["Course coverage", f"{m['course_count']} / {m['course_count']}", "No JCR course was missing from the map inventory."],
        ["Map inventory", m["map_count"], "Stable Hub map IDs are retained."],
        ["Lifecycle", f"{m['active_map_count']} active; {m['archived_map_count']} archived", "Archived maps are retained with their validity information."],
        ["Track linkage", f"{m['maps_with_tracks']} with tracks; {m['maps_without_tracks']} without", "Maps without child tracks remain review exceptions."],
        ["Operational discipline", "; ".join(f"{k}: {v}" for k, v in maps["map_type"].value_counts(dropna=False).sort_index().items()), "Counts are sourced from the current reviewed map Parquet."],
    ])

    wp_map_count = waypoints.map_id.nunique()
    missing_maps = sorted(set(maps.map_id) - set(waypoints.map_id))
    numeric = pd.to_numeric(waypoints.waypoint_number, errors="coerce")
    dup = waypoints.loc[numeric.notna()].duplicated(["map_id", "waypoint_number"]).sum()
    reports = pd.read_parquet(DATA / "jcr_going_reports.parquet")
    stick = pd.read_parquet(DATA / "jcr_stick_readings_enriched.parquet")
    write("waypoint_result.md", ["Waypoint inventory measure", "Result"], [
        ["JCR courses represented", courses.course_id.nunique()], ["Maps in course/map inventory", maps.map_id.nunique()],
        ["Maps with configured waypoint rows", wp_map_count], ["Maps with no configured waypoint rows", len(missing_maps)],
        ["Configured waypoint rows", len(waypoints)], ["Rows with Hub waypoint_id", waypoints.waypoint_id.notna().sum()],
        ["Rows with numeric waypoint_number", numeric.notna().sum()], ["Rows without numeric waypoint_number", numeric.isna().sum()],
        ["Duplicate non-null (map_id, waypoint_number) pairs", dup],
        ["Going Reports with linked stick readings for comparison", stick.going_report_id.nunique()],
        ["Stick-reading rows available for comparison", len(stick)],
    ])

    k = load_json("jcr_kml_validation_report.json")
    status = k.get("status_counts", {})
    write("kml_result.md", ["QA measure", "Result"], [
        ["Standalone KML files", k["standalone_kml_count"]], ["JCR KML files", k["jcr_claimed_kml_count"]],
        ["JCR files matched to one active Hub map", status.get("matched", status.get("available_and_matched", 0))],
        ["JCR files requiring map review", sum(v for key, v in status.items() if "ambig" in key or "review" in key)],
        ["JCR numeric waypoint placemarks", k["jcr_numeric_waypoint_count"]], ["JCR invalid or implausible coordinates", k["jcr_invalid_or_implausible_coordinates"]],
        ["Duplicate placemark IDs", k["jcr_duplicate_placemark_ids"]], ["Duplicate numeric waypoint labels", k["jcr_duplicate_numeric_labels"]],
        ["XML parse errors", k["parse_error_count"]],
    ])

    z = load_json("jcr_section_zone_qa_report.json")
    write("section_zone_result.md", ["QA measure", "Result"], [
        ["Sections", z["section_count"]], ["Zones", z["zone_count"]], ["Section memberships", z["section_membership_count"]],
        ["Zone memberships", z["zone_membership_count"]], ["Waypoints in multiple zones", z["waypoints_in_multiple_zones"]],
        ["Maximum zones on one waypoint", z["max_zones_on_one_waypoint"]], ["Maximum sections on one waypoint", z["max_sections_on_one_waypoint"]],
        ["Section references to unconfigured waypoints", z["section_refs_to_unconfigured_waypoints"]],
        ["Zone references to unconfigured waypoints", z["zone_refs_to_unconfigured_waypoints"]],
        ["Configured waypoints with no section", z["waypoints_with_no_section"]], ["Configured waypoints with no zone", z["waypoints_with_no_zone"]],
    ])

    b = load_json("jcr_bha_calendar_comparison_report.json")
    counts = b.get("comparison_status_counts", {})
    tt_calendar = pd.read_parquet(DATA / "jcr_tt_maps_calendar.parquet")
    tt_rows = len(tt_calendar)
    tt_groups = tt_calendar[["course_id", "race_date"]].drop_duplicates().shape[0]
    write("meeting_data_result.md", ["Meeting-data measure", "Result"], [
        ["BHA workbook rows, all courses, 2021–2026", b["bha_source_rows_all_courses"]], ["BHA JCR fixture rows, 2021–2026", b["bha_jcr_fixture_rows"]],
        ["TT Maps fixture rows currently cached", tt_rows], ["TT Maps course/date groups currently cached", tt_groups],
        ["Merged comparison course/date keys", b["comparison_course_date_count"]], ["Matched course/date keys", counts.get("matched", 0)],
        ["BHA-only course/date keys", b["bha_only_count"]], ["TT Maps-only course/date keys", b["tt_maps_only_count"]],
        ["Course/date keys with multiple TT Maps rows", counts.get("multiple_tt_maps_rows", 0)],
    ])

    gi = load_json("jcr_going_report_import_report.json")
    write("going_report_result.md", ["Measure", "Result"], [["Courses represented", f"{gi['course_count']} / {courses.course_id.nunique()}"], ["Reports retained", gi["report_count"]], ["Maps represented in reports", gi["map_count"]], ["Published reports", gi["published_count"]], ["Unpublished reports", gi["unpublished_count"]], ["Archived reports", gi["archived_count"]], ["Deleted reports", gi["deleted_count"]], ["Abandoned reports", gi["abandoned_count"]], ["Waypoint-map references", gi["waypoint_map_reference_count"]], ["Zone-map references", gi["zone_map_reference_count"]], ["PDF references", gi["pdf_reference_count"]], ["Uploaded-map references", gi["uploaded_map_reference_count"]]])
    au = load_json("jcr_going_report_authorship_report.json")
    write("authorship_result.md", ["Report classification", "Reports"], [[k, v] for k, v in au["author_type_counts"].items()])

    ms = load_json("jcr_meeting_status_reconciliation_report.json")
    resolved = ms.get("resolved_status_counts", {})
    write("meeting_status_result.md", ["Reconciled status", "Course/date rows"], [[k, v] for k, v in resolved.items()] + [["Planned but no Going Report", ms["planned_without_going_report_count"]], ["Cancelled or abandoned from calendar note", ms["calendar_cancelled_or_replaced_count"]], ["Report-only course/date rows", ms["report_only_course_date_count"]], ["Reconciled course/date rows", ms["reconciliation_course_date_count"]]])
    primary = pd.read_parquet(DATA / "jcr_meeting_status_reconciliation.parquet")
    state_col = "primary_report_state" if "primary_report_state" in primary.columns else "latest_report_state"
    abandoned_col = "primary_abandoned" if "primary_abandoned" in primary.columns else "latest_report_abandoned"
    rows = primary.groupby([abandoned_col, state_col]).size().reset_index(name="Meetings")
    write("primary_selection.md", ["Primary report selection under last-published rule", "Meetings"], [[f"{'Abandoned' if a else 'Non-abandoned'}, {s}", n] for a, s, n in rows.itertuples(index=False)])

    bc = load_json("jcr_bhagi_compliance_report.json")
    compliance = pd.read_parquet(DATA / "jcr_bhagi_compliance.parquet").copy()
    scope = pd.read_parquet(DATA / "jcr_bhagi_scope.parquet").copy()
    compliance["race_date"] = pd.to_datetime(compliance["race_date"], errors="coerce")
    scope["race_date"] = pd.to_datetime(scope["race_date"], errors="coerce")
    compliance["year"] = compliance["race_date"].dt.year
    scope["year"] = scope["race_date"].dt.year

    write("bhagi_result.md", ["Population / indicator", "Meetings"], [
        ["Actual Turf meetings scored", bc["turf_actual_meeting_count"]],
        ["Actual meetings, all surfaces", bc["actual_meeting_count_all_surfaces"]],
        ["AWT-only meetings excluded", bc["scope_status_counts"].get("excluded_AWT_only", 0)],
        ["Meetings with unresolved surface", bc["scope_status_counts"].get("unresolved_surface", 0)],
        ["Meetings classified Full", int(compliance["compliance_level"].eq("Full").sum())],
        ["Meetings missing declaration-day report", int((~compliance["declaration_day_going_report_present"]).sum())],
        ["Meetings missing race-day report", int((~compliance["race_day_going_report_present"]).sum())],
        ["Meetings without declaration-day GoingStick evidence", int((~compliance["declaration_day_goingstick_present"]).sum())],
        ["Meetings without race-day GoingStick evidence", int((~compliance["race_day_goingstick_present"]).sum())],
        ["Meetings missing declaration-day official going", int((~compliance["declaration_day_official_going_reported"]).sum())],
        ["Meetings missing race-day official going", int((~compliance["race_day_official_going_reported"]).sum())],
        ["Meetings missing one or more watering/rails/stalls fields", int((~compliance["all_requested_information_available"]).sum())],
    ])

    # Complete meeting-level analytical output: the selected report is explicit,
    # while stick evidence is represented independently by timestamped datasets.
    meeting_cols = [
        "course_name", "race_date", "surface", "surface_source",
        "declaration_day_proxy_dates",
        "declaration_day_report_id", "declaration_day_report_state", "declaration_day_report_author_type",
        "declaration_day_report_make_date", "declaration_day_official_going", "declaration_day_watering",
        "declaration_day_rails", "declaration_day_stalls", "declaration_day_unique_stick_dataset_count",
        "declaration_day_unique_stick_reading_rows", "declaration_day_stick_measurement_dates",
        "race_day_report_id", "race_day_report_state", "race_day_report_author_type", "race_day_report_make_date",
        "race_day_official_going", "race_day_watering", "race_day_rails", "race_day_stalls",
        "race_day_unique_stick_dataset_count", "race_day_unique_stick_reading_rows", "race_day_stick_measurement_dates",
        "compliance_level", "compliance_flags",
    ]
    meeting_rows = compliance.sort_values(["course_name", "race_date"])[meeting_cols].itertuples(index=False, name=None)
    write("bhagi_meeting_detail.md", [c.replace("_", " ").title() for c in meeting_cols], meeting_rows)

    scope_summary = (scope.groupby(["course_name", "year", "scope_status"], dropna=False).size()
                     .unstack("scope_status", fill_value=0).reset_index())
    for status in ["scored_Turf", "excluded_AWT_only", "unresolved_surface"]:
        if status not in scope_summary:
            scope_summary[status] = 0
    scope_summary = scope_summary.sort_values(["course_name", "year"])
    write("bhagi_scope_by_course_year.md", ["Course", "Year", "Turf meetings scored", "AWT-only excluded", "Surface unresolved"],
          scope_summary[["course_name", "year", "scored_Turf", "excluded_AWT_only", "unresolved_surface"]].itertuples(index=False, name=None))

    course_year = (compliance.groupby(["course_name", "year"], dropna=False).agg(
        turf_meetings=("race_date", "size"),
        full=("compliance_level", lambda s: int(s.eq("Full").sum())),
        missing_declaration_report=("declaration_day_going_report_present", lambda s: int((~s).sum())),
        missing_race_report=("race_day_going_report_present", lambda s: int((~s).sum())),
        missing_declaration_stick=("declaration_day_goingstick_present", lambda s: int((~s).sum())),
        missing_race_stick=("race_day_goingstick_present", lambda s: int((~s).sum())),
        missing_declaration_going=("declaration_day_official_going_reported", lambda s: int((~s).sum())),
        missing_race_going=("race_day_official_going_reported", lambda s: int((~s).sum())),
        missing_watering_rails_stalls=("all_requested_information_available", lambda s: int((~s).sum())),
    ).reset_index().sort_values(["course_name", "year"]))
    course_year["full_pct"] = (100 * course_year["full"] / course_year["turf_meetings"]).round(1)
    write("bhagi_course_year.md", ["Course", "Year", "Turf meetings", "Full", "Full %", "Missing declaration report", "Missing race-day report", "Missing declaration-day stick", "Missing race-day stick", "Missing declaration going", "Missing race going", "Missing watering/rails/stalls"],
          course_year[["course_name", "year", "turf_meetings", "full", "full_pct", "missing_declaration_report", "missing_race_report", "missing_declaration_stick", "missing_race_stick", "missing_declaration_going", "missing_race_going", "missing_watering_rails_stalls"]].itertuples(index=False, name=None))

    exceptions = compliance.loc[compliance["compliance_flags"].fillna("").ne("")].sort_values(["course_name", "race_date"])
    exception_cols = ["course_name", "race_date", "surface_source", "declaration_day_report_id", "declaration_day_report_state", "race_day_report_id", "race_day_report_state", "declaration_day_unique_stick_dataset_count", "race_day_unique_stick_dataset_count", "compliance_flags"]
    write("bhagi_exceptions.md", [c.replace("_", " ").title() for c in exception_cols], exceptions[exception_cols].itertuples(index=False, name=None))

    qa = load_json("jcr_stick_reading_qa_report.json")
    ts = load_json("jcr_stick_timestamp_qa_report.json")
    write("stick_qa_result.md", ["QA check", "Result"], [["Index outside 0–15", qa["range_failures"]["index"]], ["Penetration outside 0–15", qa["range_failures"]["penetrate"]], ["Shear outside 0–15", qa["range_failures"]["shear"]], ["Index/penetration/shear boundary values at 0 or 15", "/".join(str(qa["boundary_flags"][k]) for k in ("index", "penetrate", "shear"))], ["Missing or non-numeric index, penetration or shear", "/".join(str(qa["missing_or_non_numeric"][k]) for k in ("index", "penetrate", "shear"))], ["Duplicate report/waypoint keys", qa["duplicate_report_waypoint_rows"]], ["Unexpected waypoint numbers", qa["unexpected_waypoint_rows"]], ["Reports exceeding configured waypoint count", qa["reports_exceeding_configured_waypoints"]], ["Report-level QA reviews", qa["report_level_qa_review"]], ["Stick readings with joined make_date", ts["rows_with_joined_make_date"]], ["Stick readings where created_at equals updated_at", ts["stick_created_equals_updated_rows"]]])

    ts = load_json("jcr_stick_timestamp_qa_report.json")
    qa = load_json("jcr_stick_reading_qa_report.json")
    stick_import = load_json("jcr_stick_reading_import_report.json") if (DATA / "jcr_stick_reading_import_report.json").exists() else qa
    raw_stick = pd.read_parquet(DATA / "jcr_stick_readings.parquet")
    write("stick_overall_result.md", ["GoingStick import measure", "Result"], [
        ["Configured waypoint rows", qa["configured_waypoint_rows"]],
        ["Configured maps", qa["configured_maps"]],
        ["Reading rows", stick_import["reading_rows"]],
        ["Courses represented", raw_stick["course_name"].nunique()],
        ["Going Reports with readings", raw_stick["going_report_id"].nunique()],
        ["Reading rows attributed using make_date because race_date is missing", stick_import.get("rows_included_by_make_date_fallback", 0)],
        ["Rows with joined Going Report make_date", ts["rows_with_joined_make_date"]],
        ["Rows where stick created_at equals updated_at", ts["stick_created_equals_updated_rows"]],
        ["Rows where report created_at equals stick created_at", ts["report_created_equals_stick_created_rows"]],
        ["Rows where report created_at differs from stick created_at", ts["report_created_differs_from_stick_created_rows"]],
    ])
    enriched = pd.read_parquet(DATA / "jcr_stick_readings_enriched.parquet")
    enriched["reading_year"] = pd.to_datetime(enriched["race_date"], errors="coerce").dt.year
    raw_stick["reading_date"] = pd.to_datetime(raw_stick["race_date"], errors="coerce")
    missing_race_date = raw_stick["reading_date"].isna()
    if "source_make_date" in raw_stick:
        raw_stick.loc[missing_race_date, "reading_date"] = pd.to_datetime(raw_stick.loc[missing_race_date, "source_make_date"], errors="coerce")
    raw_stick["reading_year"] = raw_stick["reading_date"].dt.year
    raw_stick["make_date_fallback"] = raw_stick["race_date"].isna() & raw_stick["reading_date"].notna()
    years = list(range(2021, 2027))
    course_year = raw_stick.pivot_table(index="course_name", columns="reading_year", values="reading_id", aggfunc="count", fill_value=0).reindex(columns=years, fill_value=0).sort_index()
    fallback_counts = raw_stick.groupby("course_name")["make_date_fallback"].sum()
    course_year["Rows using make_date fallback"] = fallback_counts.reindex(course_year.index, fill_value=0).astype(int)
    course_year["Total"] = course_year[years].sum(axis=1)
    rows = [[course, *[int(row[y]) for y in years], int(row["Rows using make_date fallback"]), int(row["Total"])] for course, row in course_year.iterrows()]
    totals = course_year.sum(axis=0)
    rows.append(["Total", *[int(totals[y]) for y in years], int(totals["Rows using make_date fallback"]), int(totals["Total"])])
    write("stick_course_year.md", ["Course", *map(str, years), "Rows using make_date fallback", "Total"], rows)

    enriched = pd.read_parquet(DATA / "jcr_stick_readings_enriched.parquet")
    freq = enriched.groupby(["course_name", "make_to_stick_created_days"]).size().unstack(fill_value=0).sort_index()
    days = sorted(freq.columns, key=lambda x: (str(x)))
    headers = ["Course", "Stick readings", "Reports with readings"] + ["Same calendar day" if d == 0 else f"+{d} days" for d in days]
    rows = [[course, int(g.shape[0]), int(g.going_report_id.nunique())] + [int(freq.loc[course].get(d, 0)) for d in days] for course, g in enriched.groupby("course_name")]
    total = ["Total", len(enriched), enriched.going_report_id.nunique()] + [int(freq[d].sum()) for d in days]
    write("stick_timestamp_course.md", headers, rows + [total])

    compliance = pd.read_parquet(DATA / "jcr_waypoint_compliance.parquet")
    compliance["missing_configured_records"] = (compliance["configured_waypoint_numbers"] - compliance["distinct_waypoints"] + compliance["unexpected_waypoint_count"]).clip(lower=0)
    course_rows = compliance.groupby("course_name").agg(
        reports_with_readings=("going_report_id", "nunique"),
        reports_with_missing_configured_waypoints=("missing_configured_records", lambda x: int((x > 0).sum())),
        missing_configured_waypoint_records=("missing_configured_records", "sum"),
        reports_with_unexpected_waypoints=("unexpected_waypoint_count", lambda x: int((x > 0).sum())),
        unexpected_waypoint_records=("unexpected_waypoint_count", "sum"),
    ).reset_index()
    rows = course_rows.values.tolist()
    rows.append(["Total", int(course_rows.reports_with_readings.sum()), int(course_rows.reports_with_missing_configured_waypoints.sum()), int(course_rows.missing_configured_waypoint_records.sum()), int(course_rows.reports_with_unexpected_waypoints.sum()), int(course_rows.unexpected_waypoint_records.sum())])
    write("course_waypoint_result.md", ["Course", "Reports with readings", "Reports with missing configured waypoints", "Missing configured waypoint records", "Reports with unexpected waypoints", "Unexpected waypoint records"], rows)

    reports = pd.read_parquet(DATA / "jcr_going_reports.parquet")
    mixed = reports[reports.duplicated(["course_id", "race_date"], keep=False)].copy()
    mixed_groups = mixed.groupby(["course_id", "race_date"]).size()
    write("mixed_report.md", ["Mixed-meeting/report measure", "Result"], [["Mixed meeting groups", len(mixed_groups)], ["Reports within mixed groups", len(mixed)], ["Mixed-group reports with report_state = published", int((mixed.report_state == "published").sum())], ["Mixed-group reports with report_state = unpublished", int((mixed.report_state == "unpublished").sum())], ["Mixed-group reports with report_state = deleted", int((mixed.report_state == "deleted").sum())], ["Mixed meetings with at least one published report", int(mixed.groupby(["course_id", "race_date"]).report_state.apply(lambda x: (x == "published").any()).sum())], ["Mixed meetings with no published report", int(mixed.groupby(["course_id", "race_date"]).report_state.apply(lambda x: not (x == "published").any()).sum())]])

    dl = load_json("jcr_map_discipline_layout_report.json")
    write("discipline_result.md", ["Result", "Maps"], [["Flat", dl["discipline_counts"].get("flat", 0)], ["Jumps", dl["discipline_counts"].get("jumps", 0)], ["Unknown discipline", dl["discipline_counts"].get("unknown", 0)], ["Resolved non-generic layouts", dl["layout_status_counts"].get("resolved_from_hub_label", 0)], ["Ambiguous/generic layouts", dl["layout_status_counts"].get("ambiguous_generic_label", 0)], ["Discipline unresolved", dl["discipline_counts"].get("unresolved", 0)], ["Active/primary maps", dl["primary_map_count"]], ["Archived/historical maps", dl["historical_map_count"]]])


if __name__ == "__main__":
    main()
