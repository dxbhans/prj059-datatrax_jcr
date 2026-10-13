"""Run the Phase 1 refresh pipeline and record progress and outcomes.

Run from the repository root with::

    .venv/bin/python -m datatrax_jcr.refresh_phase1

The default mode attempts every step so that one unavailable external source
does not hide the status of the remaining local rebuilds. Use --stop-on-error
for fail-fast behaviour.
"""

from __future__ import annotations

import argparse
import json
import logging
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "data" / "config"
LOG_PATH = OUT / "jcr_refresh_progress.log"
REPORT_PATH = OUT / "jcr_refresh_report.json"


STEPS = [
    ("course_scope", ["-m", "datatrax_jcr.phase1_scope"]),
    ("going_report_cache", ["-m", "datatrax_jcr.import_going_reports"]),
    ("tt_maps_meeting_status", ["-m", "datatrax_jcr.meeting_status"]),
    ("bha_calendar_comparison", ["-m", "datatrax_jcr.bha_calendar"]),
    ("going_report_stats", ["-m", "datatrax_jcr.going_report_stats"]),
    ("import_stick_readings", ["-m", "datatrax_jcr.import_stick_readings"]),
    ("going_report_stats_meeting_level", ["-m", "datatrax_jcr.going_report_stats_report_level"]),
    ("going_report_course_year_table", ["-m", "datatrax_jcr.build_going_report_course_year_table"]),
    ("apply_map_review", ["-m", "datatrax_jcr.apply_map_review"]),
    ("svg_import", ["-m", "datatrax_jcr.svg_import"]),
    ("map_resolution", ["-m", "datatrax_jcr.map_resolution"]),
    ("meeting_date_review", ["-m", "datatrax_jcr.build_meeting_date_review"]),
    ("kempton_surface", ["-m", "datatrax_jcr.kempton_surface"]),
    ("bhagi_compliance", ["-m", "datatrax_jcr.bhagi_compliance"]),
    ("enrich_stick_readings", ["-m", "datatrax_jcr.enrich_stick_readings"]),
    ("phase1_report_tables", ["-m", "datatrax_jcr.build_phase1_report_tables"]),
    ("validate_phase1", ["-m", "datatrax_jcr.validate_phase1"]),
    ("build_package", ["-m", "datatrax_jcr.build_package"]),
    ("render_phase1_document", ["quarto", "render", "phases/phase-01-jcr-configuration.qmd"]),
]


def configure_logging() -> logging.Logger:
    OUT.mkdir(parents=True, exist_ok=True)
    logger = logging.getLogger("datatrax_jcr.refresh_phase1")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s", "%Y-%m-%dT%H:%M:%S%z")
    stream = logging.StreamHandler(sys.stdout)
    stream.setFormatter(formatter)
    file_handler = logging.FileHandler(LOG_PATH, mode="w", encoding="utf-8")
    file_handler.setFormatter(formatter)
    logger.addHandler(stream)
    logger.addHandler(file_handler)
    return logger


def run_step(name: str, command: list[str], logger: logging.Logger) -> dict:
    started = datetime.now(timezone.utc)
    start_clock = time.monotonic()
    executable = [sys.executable, *command] if command and command[0] == "-m" else command
    display = " ".join(executable)
    logger.info("START %s: %s", name, display)
    try:
        completed = subprocess.run(
            executable,
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=False,
        )
        output = completed.stdout or ""
        if output:
            for line in output.rstrip().splitlines():
                logger.info("[%s] %s", name, line)
        status = "passed" if completed.returncode == 0 else "failed"
        result = {
            "name": name,
            "command": command,
            "status": status,
            "returncode": completed.returncode,
            "started_at_utc": started.isoformat(),
            "finished_at_utc": datetime.now(timezone.utc).isoformat(),
            "duration_seconds": round(time.monotonic() - start_clock, 3),
            "output_tail": output.rstrip().splitlines()[-20:],
        }
        logger.info("END %s: %s (return code %s)", name, status, completed.returncode)
        return result
    except OSError as exc:
        result = {
            "name": name,
            "command": command,
            "status": "failed",
            "returncode": None,
            "started_at_utc": started.isoformat(),
            "finished_at_utc": datetime.now(timezone.utc).isoformat(),
            "duration_seconds": round(time.monotonic() - start_clock, 3),
            "output_tail": [f"Could not start command: {exc}"],
        }
        logger.exception("END %s: could not start command", name)
        return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Refresh and report the Phase 1 JCR cache pipeline.")
    parser.add_argument(
        "--stop-on-error",
        action="store_true",
        help="stop after the first failed step; default is to attempt every step",
    )
    args = parser.parse_args()

    logger = configure_logging()
    started = datetime.now(timezone.utc)
    logger.info("Phase 1 refresh started in %s", ROOT)
    results = []
    for name, command in STEPS:
        result = run_step(name, command, logger)
        results.append(result)
        if args.stop_on_error and result["status"] != "passed":
            logger.error("Stopping after failed step because --stop-on-error was supplied")
            break

    passed = sum(result["status"] == "passed" for result in results)
    failed = sum(result["status"] == "failed" for result in results)
    report = {
        "pipeline": "jcr_phase1_refresh",
        "started_at_utc": started.isoformat(),
        "finished_at_utc": datetime.now(timezone.utc).isoformat(),
        "repository_root": str(ROOT),
        "log_file": str(LOG_PATH),
        "steps_attempted": len(results),
        "steps_defined": len(STEPS),
        "passed": passed,
        "failed": failed,
        "status": "passed" if failed == 0 else "failed",
        "results": results,
    }
    REPORT_PATH.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    logger.info("Refresh complete: %s passed, %s failed", passed, failed)
    logger.info("Progress log: %s", LOG_PATH)
    logger.info("Refresh report: %s", REPORT_PATH)
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
