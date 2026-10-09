"""Import and validate TT Hub Going Report SVG map assets for JCR."""

from __future__ import annotations

import hashlib
import json
import os
import re
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd


BASE_URL = os.getenv("TURFTRAX_SVG_BASE_URL", "https://hub.turftrax.co.uk").rstrip("/")
OUTPUT = Path("data/config")
SVG_ROOT = OUTPUT / "svg"
ROLES = ("waypoints_svg", "zones_svg")


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def text_of(node: ET.Element | None) -> str | None:
    if node is None:
        return None
    value = " ".join("".join(node.itertext()).split())
    return value or None


def parse_svg(path: Path, document: dict) -> tuple[list[dict], str | None]:
    try:
        root = ET.parse(path).getroot()
        if local_name(root.tag).lower() != "svg":
            return [], "root element is not svg"
        elements = []
        for node in root.iter():
            element_id = node.attrib.get("id")
            if not element_id:
                continue
            labels = [text_of(child) for child in list(node)
                      if local_name(child.tag).lower() in {"title", "desc"}]
            label = " ".join(value for value in labels if value) or None
            elements.append({
                "source_document_id": document["source_document_id"],
                "report_id": document["report_id"],
                "map_id": document["map_id"],
                "document_role": document["document_role"],
                "svg_element_id": element_id,
                "element_name": local_name(node.tag),
                "element_class": node.attrib.get("class"),
                "element_style": node.attrib.get("style"),
                "element_label": label,
            })
        return elements, None
    except (ET.ParseError, OSError) as exc:
        return [], str(exc)


def retrieve(candidate: dict) -> dict:
    path = SVG_ROOT / candidate["source_path"]
    path.parent.mkdir(parents=True, exist_ok=True)
    result = dict(candidate)
    result.update({
        "local_path": str(path),
        "retrieved_at_utc": now(),
        "retrieval_status": "failed",
        "http_status": None,
        "content_type": None,
        "content_sha256": None,
        "content_bytes": None,
        "parse_status": "not_attempted",
        "parse_error": None,
        "element_count": 0,
    })
    if path.exists() and path.stat().st_size > 0:
        body = path.read_bytes()
        result["retrieval_status"] = "retrieved"
        result["content_type"] = "image/svg+xml"
        result["content_sha256"] = hashlib.sha256(body).hexdigest()
        result["content_bytes"] = len(body)
        parsed, error = parse_svg(path, result)
        result["parse_status"] = "parsed" if error is None else "failed"
        result["parse_error"] = error
        result["element_count"] = len(parsed)
        return result, parsed
    try:
        request = urllib.request.Request(
            candidate["source_url"],
            headers={"User-Agent": "DataTrax-JCR-SVG-Importer/0.1"},
        )
        with urllib.request.urlopen(request, timeout=4) as response:
            body = response.read()
            result["http_status"] = getattr(response, "status", 200)
            result["content_type"] = response.headers.get("Content-Type")
        path.write_bytes(body)
        result["retrieval_status"] = "retrieved"
        result["content_sha256"] = hashlib.sha256(body).hexdigest()
        result["content_bytes"] = len(body)
        parsed, error = parse_svg(path, result)
        result["parse_status"] = "parsed" if error is None else "failed"
        result["parse_error"] = error
        result["element_count"] = len(parsed)
        return result, parsed
    except urllib.error.HTTPError as exc:
        result["http_status"] = exc.code
        result["retrieval_status"] = "not_available" if exc.code == 404 else "failed"
        result["parse_status"] = "not_attempted"
        result["parse_error"] = f"HTTP {exc.code}: {exc.reason}"
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        result["parse_error"] = str(exc)
    return result, []


def candidate_rows(reports: pd.DataFrame) -> pd.DataFrame:
    # One retained revision per map/date is sufficient for configuration validation;
    # the full report inventory remains available in jcr_going_reports.parquet.
    selected = (
        reports.sort_values(["map_id", "race_date", "report_id"])
        .drop_duplicates(["map_id", "race_date"], keep="last")
    )
    rows = []
    for row in selected.to_dict("records"):
        report_id = int(row["report_id"])
        for role, suffix in (("waypoints_svg", "waypoints"), ("zones_svg", "zones")):
            source_path = f"maps/going-reports/{report_id}_{suffix}.svg"
            rows.append({
                "source_document_id": f"going_reports:{report_id}:{role}",
                "source_table": "going_reports",
                "source_id": report_id,
                "report_id": report_id,
                "course_id": row.get("course_id"),
                "course_name": row.get("course_name"),
                "map_id": row.get("map_id"),
                "map_label": row.get("map_label"),
                "race_date": row.get("race_date"),
                "document_role": role,
                "source_path": source_path,
                "source_url": f"{BASE_URL}/{source_path}",
                "raw_waypoint_map": row.get("waypoint_map"),
                "raw_zone_map": row.get("zone_map"),
            })
    return pd.DataFrame(rows)


def add_matches(elements: pd.DataFrame, waypoints: pd.DataFrame) -> pd.DataFrame:
    if elements.empty:
        elements["matched_feature_type"] = pd.Series(dtype="string")
        elements["matched_feature_id"] = pd.Series(dtype="Int64")
        elements["match_status"] = pd.Series(dtype="string")
        return elements
    lookup = {}
    for row in waypoints.dropna(subset=["map_id", "waypoint_number"]).to_dict("records"):
        key = (int(row["map_id"]), int(float(row["waypoint_number"])))
        lookup[key] = row["waypoint_id"]
    types, ids, statuses = [], [], []
    for row in elements.to_dict("records"):
        candidates = [row.get("element_label"), row.get("svg_element_id")]
        number = None
        for value in candidates:
            if value and re.fullmatch(r"\D*(\d{1,3})\D*", str(value).strip()):
                number = int(re.fullmatch(r"\D*(\d{1,3})\D*", str(value).strip()).group(1))
                break
        waypoint_id = lookup.get((int(row["map_id"]), number)) if number is not None and pd.notna(row["map_id"]) else None
        types.append("waypoint" if waypoint_id is not None else None)
        ids.append(waypoint_id)
        statuses.append("matched_waypoint_number" if waypoint_id is not None else "unmatched")
    elements["matched_feature_type"] = types
    elements["matched_feature_id"] = pd.array(ids, dtype="Int64")
    elements["match_status"] = statuses
    return elements


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    reports = pd.read_parquet(OUTPUT / "jcr_going_reports.parquet")
    waypoints = pd.read_parquet(OUTPUT / "jcr_waypoints.parquet")
    candidates = candidate_rows(reports)
    results, parsed_elements = [], []
    with ThreadPoolExecutor(max_workers=int(os.getenv("SVG_IMPORT_WORKERS", "128"))) as pool:
        futures = [pool.submit(retrieve, row) for row in candidates.to_dict("records")]
        for future in as_completed(futures):
            result, elements = future.result()
            results.append(result)
            parsed_elements.extend(elements)
    documents = pd.DataFrame(results).sort_values(["report_id", "document_role"])
    elements = add_matches(pd.DataFrame(parsed_elements), waypoints)
    documents.to_parquet(OUTPUT / "jcr_svg_source_documents.parquet", index=False)
    documents.loc[documents["retrieval_status"] == "retrieved"].to_parquet(
        OUTPUT / "jcr_svg_documents.parquet", index=False
    )
    elements.to_parquet(OUTPUT / "jcr_svg_elements.parquet", index=False)
    report = {
        "extracted_at_utc": now(),
        "base_url": BASE_URL,
        "source_report_count": int(reports["report_id"].nunique()),
        "representative_report_count": int(candidates["report_id"].nunique() // 2),
        "selection_rule": "one report per map_id and race_date, highest report_id retained",
        "candidate_count": int(len(candidates)),
        "retrieved_count": int((documents["retrieval_status"] == "retrieved").sum()),
        "not_available_count": int((documents["retrieval_status"] == "not_available").sum()),
        "failed_count": int((documents["retrieval_status"] == "failed").sum()),
        "parsed_count": int((documents["parse_status"] == "parsed").sum()),
        "parse_failed_count": int((documents["parse_status"] == "failed").sum()),
        "element_count": int(len(elements)),
        "matched_waypoint_element_count": int((elements.get("match_status", pd.Series(dtype=str)) == "matched_waypoint_number").sum()),
        "unmatched_element_count": int((elements.get("match_status", pd.Series(dtype=str)) == "unmatched").sum()),
        "duplicate_element_ids": int(elements.duplicated(["source_document_id", "svg_element_id"]).sum()) if not elements.empty else 0,
        "status": "complete",
        "source_path_rule": "maps/going-reports/{report_id}_{waypoints|zones}.svg",
        "raw_report_asset_fields_used_for_discovery": False,
    }
    (OUTPUT / "jcr_svg_validation_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
