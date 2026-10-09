"""Apply confirmed operational map assignments from the branded XLSX review."""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path
from zipfile import ZipFile
from xml.etree import ElementTree as ET

import pandas as pd


OUT = Path("data/config")
NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}


def read_sheet(path: Path, sheet_number: int) -> list[dict[str, str]]:
    with ZipFile(path) as archive:
        strings_root = ET.fromstring(archive.read("xl/sharedStrings.xml"))
        strings = [
            "".join(node.text or "" for node in item.findall(".//m:t", NS))
            for item in strings_root.findall("m:si", NS)
        ]
        root = ET.fromstring(archive.read(f"xl/worksheets/sheet{sheet_number}.xml"))
    rows = []
    for row in root.findall(".//m:sheetData/m:row", NS):
        if int(row.attrib["r"]) < 4:
            continue
        values = {}
        for cell in row.findall("m:c", NS):
            value = cell.find("m:v", NS)
            text = "" if value is None else value.text or ""
            if cell.attrib.get("t") == "s" and text:
                text = strings[int(text)]
            values[re.sub(r"\d", "", cell.attrib["r"])] = text
        rows.append(values)
    return rows


def main() -> None:
    workbook = OUT / "jcr_map_review.xlsx"
    rows = read_sheet(workbook, 3)
    assignments = [row for row in rows if row.get("U") in {"Confirmed", "Changed"} and row.get("T")]
    maps = pd.read_parquet(OUT / "jcr_maps.parquet")
    maps["reviewed_map_type"] = pd.NA
    maps["review_status"] = "Not reviewed"
    maps["reviewer"] = pd.NA
    maps["review_date"] = pd.NA
    maps["review_notes"] = pd.NA
    applied = []
    for row in assignments:
        map_id = int(row["C"])
        reviewed = row["T"].strip().casefold().replace(" ", "_")
        if reviewed not in {"flat", "jumps", "all_weather"}:
            continue
        mask = maps["map_id"].eq(map_id)
        if not mask.any():
            continue
        maps.loc[mask, "map_type"] = reviewed
        maps.loc[mask, "map_type_evidence"] = f"operational_review:{row.get('U')}"
        maps.loc[mask, "reviewed_map_type"] = reviewed
        maps.loc[mask, "review_status"] = row.get("U")
        maps.loc[mask, "reviewer"] = row.get("V") or pd.NA
        maps.loc[mask, "review_date"] = row.get("W") or pd.NA
        maps.loc[mask, "review_notes"] = row.get("X") or pd.NA
        applied.append({"map_id": map_id, "reviewed_map_type": reviewed, "review_status": row.get("U"), "reviewer": row.get("V")})
    maps.to_parquet(OUT / "jcr_maps.parquet", index=False)
    report = {
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(),
        "workbook": str(workbook),
        "map_review_rows": len(rows),
        "confirmed_or_changed_rows": len(assignments),
        "applied_assignments": len(applied),
        "status_counts": pd.Series([row.get("U", "") for row in rows]).value_counts().to_dict(),
        "reviewed_type_counts": pd.Series([row.get("T", "") for row in assignments]).value_counts().to_dict(),
        "unreviewed_map_ids": [int(row["C"]) for row in rows if row.get("U") == "Not reviewed"],
        "cheltenham_detail_review_status": "not_reviewed",
        "assignments": applied,
    }
    (OUT / "jcr_map_review_import_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: report[k] for k in ["map_review_rows", "confirmed_or_changed_rows", "applied_assignments", "status_counts", "reviewed_type_counts", "unreviewed_map_ids"]}, indent=2))


if __name__ == "__main__":
    main()
