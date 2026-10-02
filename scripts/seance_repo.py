#!/usr/bin/env python3
"""Shared Typst-repo primitives for the scaffolding scripts.

Both new_seance.py and new_activite.py mutate this repository's Typst
sources, and both need the same three rules from the README: a séance is a
seance-NN directory, a work is an NN-slug.typ file inside it, and the
include order is the numeric order of those names. Those rules live here
once so the two CLIs cannot drift apart, which is what would silently
reorder a document.

Stdlib only.
"""

from __future__ import annotations

import re
import unicodedata
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parent.parent
SEANCES_DIR = ROOT / "seances"
MAIN = ROOT / "main.typ"

# Zero-padded ordinals (seance-01, 04-analyse-risque.typ) so lexical order in an
# editor matches the numeric order Typst renders in.
SEANCE_DIR_RE = re.compile(r"seance-(\d+)\Z")
ORDINAL_FILE_RE = re.compile(r"(?P<ordinal>\d+)-(?P<slug>.+)\.typ\Z")
INCLUDE_RE = re.compile(r'^\s*#include\s+"(?P<path>[^"]+)"\s*$')


class SeanceError(RuntimeError):
    """A scaffold request that cannot be satisfied without guessing."""


def ordinal_name(number: int, slug: str) -> str:
    """Return the NN-slug.typ filename for an activity number and slug."""
    return f"{number:02d}-{slug}.typ"


def existing_seances(seances_dir: Path = SEANCES_DIR) -> dict[int, Path]:
    """Return {number: directory} for every seance-NN directory present."""
    if not seances_dir.is_dir():
        return {}
    found: dict[int, Path] = {}
    for child in sorted(seances_dir.iterdir()):
        match = SEANCE_DIR_RE.fullmatch(child.name)
        if match and child.is_dir():
            found[int(match.group(1))] = child
    return found


def resolve_seance(reference: str | None, seances_dir: Path = SEANCES_DIR) -> tuple[int, Path]:
    """Resolve a séance reference to (number, directory).

    Accepts None (latest séance), "3", "03", "seance-03" or "seance-3", so the
    CLI is forgiving about the form while still refusing an unknown séance.
    """
    existing = existing_seances(seances_dir)
    if not existing:
        raise SeanceError(f"aucune séance dans {seances_dir}")
    if reference is None:
        number = max(existing)
        return number, existing[number]

    digits = re.fullmatch(r"(?:seance-)?0*(\d+)", reference.strip(), flags=re.IGNORECASE)
    if not digits:
        raise SeanceError(f"séance illisible: {reference!r} (attendu 03 ou seance-03)")
    number = int(digits.group(1))
    if number not in existing:
        raise SeanceError(f"séance inconnue: seance-{number:02d}")
    return number, existing[number]


def next_ordinal(folder: Path, pattern: re.Pattern[str] = ORDINAL_FILE_RE) -> int:
    """Return one past the highest ordinal already used in folder."""
    numbers = [
        int(match.group("ordinal"))
        for child in folder.iterdir()
        if (match := pattern.fullmatch(child.name))
    ]
    return max(numbers) + 1 if numbers else 1


def _includes(text: str):
    """Yield (line_offset, path) for every #include line in text."""
    for offset, line in enumerate(text.splitlines()):
        if match := INCLUDE_RE.match(line):
            yield offset, match.group("path")


def register_include(text: str, relative_path: str, anchor_prefix: str = "") -> str:
    """Return text with `#include relative_path` added after the last include.

    anchor_prefix restricts which includes may act as the insertion anchor, so
    main.typ keeps its seances/ block contiguous while an index.typ anchors on
    its own. Appends at end of file when no anchor matches.

    Raises SeanceError if relative_path is already included: a duplicate
    include would print the same content twice.
    """
    lines = text.splitlines()
    includes = list(_includes(text))
    if any(path == relative_path for _, path in includes):
        raise SeanceError(f"include déjà présent: {relative_path}")

    anchor = -1
    for offset, path in includes:
        if PurePosixPath(path).as_posix().startswith(anchor_prefix):
            anchor = offset
    lines.insert(anchor + 1 if anchor >= 0 else len(lines), f'#include "{relative_path}"')

    # splitlines() drops the original trailing newline; restore one exactly.
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")


def slugify(title: str) -> str:
    """Turn a heading into an ASCII slug, the shape the NN-slug.typ names use.

    Keeps the digits and drops accents so the filename survives copy/paste and
    non-ASCII filesystems. Existing files use hand-shortened slugs, so callers
    should expose an explicit override.
    """
    decomposed = unicodedata.normalize("NFKD", title)
    stripped = "".join(ch for ch in decomposed if not unicodedata.combining(ch))
    ascii_only = stripped.encode("ascii", "ignore").decode("ascii").lower()
    return re.sub(r"[^a-z0-9]+", "-", ascii_only).strip("-")
