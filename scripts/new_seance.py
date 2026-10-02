#!/usr/bin/env python3
"""Scaffold a new séance and register it in main.typ.

Stdlib only. Two source-of-truth rules from the README are enforced here: the
next number is derived from the seances/ directory (never a counter in this
script), and the include order in main.typ follows the numeric order of the
séance directories, so the new #include lands after the last one present.

The generated index.typ is a stub: it holds the template import, the
#pagebreak() every séance entry point needs, and the dated heading. Body
subsections are added later with scripts/new_activite.py as NN-slug.typ files
included from there, the same way seance-01 and seance-02 are structured.

--dry-run prints the plan without touching the repo. A re-run does not
duplicate: the number comes from the seances/ directory, so it always moves on
to the next free one.

Usage:
    python3 scripts/new_seance.py
    python3 scripts/new_seance.py --date 2026-10-02 --title "Analyse de vulnérabilités"
    python3 scripts/new_seance.py --dry-run
"""

from __future__ import annotations

import argparse
import sys
from datetime import date
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
from seance_repo import (  # noqa: E402
    MAIN,
    SEANCES_DIR,
    SeanceError,
    existing_seances,
    register_include,
)

MONTHS_FR = (
    "janvier", "février", "mars", "avril", "mai", "juin",
    "juillet", "août", "septembre", "octobre", "novembre", "décembre",
)

INDEX_TEMPLATE = """\
// Séance {number} - point d'entrée. Le contenu sera réparti dans des
// sous-documents, inclus ci-dessous dans l'ordre de la séance.
#import "/template.typ": *

#pagebreak()
= Séance du {date_fr}{title_suffix}
"""


def next_seance_number(seances_dir: Path = SEANCES_DIR) -> int:
    """Return one past the highest existing séance number (1 when empty)."""
    existing = existing_seances(seances_dir)
    return max(existing) + 1 if existing else 1


def format_date_fr(when: date) -> str:
    """Format a date the way séance headings read it: '2 octobre 2026'."""
    return f"{when.day} {MONTHS_FR[when.month - 1]} {when.year}"


def render_index(number: int, when: date, title: str | None) -> str:
    """Build the index.typ stub for a séance."""
    # seance-01 spells the theme after a colon; a titleless séance stays bare.
    suffix = f" : {title}" if title else ""
    return INDEX_TEMPLATE.format(number=f"{number:02d}",
                                 date_fr=format_date_fr(when),
                                 title_suffix=suffix)


def scaffold(when: date, title: str | None, dry_run: bool = False) -> Path:
    """Create seances/seance-NN/index.typ and register it in main.typ."""
    number = next_seance_number()
    folder = SEANCES_DIR / f"seance-{number:02d}"
    index = folder / "index.typ"
    relative = f"seances/seance-{number:02d}/index.typ"

    if index.exists():
        raise SeanceError(f"{index} existe déjà")

    # Read both targets before writing either: a refused include must not leave
    # an orphan folder behind.
    updated_main = register_include(MAIN.read_text(encoding="utf-8"), relative,
                                   anchor_prefix="seances/")

    if not dry_run:
        folder.mkdir(parents=True, exist_ok=False)
        index.write_text(render_index(number, when, title), encoding="utf-8")
        MAIN.write_text(updated_main, encoding="utf-8")

    print(f"seance-{number:02d} -> {relative}")
    if not dry_run:
        print(f"créé {index.relative_to(MAIN.parent)}")
        print(f"enregistré #include dans {MAIN.name}")
    return index


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Initialise une nouvelle séance et l'ajoute à main.typ.")
    parser.add_argument("--date", type=date.fromisoformat, default=date.today(),
                        help="date de la séance, format AAAA-MM-JJ (défaut: aujourd'hui)")
    parser.add_argument("--title", help="thème de la séance, ajouté après le titre")
    parser.add_argument("--dry-run", action="store_true",
                        help="affiche le plan sans modifier le dépôt")
    args = parser.parse_args(argv)

    try:
        scaffold(args.date, args.title, args.dry_run)
    except SeanceError as error:
        print(f"erreur: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
