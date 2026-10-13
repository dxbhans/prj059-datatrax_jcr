"""Shared primary Going Report selection rule."""

from __future__ import annotations

import pandas as pd


def select_primary_reports(reports: pd.DataFrame, keys: list[str]) -> pd.DataFrame:
    """Select the last published report, falling back to the latest report.

    Publication is determined only from ``report_state == "published"``.
    Within the selected publication class, ``updated_at`` and then
    ``report_id`` determine the last record.
    """
    frame = reports.copy()
    frame["_is_published_primary"] = frame["report_state"].eq("published")
    frame["updated_at"] = pd.to_datetime(frame["updated_at"], errors="coerce")
    selected = (
        frame.sort_values(keys + ["_is_published_primary", "updated_at", "report_id"])
        .drop_duplicates(keys, keep="last")
        .drop(columns=["_is_published_primary"])
    )
    return selected
