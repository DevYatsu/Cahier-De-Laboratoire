#!/usr/bin/env python3
"""Structure the rendered Typst HTML into séances and notebook entries.

Stdlib only. scripts/build_site.py turns each Typst source into an HTML
fragment; this module groups those fragments into the units a reader
navigates: the context, the séances (one page each) and their entries
(one per `== ` heading). Each entry carries the status of the rubrics that
README.md requires, so the site can show a progress grid without anyone
maintaining it by hand.
"""

from __future__ import annotations

import html
import re
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

try:
    from scripts import build_site
except ImportError:  # executed as a script from scripts/
    import build_site  # type: ignore[no-redef]

ROOT = build_site.ROOT
SEANCES_DIR = build_site.SEANCES_DIR

HEADING_RE = re.compile(
    r'<h([1-6]) id="([^"]+)" data-seance="[^"]*">'
    r'<span class="num">([^<]*)</span> (.*?) <a class="ancre"[^>]*>¶</a></h\1>',
    re.DOTALL,
)
TAG_RE = re.compile(r"<[^>]+>")
TODO_MARK = "À compléter"

# README.md "Structure d'un travail": the rubrics every entry repeats.
# Déroulement is optional; the other four are expected.
RUBRIQUES: tuple[tuple[str, str, bool], ...] = (
    ("objectifs", "Objectifs", True),
    ("metiers", "Métiers", True),
    ("deroulement", "Déroulement", False),
    ("resultats", "Résultats", True),
    ("interpretation", "Interprétation", True),
)

MOIS = {
    "janvier": 1, "février": 2, "fevrier": 2, "mars": 3, "avril": 4, "mai": 5,
    "juin": 6, "juillet": 7, "août": 8, "aout": 8, "septembre": 9,
    "octobre": 10, "novembre": 11, "décembre": 12, "decembre": 12,
}
SEANCE_TITLE_RE = re.compile(
    r"^Séance du (\d{1,2})(?:er)? (\w+) (\d{4})\s*(?::\s*(.+))?$", re.IGNORECASE
)
ENTRY_TITLE_RE = re.compile(
    r"^(Exercice|Activité|Travail personnel)\s*(\d+)?\s*:\s*(.+)$", re.IGNORECASE
)


def plain_text(fragment: str) -> str:
    """Strip markup and collapse whitespace, for labels, snippets and search."""
    return " ".join(html.unescape(TAG_RE.sub(" ", fragment)).split())


@dataclass
class Heading:
    level: int
    id: str
    num: str
    title_html: str

    @property
    def title(self) -> str:
        return plain_text(self.title_html)


@dataclass
class Entree:
    """One notebook entry: an exercise, an activity, a synthesis..."""

    heading: Heading
    html: str
    source: Path
    modified: str | None = None
    rubriques: dict[str, str] = field(default_factory=dict)  # key -> ok|todo|absent
    rubrique_ids: dict[str, str] = field(default_factory=dict)  # key -> heading id
    sous_titres: list[Heading] = field(default_factory=list)

    @property
    def kind(self) -> str:
        m = ENTRY_TITLE_RE.match(self.heading.title)
        if m:
            return m.group(1).capitalize()
        first = self.heading.title.split()[0] if self.heading.title else ""
        return first if first in ("Synthèse", "Intervention") else "Entrée"

    @property
    def ref(self) -> str | None:
        m = ENTRY_TITLE_RE.match(self.heading.title)
        return m.group(2) if m and m.group(2) else None

    @property
    def name(self) -> str:
        """Title without its "Exercice 3 :" prefix."""
        m = ENTRY_TITLE_RE.match(self.heading.title)
        return m.group(3) if m else self.heading.title

    @property
    def objectif(self) -> str:
        m = re.search(
            r'<aside class="callout callout-objectifs">'
            r'<p class="callout-title">[^<]*</p>(.*?)</aside>',
            self.html,
            re.DOTALL,
        )
        return plain_text(m.group(1)) if m else ""

    @property
    def complete(self) -> bool:
        return all(
            self.rubriques.get(key) == "ok"
            for key, _, required in RUBRIQUES
            if required
        )

    @property
    def todo_count(self) -> int:
        return sum(1 for status in self.rubriques.values() if status == "todo")


@dataclass
class Seance:
    key: str
    heading: Heading
    intro_html: str
    entrees: list[Entree] = field(default_factory=list)
    modified: str | None = None

    @property
    def number(self) -> int:
        return int(self.key.rsplit("-", 1)[1])

    @property
    def slug(self) -> str:
        return f"{self.key}.html"

    @property
    def label(self) -> str:
        return f"Séance {self.number:02d}"

    def _title_match(self) -> re.Match[str] | None:
        return SEANCE_TITLE_RE.match(self.heading.title)

    @property
    def date_label(self) -> str | None:
        m = self._title_match()
        return f"{m.group(1)} {m.group(2)} {m.group(3)}" if m else None

    @property
    def date_iso(self) -> str | None:
        m = self._title_match()
        if not m or m.group(2).lower() not in MOIS:
            return None
        return f"{m.group(3)}-{MOIS[m.group(2).lower()]:02d}-{int(m.group(1)):02d}"

    @property
    def theme(self) -> str | None:
        """Subtitle after the date ("découverte et auto-évaluation")."""
        m = self._title_match()
        return m.group(4).strip() if m and m.group(4) else None

    @property
    def objectifs(self) -> str:
        m = re.search(
            r'<aside class="callout callout-objectifs">'
            r'<p class="callout-title">[^<]*</p>(.*?)</aside>',
            self.intro_html,
            re.DOTALL,
        )
        return plain_text(m.group(1)) if m else ""


@dataclass
class Document:
    contexte_html: str
    seances: list[Seance]

    @property
    def entrees(self) -> list[Entree]:
        return [e for s in self.seances for e in s.entrees]


def headings_in(fragment: str) -> list[tuple[re.Match[str], Heading]]:
    return [
        (m, Heading(int(m.group(1)), m.group(2), m.group(3), m.group(4)))
        for m in HEADING_RE.finditer(fragment)
    ]


def split_on_level(fragment: str, level: int) -> tuple[str, list[tuple[Heading, str]]]:
    """Split a fragment at headings of `level`: (preamble, [(heading, section)])."""
    found = [(m, h) for m, h in headings_in(fragment) if h.level == level]
    if not found:
        return fragment, []
    preamble = fragment[:found[0][0].start()]
    sections: list[tuple[Heading, str]] = []
    for index, (match, heading) in enumerate(found):
        end = found[index + 1][0].start() if index + 1 < len(found) else len(fragment)
        sections.append((heading, fragment[match.start():end]))
    return preamble, sections


def rubrique_key(title: str) -> str | None:
    slug = build_site.slugify(title)
    for prefix, key in (
        ("interpretation", "interpretation"),
        ("resultat", "resultats"),
        ("metier", "metiers"),
        ("deroulement", "deroulement"),
    ):
        if slug.startswith(prefix):
            return key
    return None


def section_status(fragment: str) -> str:
    return "todo" if TODO_MARK in plain_text(fragment) else "ok"


def assess(entree: Entree) -> None:
    """Fill in rubric statuses and the entry's level-3 sub-titles."""
    preamble, sections = split_on_level(entree.html, 3)
    statuses = {key: "absent" for key, _, _ in RUBRIQUES}
    objectifs = re.search(
        r'<aside class="callout callout-objectifs">.*?</aside>', preamble, re.DOTALL
    )
    if objectifs:
        statuses["objectifs"] = section_status(objectifs.group(0))
    for heading, body in sections:
        key = rubrique_key(heading.title)
        if key:
            entree.rubrique_ids.setdefault(key, heading.id)
            # A rubric with nested parts is "todo" if any part still is.
            statuses[key] = "todo" if statuses[key] == "todo" else section_status(body)
    entree.rubriques = statuses
    entree.sous_titres = [h for h, _ in sections]


def git_modified(paths: list[Path]) -> str | None:
    """Last commit date (YYYY-MM-DD) touching `paths`, or None outside git."""
    try:
        proc = subprocess.run(
            ["git", "log", "-1", "--format=%cs", "--", *map(str, paths)],
            cwd=ROOT, capture_output=True, text=True, timeout=20,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    return proc.stdout.strip() or None


def build_document(with_git: bool = True) -> Document:
    contexte: list[str] = []
    seances: dict[str, Seance] = {}
    for path, key, fragment in build_site.render_sources():
        if key == "contexte":
            contexte.append(fragment)
            continue
        preamble, h1s = split_on_level(fragment, 1)
        if h1s:
            heading, body = h1s[0]
            # The h1 tag itself is rendered by the page header, not the body.
            body = body[HEADING_RE.match(body).end():]  # type: ignore[union-attr]
            intro, entries = split_on_level(body, 2)
            seance = Seance(key=key, heading=heading, intro_html=intro.strip())
            seances[key] = seance
        else:
            seance = seances[key]
            intro, entries = split_on_level(fragment, 2)
            if intro.strip():
                target = seance.entrees[-1] if seance.entrees else None
                if target:
                    target.html += intro
                else:
                    seance.intro_html += intro
        for heading, body in entries:
            entree = Entree(heading=heading, html=body, source=path)
            assess(entree)
            seance.entrees.append(entree)
    if with_git:
        for seance in seances.values():
            seance.modified = git_modified([SEANCES_DIR / seance.key])
            for entree in seance.entrees:
                entree.modified = git_modified([entree.source])
    return Document("\n".join(contexte), list(seances.values()))

