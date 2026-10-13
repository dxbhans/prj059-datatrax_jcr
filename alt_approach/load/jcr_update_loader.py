"""Reusable JCR GoingStick analysis inputs and transformations.

The Ascot prototype queried one course directly from the Hub.  JCR already
has a versioned, normalised Parquet configuration package, so this module
loads that package and keeps course, map and waypoint identity explicit.
"""

from __future__ import annotations

import logging
import os
from pathlib import Path

import pandas as pd

LOGGER = logging.getLogger(__name__)

DEFAULT_START = pd.Timestamp("2021-01-01")
DEFAULT_END = pd.Timestamp("2026-12-31")


def configure_logging(level: int = logging.INFO) -> None:
    logging.basicConfig(
        level=level,
        format="%(asctime)s | %(levelname)s | %(message)s",
        force=True,
    )
    LOGGER.setLevel(level)


def _path(data_dir: Path, name: str) -> Path:
    path = data_dir / name
    if not path.exists():
        raise FileNotFoundError(f"Required JCR input is missing: {path}")
    return path


def load_sources(data_dir: Path, refresh: bool = False) -> dict[str, pd.DataFrame]:
    """Load the normalised JCR configuration and GoingStick extracts.

    ``refresh`` is accepted for API compatibility with the Ascot loader.  The
    JCR extracts are intentionally treated as immutable, versioned inputs;
    refreshing them is an upstream extraction operation.
    """
    del refresh
    files = {
        "courses": "jcr_courses.parquet",
        "maps": "jcr_map_discipline_layout.parquet",
        "reports": "jcr_going_reports.parquet",
        "readings": "jcr_stick_readings.parquet",
        "meetings": "jcr_bhagi_compliance.parquet",
        "meeting_status": "jcr_meeting_status_reconciliation.parquet",
        "waypoints": "jcr_waypoints.parquet",
        "sections": "jcr_sections.parquet",
        "zones": "jcr_zones.parquet",
        "waypoint_sections": "jcr_waypoint_sections.parquet",
        "waypoint_zones": "jcr_waypoint_zones.parquet",
    }
    sources = {key: pd.read_parquet(_path(data_dir, filename)) for key, filename in files.items()}
    LOGGER.info("Loaded JCR inputs: %s", {key: len(value) for key, value in sources.items()})
    return prepare_sources(sources)


def _date(frame: pd.DataFrame, column: str) -> None:
    if column in frame:
        frame[column] = pd.to_datetime(frame[column], errors="coerce").dt.normalize()


def _number(frame: pd.DataFrame, column: str) -> None:
    if column in frame:
        frame[column] = pd.to_numeric(frame[column], errors="coerce")


def prepare_sources(sources: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    """Apply stable dates, numeric fields and common identity columns."""
    result = {key: value.copy() for key, value in sources.items()}
    for name in ("reports", "readings", "meetings", "meeting_status"):
        _date(result[name], "race_date")
        _date(result[name], "meeting_date")
        _date(result[name], "make_date")
        _date(result[name], "created_at")
        _date(result[name], "updated_at")

    for column in ("index", "penetrate", "shear", "way_point"):
        _number(result["readings"], column)
    _number(result["readings"], "going_report_id")
    _number(result["readings"], "map_id")
    _number(result["reports"], "report_id")
    _number(result["reports"], "map_id")
    _number(result["waypoints"], "map_id")
    _number(result["waypoints"], "waypoint_number")
    _number(result["waypoint_sections"], "map_id")
    _number(result["waypoint_sections"], "waypoint_number")
    _number(result["waypoint_zones"], "map_id")
    _number(result["waypoint_zones"], "waypoint_number")

    result["reports"]["course_id"] = pd.to_numeric(result["reports"]["course_id"], errors="coerce").astype("Int64")
    result["readings"]["course_id"] = pd.to_numeric(result["readings"]["course_id"], errors="coerce").astype("Int64")
    result["maps"]["course_id"] = pd.to_numeric(result["maps"]["course_id"], errors="coerce").astype("Int64")
    return result


def course_register(sources: dict[str, pd.DataFrame]) -> pd.DataFrame:
    """Return the controlled course register in display order."""
    columns = ["course_id", "canonical_name", "included", "map_count", "waypoint_count"]
    available = [column for column in columns if column in sources["courses"]]
    return sources["courses"][available].drop_duplicates("course_id").sort_values(
        "course_id"
    )


def select_course(
    sources: dict[str, pd.DataFrame], course_id: int | None = None
) -> dict[str, pd.DataFrame]:
    """Filter course-bearing inputs by stable JCR course ID."""
    if course_id is None:
        return {key: value.copy() for key, value in sources.items()}
    selected = {}
    for key, frame in sources.items():
        if "course_id" in frame.columns:
            selected[key] = frame.loc[frame["course_id"].eq(course_id)].copy()
        else:
            selected[key] = frame.copy()
    return selected


def add_map_metadata(
    sources: dict[str, pd.DataFrame], readings: pd.DataFrame | None = None
) -> pd.DataFrame:
    """Join readings to the controlled map discipline/layout metadata."""
    frame = (sources["readings"] if readings is None else readings).copy()
    maps = sources["maps"].copy()
    keep = [
        "map_id", "course_id", "canonical_name", "map_label", "discipline",
        "map_role_resolved", "active", "layout_resolution_status", "comparison_group",
    ]
    keep = [column for column in keep if column in maps.columns]
    frame = frame.merge(maps[keep].drop_duplicates("map_id"), on=["map_id", "course_id"], how="left")
    return frame


def meeting_summary(sources: dict[str, pd.DataFrame]) -> pd.DataFrame:
    """Use the JCR actual-meeting compliance table as the denominator."""
    frame = sources["meetings"].copy()
    if "meeting_date" not in frame and "race_date" in frame:
        frame["meeting_date"] = frame["race_date"]
    frame["meeting_date"] = pd.to_datetime(frame["meeting_date"], errors="coerce").dt.normalize()
    return frame.sort_values(["course_id", "meeting_date"]).reset_index(drop=True)


def valid_readings(readings: pd.DataFrame) -> pd.DataFrame:
    """Keep numeric, non-boundary readings for distributional analysis."""
    frame = readings.copy()
    required = [column for column in ("index", "penetrate", "shear") if column in frame]
    frame = frame.dropna(subset=required)
    for flag in (
        "index_out_of_range", "penetrate_out_of_range", "shear_out_of_range",
        "index_boundary_0_or_15", "penetrate_boundary_0_or_15", "shear_boundary_0_or_15",
    ):
        if flag in frame:
            frame = frame.loc[~frame[flag].fillna(False).astype(bool)]
    return frame


def reading_analysis(
    sources: dict[str, pd.DataFrame],
    course_id: int | None = None,
    start: pd.Timestamp = DEFAULT_START,
    end: pd.Timestamp = DEFAULT_END,
) -> pd.DataFrame:
    """Create the map-aware reading table used by the report."""
    frame = add_map_metadata(sources, sources["readings"])
    frame = valid_readings(frame)
    frame = frame.loc[frame["race_date"].between(start, end)].copy()
    if course_id is not None:
        frame = frame.loc[frame["course_id"].eq(course_id)].copy()
    reports = sources["reports"][[
        "report_id", "official_going", "race_date", "course_id", "author_type",
    ]].drop_duplicates("report_id")
    frame = frame.merge(
        reports.rename(columns={"race_date": "report_race_date"}),
        left_on="going_report_id", right_on="report_id", how="left", suffixes=("", "_report"),
    )
    frame["official_going_clean"] = (
        frame["official_going"].astype("string").fillna("").str.strip().str.replace(r"\s+", " ", regex=True)
    )
    frame["year"] = frame["race_date"].dt.year
    return frame


def add_spatial_membership(
    sources: dict[str, pd.DataFrame], readings: pd.DataFrame
) -> pd.DataFrame:
    """Attach section and zone labels, preserving overlapping zone membership."""
    frame = readings.copy()
    frame["waypoint_number"] = pd.to_numeric(frame["way_point"], errors="coerce")
    sections = sources["waypoint_sections"][["map_id", "waypoint_number", "section_id"]].drop_duplicates()
    section_names = sources["sections"][["section_id", "section_label"]].drop_duplicates("section_id")
    sections = sections.merge(section_names, on="section_id", how="left")
    frame = frame.merge(sections, on=["map_id", "waypoint_number"], how="left")
    zones = sources["waypoint_zones"][["map_id", "waypoint_number", "zone_id"]].drop_duplicates()
    zone_names = sources["zones"][["zone_id", "zone_label"]].drop_duplicates("zone_id")
    zones = zones.merge(zone_names, on="zone_id", how="left")
    return frame.merge(zones, on=["map_id", "waypoint_number"], how="left")


def course_id_from_environment(default: int | None = None) -> int | None:
    value = os.getenv("JCR_COURSE_ID", "").strip()
    return int(value) if value else default

