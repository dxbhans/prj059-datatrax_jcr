"""Resolve JCR map discipline, layout and comparison groups from available evidence."""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd


OUT = Path("data/config")


def norm(value: object) -> str:
    value = "" if pd.isna(value) else str(value)
    return re.sub(r"[^a-z0-9]+", "_", value.casefold()).strip("_")


def main() -> None:
    maps = pd.read_parquet(OUT / "jcr_maps.parquet")
    kml = pd.read_parquet(OUT / "jcr_kml_inventory.parquet")
    svg = pd.read_parquet(OUT / "jcr_svg_source_documents.parquet")

    kml_by_map = {}
    for row in kml[kml["match_status"] == "available_and_matched"].itertuples():
        for value in str(row.match_map_ids_exact).split(","):
            if value.strip().isdigit():
                kml_by_map.setdefault(int(value), []).append(row.file_name)
    svg_stats = (svg.groupby("map_id", dropna=False).agg(
        svg_candidate_count=("source_document_id", "size"),
        svg_retrieved_count=("retrieval_status", lambda s: int((s == "retrieved").sum())),
        svg_parse_failed_count=("parse_status", lambda s: int((s == "failed").sum())),
        svg_report_count=("report_id", "nunique"),
    ).reset_index())

    records = []
    for row in maps.to_dict("records"):
        label = str(row.get("map_label") or "").strip()
        track = str(row.get("track_names") or "").strip()
        evidence_text = " ".join([label, track, str(row.get("going_group_label") or "")]).casefold()
        explicit_type = str(row.get("map_type") or "unknown")
        if explicit_type in {"flat", "jumps"}:
            discipline, confidence = explicit_type, "high"
            evidence = "explicit flat/jump wording in Hub map, track or group metadata"
        elif re.search(r"\b(flat|all.weather)\b", evidence_text):
            discipline, confidence = "flat", "medium"
            evidence = "flat/all-weather wording in Hub metadata"
        elif re.search(r"\b(jump|chase|hurdle|national|mildmay)\b", evidence_text):
            discipline, confidence = "jumps", "medium"
            evidence = "jump-course wording in Hub metadata"
        else:
            discipline, confidence = "unknown", "low"
            evidence = "no reliable discipline wording in available metadata"

        layout_label = label or track or "Unlabelled"
        layout_key = norm(layout_label)
        generic = layout_key in {"map", "new", "old", "map_2", "map_3", "map_4", "map_5", "map_6", "map_7", "map_11"}
        if generic:
            layout_status = "ambiguous_generic_label"
            comparison_group = f"course_{int(row['course_id'])}_map_{int(row['map_id'])}"
        elif discipline == "unknown":
            layout_status = "discipline_unresolved"
            comparison_group = f"course_{int(row['course_id'])}_map_{int(row['map_id'])}"
        else:
            layout_status = "resolved_from_hub_label"
            comparison_group = f"course_{int(row['course_id'])}_{discipline}_{layout_key}"
        map_id = int(row["map_id"])
        records.append({
            **row,
            "discipline": discipline,
            "layout_label": layout_label,
            "layout_key": layout_key,
            "map_role_resolved": "primary" if bool(row["active"]) else "historical",
            "comparison_group": comparison_group,
            "layout_resolution_status": layout_status,
            "evidence": evidence,
            "confidence": confidence,
            "kml_match_count": len(kml_by_map.get(map_id, [])),
            "kml_files": "; ".join(kml_by_map.get(map_id, [])),
        })
    result = pd.DataFrame(records).merge(svg_stats, on="map_id", how="left")
    for col in ["svg_candidate_count", "svg_retrieved_count", "svg_parse_failed_count", "svg_report_count"]:
        result[col] = result[col].fillna(0).astype(int)
    result.to_parquet(OUT / "jcr_map_discipline_layout.parquet", index=False)

    chelt = result[result["canonical_name"].eq("Cheltenham")]
    report = {
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(),
        "map_count": int(len(result)),
        "discipline_counts": result["discipline"].value_counts().to_dict(),
        "layout_status_counts": result["layout_resolution_status"].value_counts().to_dict(),
        "primary_map_count": int((result["map_role_resolved"] == "primary").sum()),
        "historical_map_count": int((result["map_role_resolved"] == "historical").sum()),
        "maps_with_kml_evidence": int((result["kml_match_count"] > 0).sum()),
        "maps_with_svg_evidence": int((result["svg_retrieved_count"] > 0).sum()),
        "cheltenham": chelt[["map_id", "map_label", "discipline", "layout_label", "map_role_resolved", "layout_resolution_status", "confidence"]].to_dict("records"),
        "acceptance_rule": "comparison groups are only shared when discipline and non-generic layout are resolved; otherwise the map remains isolated",
    }
    (OUT / "jcr_map_discipline_layout_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
