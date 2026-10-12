#!/usr/bin/env python3
"""Assemble the static multi-page site under public/.

Stdlib only. Builds the structured document (scripts/site_model.py), renders
one page per séance plus the home, tracking-grid, report and 404 pages
(scripts/site_pages.py), and copies the static assets next to them so the
output stays a fully static GitHub Pages artifact.

audit_built_page() / audit_site() inventory the diagrams a generated page
references, so a build that drops a figure or leaves a PDF-only fallback is
rejected before deployment.

Usage:
    python3 -m scripts.assemble_site --out public
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
from html.parser import HTMLParser
from pathlib import Path, PurePosixPath
from typing import NamedTuple

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "site"

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


def audit_pages(root: Path) -> AuditReport:
    """Audit every generated page of a multi-page site as one document."""
    pages = sorted(root.glob("*.html"))
    if not pages:
        raise SystemExit(f"No HTML page under {root}")
    return audit_site(root, "\n".join(p.read_text(encoding="utf-8") for p in pages))


def copy_seance_assets(out: Path) -> int:
    """seances/<seance-NN>/assets/* -> <out>/assets/<seance-NN>/*.

    build_site.asset_src() rewrites image paths to this layout.
    """
    copied = 0
    for source in sorted((ROOT / "seances").glob("seance-*/assets")):
        target = out / "assets" / source.parent.name
        shutil.copytree(source, target, dirs_exist_ok=True)
        copied += sum(1 for p in source.rglob("*") if p.is_file())
    return copied


def figure_count(page: str) -> int:
    return _report(page)[1].svg_count


def main() -> None:
    parser = argparse.ArgumentParser(description="Assemble the static multi-page site.")
    parser.add_argument("--out", default=str(ROOT / "public"), help="Output directory.")
    parser.add_argument("--no-git", action="store_true",
                        help="Skip per-entry modification dates (no git history).")
    args = parser.parse_args()

    # Imported here so the audit helpers stay usable without the page renderer.
    try:
        from scripts import site_model, site_pages
    except ImportError:  # executed as a script from scripts/
        import site_model, site_pages  # type: ignore[no-redef]

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    doc = site_model.build_document(with_git=not args.no_git)
    meta = site_pages.build_meta()

    rapport_json = SITE / "rapport-data.json"
    total_heures = None
    if rapport_json.exists():
        total = json.loads(rapport_json.read_text(encoding="utf-8")).get("total_heures")
        total_heures = total if isinstance(total, (int, float)) and total > 0 else None
    figures = figure_count("\n".join(e.html for e in doc.entrees))

    pages = {"index.html": site_pages.page_index(doc, meta, total_heures, figures),
             "suivi.html": site_pages.page_suivi(doc, meta),
             "rapport.html": site_pages.page_rapport(doc, meta),
             "404.html": site_pages.page_404(doc, meta)}
    for index, seance in enumerate(doc.seances):
        pages[seance.slug] = site_pages.page_seance(doc, meta, index)
    for name, page in pages.items():
        (out / name).write_text(page, encoding="utf-8")
    (out / "search-index.json").write_text(
        json.dumps(site_pages.search_index(doc), ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    for asset in ("style.css", "app.js", "rapport.js"):
        shutil.copyfile(SITE / asset, out / asset)
    if rapport_json.exists():
        shutil.copyfile(rapport_json, out / rapport_json.name)
    xls = ROOT / "rapport-activite-template.xls"
    if xls.exists():
        shutil.copyfile(xls, out / xls.name)
    photos = copy_seance_assets(out)
    print(f"Site assemblé : {out} ({len(pages)} pages, {len(doc.seances)} séances, "
          f"{len(doc.entrees)} entrées, {figures} figures, {photos} photos)")


if __name__ == "__main__":
    main()
