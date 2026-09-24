#!/usr/bin/env python3
"""Regenerate site/rapport-data.json from rapport-activite-template.xls.

Stdlib only, except for one optional dependency: xlrd (needed to read the
legacy .xls format). If xlrd is missing, the script exits with a clear hint
instead of failing obscurely.

Usage:
    /tmp/xlsvenv/bin/python scripts/export_rapport.py
    python3 scripts/export_rapport.py --xls rapport-activite-template.xls \\
        --out site/rapport-data.json

The JSON mirrors the SUMMARY sheet layout (title rows, module/ECTS rows,
activity rows, TOTAL, footnote). The static site does not parse .xls at runtime,
so CI stays dependency-free.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def read_summary(xls_path: Path) -> dict:
    try:
        import xlrd  # type: ignore
    except ImportError:
        raise SystemExit(
            "xlrd is required to read the .xls file "
            "(e.g. /tmp/xlsvenv/bin/python scripts/export_rapport.py)."
        )
    book = xlrd.open_workbook(str(xls_path))
    try:
        sheet = book.sheet_by_name("SUMMARY")
    except Exception:
        sheet = book.sheet_by_index(0)

    def cell(r: int, c: int):
        if r < 0 or r >= sheet.nrows or c < 0 or c >= sheet.ncols:
            return ""
        return sheet.cell_value(r, c)

    def num(value) -> float | None:
        try:
            return float(value)
        except (TypeError, ValueError):
            return None

    modules = [
        {"code": str(cell(3, 3)), "ects": num(cell(3, 4)), "periodes": num(cell(3, 5))},
        {"code": str(int(cell(4, 3))) if isinstance(cell(4, 3), float) else str(cell(4, 3)),
         "ects": num(cell(4, 4)), "periodes": num(cell(4, 5))},
        {"code": str(cell(5, 3)), "ects": num(cell(5, 4)), "periodes": num(cell(5, 5))},
    ]
    activities = []
    r = 8
    while True:
        module, cat, desc, heures = cell(r, 0), cell(r, 1), cell(r, 2), cell(r, 5)
        if not str(module or desc).strip():
            break
        activities.append({
            "module": str(module),
            "categorie": str(cat),
            "description": str(desc),
            "heures": num(heures),
            "exemple": False,
        })
        r += 1
        if r > 40:  # safety bound for the legacy activity table
            break

    total = num(cell(49, 5))
    return {
        "source": xls_path.name,
        "sheet": sheet.name,
        "title": str(cell(0, 0)),
        "title_module": str(cell(0, 3)),
        "student": str(cell(1, 1)),
        "period": str(cell(1, 3)),
        "modules": modules,
        "note_exemples": " ".join(
            str(cell(7, 8)).split()) if cell(7, 8) else "",
        "activities": activities,
        "total_heures": total,
        "footnote": str(cell(52, 0)),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Export rapport data to JSON.")
    parser.add_argument("--xls", default=str(ROOT / "rapport-activite-template.xls"))
    parser.add_argument("--out", default=str(ROOT / "site" / "rapport-data.json"))
    args = parser.parse_args()

    data = read_summary(Path(args.xls))
    out = Path(args.out)
    out.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                   encoding="utf-8")
    print(f"Rapport exporté : {out} "
          f"({len(data['activities'])} activités, total {data['total_heures']})")


if __name__ == "__main__":
    main()
