#!/usr/bin/env python3
"""Scaffold a new activity (travail) in a séance and include it from index.typ.

Stdlib only. Creates seances/seance-NN/MM-slug.typ holding the squelette de
titres the README fixes for every work, then appends the matching #include to
that séance's index.typ. The filename ordinal is the only ordering source, so
the include is always appended last and renders in ascending NN order.

--seance selects the target (03, 3 or seance-03); it defaults to the highest
numbered séance, which is the one being written during the semester. The slug
defaults to the title, but existing files use hand-shortened names
(05-facteur-humain-biais-cognitifs.typ), so pass --slug to match that style.

"Déroulement" is deliberately absent: the README makes it optional and
conditional on raw material, so it is added by hand when there is a journal to
keep.

--dry-run prints the plan without touching the repo. Since the ordinal always
advances, a re-run would otherwise produce a second file carrying the same
slug (01-x.typ then 02-x.typ); that is refused and the existing file is named.

Usage:
    python3 scripts/new_activite.py --title "Activité 5 : Cartographie des menaces"
    python3 scripts/new_activite.py --seance 02 --title "Analyse de risque"
    python3 scripts/new_activite.py --title "..." --slug analyse-risque --dry-run
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
from seance_repo import (  # noqa: E402
    ORDINAL_FILE_RE,
    SeanceError,
    next_ordinal,
    ordinal_name,
    register_include,
    resolve_seance,
    slugify,
)

ACTIVITY_TEMPLATE = """\
// {title} - squelette de travail, à compléter.
#import "/template.typ": *

== {title}

#encadre("Objectifs")[À compléter.]

=== Métiers pertinents

À compléter.

=== Résultats

À compléter.

=== Interprétation des résultats

À compléter.
"""


def render_activity(title: str) -> str:
    """Build the NN-slug.typ stub for an activity."""
    return ACTIVITY_TEMPLATE.format(title=title)


def scaffold(title: str, seance_ref: str | None = None,
             slug: str | None = None, dry_run: bool = False) -> Path:
    """Create MM-slug.typ in the target séance and register it in index.typ."""
    number_seance, folder = resolve_seance(seance_ref)
    index = folder / "index.typ"
    if not index.is_file():
        raise SeanceError(f"index de séance manquant: {index}")

    final_slug = slugify(slug) if slug else slugify(title)
    if not final_slug:
        raise SeanceError(f"slug vide après normalisation: {title!r}")

    ordinal = next_ordinal(folder)
    filename = ordinal_name(ordinal, final_slug)
    target = folder / filename
    # next_ordinal always yields a free number, so a repeated run would not
    # collide on the filename but would silently add a same-slug twin; that is
    # the collision worth refusing.
    twins = sorted(
        child.name for child in folder.iterdir()
        if (match := ORDINAL_FILE_RE.fullmatch(child.name))
        and match.group("slug") == final_slug
    )
    if twins:
        raise SeanceError(
            f"slug déjà utilisé dans seance-{number_seance:02d}: {', '.join(twins)}"
        )

    # Read before writing: a refused include must not leave an orphan file.
    updated_index = register_include(index.read_text(encoding="utf-8"), filename)

    if not dry_run:
        target.write_text(render_activity(title), encoding="utf-8")
        index.write_text(updated_index, encoding="utf-8")

    print(f"seance-{number_seance:02d}/{filename}")
    if not dry_run:
        print(f"créé {target}")
        print(f"enregistré #include dans {index.relative_to(index.parent.parent.parent)}")
    return target


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Initialise une nouvelle activité dans une séance.")
    parser.add_argument("--title", required=True,
                        help="titre du travail, utilisé comme titre de niveau 2")
    parser.add_argument("--seance", help="séance cible (03, 3, seance-03; défaut: la plus récente)")
    parser.add_argument("--slug", help="nom de fichier court (défaut: dérivé du titre)")
    parser.add_argument("--dry-run", action="store_true",
                        help="affiche le plan sans modifier le dépôt")
    args = parser.parse_args(argv)

    try:
        scaffold(args.title, args.seance, args.slug, args.dry_run)
    except SeanceError as error:
        print(f"erreur: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
