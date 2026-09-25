#!/usr/bin/env python3
"""Assemble public/index.html from the versioned site shell.

Stdlib only. Reads site/template.html and substitutes the <!--TOC--> and
<!--FRAGMENT--> placeholders with the fragment files produced by
scripts/build_site.py. Copies site/style.css and site/app.js next to the
output so the page stays a fully static GitHub Pages artifact.

audit_built_page() / audit_site() inventory the diagrams a generated page
references, so a build that drops a figure or leaves a PDF-only fallback is
rejected before deployment.

Usage:
    python3 scripts/build_site.py -o /tmp/fragment.html --toc /tmp/toc.html
    python3 scripts/assemble_site.py --toc /tmp/toc.html \\
        --fragment /tmp/fragment.html --out public/index.html
"""

from __future__ import annotations

import argparse
import re
import shutil
from html.parser import HTMLParser
from pathlib import Path, PurePosixPath
from typing import NamedTuple

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "site"
TOC_MARKER = "<!--TOC-->"
FRAGMENT_MARKER = "<!--FRAGMENT-->"

# Diagrams rendered by build_site.py live under assets/figs/ and are the only
# SVG the site references; everything else is a copied photo or icon.
FIGURE_DIR = "assets/figs/"
# build_site.py:typst_placeholder() emits this div for any Typst construct it
# cannot express in HTML; its text is "Diagramme - voir la version PDF."
PLACEHOLDER_CLASS = "typst-only"
# Only seances/<seance-NN> wrappers are sessions; contexte.typ renders under
# the "contexte" key and is not a session.
SESSION_KEY_RE = re.compile(r"seance-\d{2}\Z")


class AuditReport(NamedTuple):
    """Image inventory of a generated page, as counted from its markup."""

    svg_count: int
    session_svg_counts: dict[str, int]
    placeholder_count: int


class DiagramAuditParser(HTMLParser):
    """Collect every image reference with its session wrapper, plus placeholders."""

    def __init__(self) -> None:
        super().__init__()
        self.sessions: list[str] = []  # session keys, first-appearance order
        self.images: list[tuple[str | None, str]] = []  # (session key or None, src)
        self.placeholder_count = 0
        self.current: str | None = None
        self.depth = 0  # div nesting inside the active session wrapper

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        classes = (values.get("class") or "").split()
        src = values.get("src")
        if tag == "div" and "bloc-seance" in classes:
            key = values.get("data-seance")
            self.current = key
            if key and key not in self.sessions:
                self.sessions.append(key)
            self.depth = 1
            return
        if self.current is not None and tag == "div":
            # Nested callout/table wrappers keep the active session in scope.
            self.depth += 1
        if tag == "div" and PLACEHOLDER_CLASS in classes:
            self.placeholder_count += 1
        if tag == "img" and src:
            self.images.append((self.current, src))

    def handle_endtag(self, tag: str) -> None:
        if tag != "div" or self.current is None:
            return
        self.depth -= 1
        if self.depth <= 0:
            self.current = None


def _local_path(src: str) -> PurePosixPath | None:
    """Return the site-relative path of a local reference, or None if remote."""
    if "://" in src or src.startswith("//") or src.startswith("data:"):
        return None
    path = PurePosixPath(src)
    if path.is_absolute() or ".." in path.parts:
        raise SystemExit(f"Invalid asset path: {src}")
    return path


def _session_svg_counts(parser: DiagramAuditParser) -> dict[str, int]:
    """Count figure references per session; a session with none still gets a key."""
    counts = {key: 0 for key in parser.sessions if SESSION_KEY_RE.fullmatch(key)}
    for session, src in parser.images:
        if session in counts and src.startswith(FIGURE_DIR):
            counts[session] += 1
    return counts


def _report(page: str) -> tuple[DiagramAuditParser, AuditReport]:
    parser = DiagramAuditParser()
    parser.feed(page)
    report = AuditReport(
        svg_count=sum(1 for _, src in parser.images if src.startswith(FIGURE_DIR)),
        session_svg_counts=_session_svg_counts(parser),
        placeholder_count=parser.placeholder_count,
    )
    return parser, report


def audit_built_page(page: str) -> AuditReport:
    """Inventory the generated fragment before assembly.

    Counts referenced diagrams per session so a build that silently drops a
    diagram (or leaves a PDF-only fallback) is visible in the report. Files are
    not checked here: they do not exist yet.
    """
    return _report(page)[1]


def audit_site(root: Path, page: str) -> AuditReport:
    """Audit an assembled page and fail closed on a missing diagram file."""
    parser, report = _report(page)
    for _, src in parser.images:
        path = _local_path(src)
        if path is None or path.suffix != ".svg":
            continue
        if not (root / path).is_file():
            raise SystemExit(f"Missing SVG reference: {src} (looked under {root})")
    return report


def main() -> None:
    parser = argparse.ArgumentParser(description="Assemble the static site.")
    parser.add_argument("--template", default=str(SITE / "template.html"))
    parser.add_argument("--toc", required=True, help="TOC nav file from build_site.py.")
    parser.add_argument("--fragment", required=True, help="Body fragment from build_site.py.")
    parser.add_argument("--out", required=True, help="Assembled index.html to write.")
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    if TOC_MARKER not in template or FRAGMENT_MARKER not in template:
        raise SystemExit("template.html must contain <!--TOC--> and <!--FRAGMENT--> markers")
    toc = Path(args.toc).read_text(encoding="utf-8").rstrip() + "\n"
    fragment = Path(args.fragment).read_text(encoding="utf-8").rstrip() + "\n"
    page = template.replace(TOC_MARKER, toc).replace(FRAGMENT_MARKER, fragment)

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(page, encoding="utf-8")
    for asset in ("style.css", "app.js", "rapport.html", "rapport-data.json"):
        shutil.copyfile(SITE / asset, out.parent / asset)
    xls = ROOT / "rapport-activite-template.xls"
    if xls.exists():
        shutil.copyfile(xls, out.parent / xls.name)
    print(f"Site assemblé : {out} ({len(page)} caractères)")


if __name__ == "__main__":
    main()
