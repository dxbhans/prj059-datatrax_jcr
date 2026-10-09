"""Build a branded workbook for calendar/Going Report date exceptions."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import xlsxwriter
from xlsxwriter.utility import xl_col_to_name


OUT = Path("data/config")
WORKBOOK = OUT / "jcr_meeting_date_review.xlsx"


def main() -> None:
    reconciliation = pd.read_parquet(OUT / "jcr_meeting_status_reconciliation.parquet")
    courses = pd.read_parquet(OUT / "jcr_courses.parquet")[["course_id", "canonical_name"]]
    data = reconciliation.merge(courses, on="course_id", how="left")
    bha = pd.read_parquet(OUT / "jcr_bha_fixture_calendar.parquet")
    bha["meeting_date"] = pd.to_datetime(bha["meeting_date"], errors="coerce").dt.date
    bha = bha.groupby(["course_id", "meeting_date"], as_index=False).agg(
        bha_surfaces=("bha_surface", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
        bha_race_codes=("bha_race_code", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
    ).rename(columns={"meeting_date": "race_date"})
    tt = pd.read_parquet(OUT / "jcr_tt_maps_calendar.parquet")
    tt["race_date"] = pd.to_datetime(tt["race_date"], errors="coerce").dt.date
    tt = tt.groupby(["course_id", "race_date"], as_index=False).agg(
        tt_maps_race_type_codes=("race_type_code", lambda s: ";".join(sorted({str(v).strip() for v in s.dropna() if str(v).strip()}))),
    )
    evidence = bha.merge(tt, on=["course_id", "race_date"], how="outer")
    evidence["surface_classification"] = pd.NA
    evidence["discipline"] = pd.NA
    evidence["classification_source"] = pd.NA
    evidence["classification_status"] = "unresolved"
    evidence.loc[evidence["bha_surfaces"].eq("AWT"), ["surface_classification", "discipline", "classification_source", "classification_status"]] = ["AWT", "Flat", "BHA fixture calendar", "classified"]
    evidence.loc[evidence["bha_surfaces"].eq("Turf"), ["surface_classification", "discipline", "classification_source", "classification_status"]] = ["Turf", "Jump", "BHA fixture calendar", "classified"]
    for code, values in {"2": ("Turf", "Jump"), "4": ("AWT", "Flat")}.items():
        mask = evidence["classification_status"].eq("unresolved") & evidence["tt_maps_race_type_codes"].fillna("").eq(code)
        evidence.loc[mask, ["surface_classification", "discipline", "classification_source", "classification_status"]] = [values[0], values[1], "TT Maps race_type_code", "classified_fallback"]
    data = data.merge(evidence, on=["course_id", "race_date"], how="left")
    review_candidates = data[(data["calendar_row_count"].notna() & data["going_report_count"].isna()) | (data["calendar_row_count"].isna() & data["going_report_count"].notna())]
    awt_rows = int(review_candidates["surface_classification"].eq("AWT").sum())
    # AWT is outside the operational review scope; retain unresolved rows for Turf confirmation.
    data = data[data["surface_classification"].ne("AWT") | data["surface_classification"].isna()].copy()
    calendar_only = data[data["calendar_row_count"].notna() & data["going_report_count"].isna()].copy()
    report_only = data[data["calendar_row_count"].isna() & data["going_report_count"].notna()].copy()

    rows = []
    for exception_type, frame in (("Calendar date without Going Report", calendar_only), ("Going Report date absent from calendar", report_only)):
        for row in frame.sort_values(["course_id", "race_date"]).to_dict("records"):
            applicable = exception_type == "Calendar date without Going Report"
            rows.append({
                "Review ID": f"{('CAL' if applicable else 'RPT')}-{int(row['course_id']):03d}-{pd.Timestamp(row['race_date']).strftime('%Y%m%d')}",
                "Exception type": exception_type,
                "Course ID": int(row["course_id"]),
                "Course": row["canonical_name"],
                "Calendar date": row["race_date"] if applicable else None,
                "Calendar status": row.get("calendar_status") if applicable else None,
                "Calendar notes": row.get("calendar_notes") if applicable else None,
                "Calendar ID count": int(row["calendar_row_count"]) if applicable else None,
                "Report race date": row["race_date"] if not applicable else None,
                "Report count": int(row["going_report_count"]) if not applicable else None,
                "Latest report ID": int(row["latest_report_id"]) if not applicable else None,
                "Latest report updated": row.get("latest_report_updated_at") if not applicable else None,
                "Report observed status": row.get("report_observed_status") if not applicable else None,
                "Latest report abandoned": row.get("latest_report_abandoned") if not applicable else None,
                "Latest report state": row.get("latest_report_state") if not applicable else None,
                "Latest report author type": row.get("latest_report_author_type") if not applicable else None,
                "Latest report Hub user": row.get("latest_report_hub_user") if not applicable else None,
                "BHA surface": row.get("bha_surfaces") if pd.notna(row.get("surface_classification")) else None,
                "BHA race code": row.get("bha_race_codes") if pd.notna(row.get("surface_classification")) else None,
                "TT Maps race type code": row.get("tt_maps_race_type_codes") if pd.notna(row.get("surface_classification")) else None,
                "Derived surface": row.get("surface_classification") if pd.notna(row.get("surface_classification")) else None,
                "Derived discipline": row.get("discipline") if pd.notna(row.get("discipline")) else None,
                "Racing type": row.get("bha_race_codes") if pd.notna(row.get("bha_race_codes")) else ("Jump" if str(row.get("tt_maps_race_type_codes")) == "2" else ("Flat" if str(row.get("tt_maps_race_type_codes")) == "4" else None)),
                "Classification source": row.get("classification_source") if (not applicable and pd.notna(row.get("surface_classification"))) else ("Operational review required" if (not applicable and row["course_id"] == 28) else None),
                "Classification status": row.get("classification_status") if (not applicable and row["course_id"] == 28) else None,
                "Stick analysis eligible?": (("Yes" if row.get("stick_analysis_eligible") == True else ("No" if pd.notna(row.get("surface_classification")) else "Unresolved")) if (not applicable and row["course_id"] == 28) else "Not applicable"),
                "Surface reviewer decision": "" if (not applicable and row["course_id"] == 28) else "Not applicable",
                "Surface evidence/notes": "",
                "Calendar date needs update?": "Not applicable" if not applicable else "",
                "Calendar date declare abandoned?": "Not applicable" if not applicable else "",
                "Report race date needs update?": "" if not applicable else "Not applicable",
                "Report race date add to calendar?": "" if not applicable else "Not applicable",
                "Reviewer": "",
                "Review date": "",
                "Review notes": "",
            })
    frame = pd.DataFrame(rows)

    workbook = xlsxwriter.Workbook(WORKBOOK)
    sheet = workbook.add_worksheet("Meeting Date Review")
    sheet.hide_gridlines(2)
    navy = "#20738B"
    orange = "#ED6C29"
    yellow = "#FFF2CC"
    grey = "#F2F2F2"
    white = "#FFFFFF"
    title = workbook.add_format({"bold": True, "font_size": 18, "font_color": white, "bg_color": navy, "align": "left", "valign": "vcenter"})
    subtitle = workbook.add_format({"font_color": white, "bg_color": navy, "italic": True, "valign": "vcenter"})
    instruction = workbook.add_format({"text_wrap": True, "valign": "top", "bg_color": "#EAF3F5", "font_color": "#173B45"})
    header = workbook.add_format({"bold": True, "font_color": white, "bg_color": navy, "text_wrap": True, "border": 1, "align": "center", "valign": "vcenter"})
    body = workbook.add_format({"border": 1, "valign": "top"})
    date_fmt = workbook.add_format({"border": 1, "num_format": "yyyy-mm-dd", "valign": "top"})
    editable = workbook.add_format({"border": 1, "bg_color": yellow, "valign": "top"})
    editable_date = workbook.add_format({"border": 1, "bg_color": yellow, "num_format": "yyyy-mm-dd", "valign": "top"})
    sheet.set_row(0, 30)
    end_col = xl_col_to_name(len(frame.columns) - 1)
    sheet.merge_range(f"A1:{end_col}1", "TurfTrax · DataTrax — JCR Meeting Date and Surface Review", title)
    sheet.merge_range(f"A2:{end_col}2", "Review calendar/report date exceptions and, for Kempton rows, confirm the derived Turf versus AWT classification.", subtitle)
    sheet.merge_range(f"A3:{end_col}3", "Use Yes / No / Unclear for date decisions. For Kempton, review the derived surface and complete Surface reviewer decision and Surface evidence/notes. AWT reports are excluded from Going Stick analysis; unresolved surface rows must not be included until confirmed.", instruction)
    sheet.set_row(2, 42)
    start = 4
    columns = list(frame.columns)
    for col, name in enumerate(columns):
        sheet.write(start, col, name, header)
    for r, record in enumerate(frame.to_dict("records"), start + 1):
        for c, name in enumerate(columns):
            value = record[name]
            if pd.isna(value):
                value = ""
            if name in {"Calendar date", "Report race date", "Latest report updated", "Review date"} and value != "":
                if name == "Latest report updated":
                    value = pd.Timestamp(value).to_pydatetime()
                    fmt = date_fmt
                else:
                    value = pd.Timestamp(value).to_pydatetime()
                    fmt = editable_date if name == "Review date" else date_fmt
            elif name in {"Calendar date needs update?", "Calendar date declare abandoned?", "Report race date needs update?", "Report race date add to calendar?", "Surface reviewer decision", "Surface evidence/notes", "Reviewer", "Review notes"}:
                fmt = editable
            else:
                fmt = body
            sheet.write(r, c, value, fmt)
    last = start + len(frame)
    sheet.autofilter(start, 0, last, len(columns) - 1)
    sheet.freeze_panes(start + 1, 4)
    for c, width in enumerate([18, 34, 10, 18, 13, 18, 34, 13, 13, 12, 14, 20, 24, 16, 18, 24, 32, 23, 14, 14, 22, 18, 24, 18, 18, 18, 28, 28, 28, 16, 14, 44]):
        sheet.set_column(c, c, width)
    decision_columns = [columns.index(name) for name in ["Calendar date needs update?", "Calendar date declare abandoned?", "Report race date needs update?", "Report race date add to calendar?"]]
    for col in decision_columns:
        sheet.data_validation(start + 1, col, last, col, {"validate": "list", "source": ["Yes", "No", "Unclear", "Not applicable"]})
    surface_decision = columns.index("Surface reviewer decision")
    sheet.data_validation(start + 1, surface_decision, last, surface_decision, {"validate": "list", "source": ["Turf/Jump", "Unclear", "Not applicable"]})
    sheet.data_validation(start + 1, columns.index("Review date"), last, columns.index("Review date"), {"validate": "date", "criteria": "between", "minimum": datetime(2020, 1, 1), "maximum": datetime(2035, 12, 31)})
    sheet.conditional_format(start + 1, 0, last, len(columns) - 1, {"type": "formula", "criteria": f'=MOD(ROW(),2)=0', "format": workbook.add_format({"bg_color": "#FAFAFA"})})
    workbook.close()

    report = {
        "created_at_utc": datetime.now(timezone.utc).isoformat(),
        "workbook": str(WORKBOOK),
        "sheet": "Meeting Date Review",
        "calendar_only_rows": int(len(calendar_only)),
        "report_only_rows": int(len(report_only)),
        "total_review_rows": int(len(frame)),
        "decision_fields": [
            "Calendar date needs update?", "Calendar date declare abandoned?",
            "Report race date needs update?", "Report race date add to calendar?",
        ],
        "applicability": "Calendar-only rows use the first two date decisions; report-only rows use the last two date decisions. Confirmed AWT rows are excluded. Remaining Kempton rows expose derived surface evidence and a surface reviewer decision.",
        "excluded_awt_rows": awt_rows,
        "surface_review_rows": int((frame["Surface reviewer decision"] == "").sum()),
        "surface_unresolved_rows": int(((frame["Course ID"] == 28) & (frame["Stick analysis eligible?"] == "Unresolved")).sum()),
        "surface_columns": ["BHA surface", "BHA race code", "TT Maps race type code", "Derived surface", "Derived discipline", "Racing type", "Classification source", "Classification status", "Stick analysis eligible?", "Surface reviewer decision", "Surface evidence/notes"],
    }
    (OUT / "jcr_meeting_date_review_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
