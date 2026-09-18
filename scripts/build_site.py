#!/usr/bin/env python3
"""Build a clean semantic HTML fragment from the Typst sources.

Stdlib only. Parses the Typst files in #include order (from main.typ)
and emits headings, paragraphs, lists, tables and showybox callouts.
Skips Typst-only directives, the cover page and the Sommaire section
(a fresh TOC is generated from the actual headings instead).

Usage:
    python3 scripts/build_site.py            # prints fragment to stdout
    python3 scripts/build_site.py -o out.html  # writes fragment to file
"""

from __future__ import annotations

import argparse
import html
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

SKIP_PREFIXES = (
    "#import", "#set", "#show", "#let", "#pagebreak", "#outline",
    "#align", "#grid", "#box", "#block", "#v(", "#v[", "#line(",
    "#text(", "#counter", "#datetime", "#hydra", "#codly", "#figure",
    "#image", "#table.cell", "#page(", "#context", "#footnote",
)

HEADING_RE = re.compile(r"^(=+)\s+(.*?)\s*$")
INCLUDE_RE = re.compile(r'#include\s+"([^"]+)"')
SHOWYBOX_TITLE_RE = re.compile(r'title:\s*"([^"]+)"')
TABLE_COLUMNS_RE = re.compile(r"columns:\s*\(([^)]*)\)")
STRONG_RE = re.compile(r"\*([^*]+?)\*")
CODE_RE = re.compile(r"`([^`]+?)`")
LINK_RE = re.compile(r'#link\("([^"]+)"\)\[([^\]]+?)\]')
LINK_BARE_RE = re.compile(r'#link\("([^"]+)"\)')


def slugify(text: str) -> str:
    plain = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    slug = re.sub(r"[^a-z0-9]+", "-", plain.lower()).strip("-")
    return slug or "section"


# Heading slugs repeat across séances ("métiers pertinents", "résultats").
# Registry keeps ids unique so anchors and scroll-spy land on the right heading.
_SLUG_COUNTS: dict[str, int] = {}


def unique_slug(text: str) -> str:
    base = slugify(text)
    count = _SLUG_COUNTS.get(base, 0)
    _SLUG_COUNTS[base] = count + 1
    return base if count == 0 else f"{base}-{count + 1}"


def inline_markup(text: str) -> str:
    """Convert #link(url)[label], *bold* and `code` to HTML, escaping the rest."""
    # Extract links first so escaping + bold parsing don't touch them.
    links: list[str] = []

    def take_link(m: re.Match[str]) -> str:
        url = m.group(1).strip()
        label = m.group(2).strip()
        # Label may itself contain *bold* / `code`.
        label_html = inline_markup(label)
        links.append(f'<a href="{html.escape(url, quote=True)}">{label_html}</a>')
        return f"\x00LINK{len(links) - 1}\x00"

    text = LINK_RE.sub(take_link, text)

    def take_bare(m: re.Match[str]) -> str:
        url = m.group(1).strip()
        links.append(f'<a href="{html.escape(url, quote=True)}">{html.escape(url)}</a>')
        return f"\x00LINK{len(links) - 1}\x00"

    text = LINK_BARE_RE.sub(take_bare, text)

    parts: list[str] = []
    # Split on code spans first so * inside code is untouched.
    for i, chunk in enumerate(CODE_RE.split(text)):
        if i % 2 == 1:
            parts.append("<code>" + html.escape(chunk) + "</code>")
        else:
            escaped = html.escape(chunk)
            escaped = STRONG_RE.sub(r"<strong>\1</strong>", escaped)
            parts.append(escaped)
    out = "".join(parts)
    for idx, link_html in enumerate(links):
        out = out.replace(f"\x00LINK{idx}\x00", link_html)
    return out


def balanced_block(lines: list[str], start: int, opener: str, closer: str) -> tuple[str, int]:
    """Accumulate lines from `start` until opener/closer balance returns to 0."""
    depth = 0
    seen = False
    collected: list[str] = []
    i = start
    while i < len(lines):
        line = lines[i]
        if opener in line:
            seen = True
        depth += line.count(opener) - line.count(closer)
        collected.append(line)
        i += 1
        if seen and depth <= 0:
            break
    return "\n".join(collected), i


def split_top_level_cells(body: str) -> list[str]:
    """Split a #table(...) inner body into top-level [...] cells."""
    cells: list[str] = []
    depth = 0
    current: list[str] = []
    in_cell = False
    for ch in body:
        if ch == "[":
            if depth == 0:
                in_cell = True
                current = []
            else:
                current.append(ch)
            depth += 1
        elif ch == "]":
            depth -= 1
            if depth == 0 and in_cell:
                cells.append("".join(current).strip())
                in_cell = False
            else:
                current.append(ch)
        elif in_cell:
            current.append(ch)
    return cells


def parse_table(block: str) -> str:
    m = TABLE_COLUMNS_RE.search(block)
    ncols = len([c for c in m.group(1).split(",") if c.strip()]) if m else 0
    # Drop the columns:/align: params, keep only the [...] cells.
    body = TABLE_COLUMNS_RE.sub("", block)
    body = re.sub(r"align:\s*\([^)]*\)", "", body)
    cells = split_top_level_cells(body)
    if not cells:
        return ""
    if ncols <= 0:
        ncols = 2
    rows = [cells[i:i + ncols] for i in range(0, len(cells), ncols)]
    # First row is the header when every cell carries *bold* markup.
    header = rows[0] if rows and all("*" in c for c in rows[0]) else None
    data = rows[1:] if header else rows

    def cell_text(cell: str) -> str:
        # Header cells look like *Thème* -> strip stars, body keeps markup.
        inner = cell.strip()
        if inner.startswith("*") and inner.endswith("*") and len(inner) > 2:
            inner = inner[1:-1]
        return inline_markup(inner)

    out = ['<div class="table-scroll" tabindex="0" role="region" '
           'aria-label="Tableau à défilement horizontal">', "<table>"]
    if header:
        out.append("<thead><tr>" + "".join(f"<th scope=\"col\">{cell_text(c)}</th>" for c in header) + "</tr></thead>")
    out.append("<tbody>")
    for row in data:
        out.append("<tr>" + "".join(f"<td>{cell_text(c)}</td>" for c in row) + "</tr>")
    out.append("</tbody></table></div>")
    return "\n".join(out)


def callout_class(title: str) -> str:
    low = title.lower()
    if "objectif" in low:
        return "callout callout-objectifs"
    if "interpr" in low:
        return "callout callout-interpretation"
    if "résultat" in low or "resultat" in low:
        return "callout callout-resultats"
    return "callout"


def parse_showybox(block: str) -> str:
    m = SHOWYBOX_TITLE_RE.search(block)
    title = m.group(1) if m else "À noter"
    # Body is the [...] group that follows the final closing paren.
    mbody = re.search(r"\)\s*\[(.*)\]\s*$", block, flags=re.DOTALL)
    body = mbody.group(1) if mbody else ""
    body_lines = [ln for ln in body.splitlines()]
    inner = render_blocks(body_lines)
    return (f'<aside class="{callout_class(title)}">'
            f'<p class="callout-title">{html.escape(title)}</p>\n{inner}\n</aside>')


ENCADRE_TITLE_RE = re.compile(r'^#encadre\(\s*"([^"]+)"\s*\)')


def parse_encadre(block: str) -> str:
    m = ENCADRE_TITLE_RE.match(block)
    title = m.group(1) if m else "À noter"
    # Body is the final [...] group following the title parens.
    mbody = re.search(r"\)\s*\[(.*)\]\s*$", block, flags=re.DOTALL)
    body = mbody.group(1) if mbody else ""
    inner = render_blocks(body.splitlines())
    return (f'<aside class="{callout_class(title)}">'
            f'<p class="callout-title">{html.escape(title)}</p>\n{inner}\n</aside>')


def is_skippable(line: str) -> bool:
    s = line.strip()
    if not s or s.startswith("//"):
        return True
    if s.startswith("#"):
        return s.startswith(SKIP_PREFIXES)
    # Bare Typst closings / punctuation leftovers.
    if s in ("]", ")", "),", "],", "[", "("):
        return True
    return False


def render_list(items: list[tuple[int, str]]) -> str:
    """Render (indent, text) bullet items with 2-space nesting."""
    out: list[str] = []
    depth = -1  # current open <ul> depth (0-based)
    for indent, text in items:
        level = indent // 2
        if level > depth:
            while depth < level:
                out.append("<ul>")
                depth += 1
            out.append(f"<li>{inline_markup(text)}")
        elif level == depth:
            out.append(f"</li>\n<li>{inline_markup(text)}")
        else:
            while depth > level:
                out.append("</li>\n</ul>")
                depth -= 1
            out.append(f"</li>\n<li>{inline_markup(text)}")
    while depth >= 0:
        out.append("</li>\n</ul>")
        depth -= 1
    return "\n".join(out)


def render_blocks(raw_lines: list[str]) -> str:
    lines = [ln.rstrip() for ln in raw_lines]
    out: list[str] = []
    headings: list[tuple[int, str, str]] = []  # collected globally elsewhere
    i = 0
    para: list[str] = []
    list_items: list[tuple[int, str]] = []

    def flush_para() -> None:
        if para:
            out.append(f"<p>{inline_markup(' '.join(para))}</p>")
            para.clear()

    def flush_list() -> None:
        if list_items:
            out.append(render_list(list_items))
            list_items.clear()

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if not stripped or stripped.startswith("//"):
            flush_para()
            flush_list()
            i += 1
            continue

        if stripped.startswith("#showybox"):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "[", "]")
            out.append(parse_showybox(block))
            continue

        if stripped.startswith("#encadre("):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "[", "]")
            out.append(parse_encadre(block))
            continue

        if stripped.startswith("#table("):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "(", ")")
            out.append(parse_table(block))
            continue

        if stripped.startswith("#"):
            if is_skippable(stripped):
                i += 1
                continue
            # Unknown directive: skip the line rather than leaking it.
            i += 1
            continue

        m = HEADING_RE.match(stripped)
        if m:
            flush_para()
            flush_list()
            level = min(len(m.group(1)), 3)
            text = m.group(2)
            hid = unique_slug(re.sub(r"\*", "", text))
            # Split leading numbering ("1.2 ") for the red accent span.
            num_m = re.match(r"^(\d+(?:\.\d+)*\.?)\s+(.*)$", text)
            if num_m:
                title_html = (f'<span class="num">{html.escape(num_m.group(1))}</span> '
                              f'{inline_markup(num_m.group(2))}')
            else:
                title_html = inline_markup(text)
            tag = f"h{level}"
            out.append(f'<{tag} id="{hid}">{title_html} '
                       f'<a class="ancre" href="#{hid}" aria-label="Lien vers cette section">¶</a></{tag}>')
            headings.append((level, hid, re.sub(r"\*", "", text)))
            i += 1
            continue

        bullet = re.match(r"^(\s*)-\s+(.*)$", line)
        if bullet:
            flush_para()
            indent = len(bullet.group(1).replace("\t", "  "))
            list_items.append((indent, bullet.group(2).strip()))
            i += 1
            continue

        if list_items and (line.startswith("  ") or line.startswith("\t")):
            # Indented continuation line inside a list (e.g. quoted answers).
            indent, prev = list_items[-1]
            list_items[-1] = (indent, prev + " " + stripped.strip('"').strip())
            i += 1
            continue

        if stripped in ("]", ")", "),", "],"):
            i += 1
            continue

        flush_list()
        para.append(stripped)
        i += 1

    flush_para()
    flush_list()
    return "\n".join(o for o in out if o.strip())


def collect_headings(fragment: str) -> list[tuple[int, str, str]]:
    found = []
    for m in re.finditer(r'<h([123]) id="([^"]+)">(.*?) <a class="ancre"', fragment):
        label = re.sub(r"<[^>]+>", "", m.group(3)).strip()
        label = html.unescape(label)
        found.append((int(m.group(1)), m.group(2), label))
    return found


def build_toc(headings: list[tuple[int, str, str]]) -> str:
    if not headings:
        return ""
    out = ['<nav class="toc" aria-label="Sommaire"><p class="toc-titre">Sommaire</p>']
    current = 0
    for level, hid, label in headings:
        while current < level:
            out.append("<ul>")
            current += 1
        while current > level:
            out.append("</ul>")
            current -= 1
        out.append(f'<li><a href="#{hid}">{html.escape(label)}</a></li>')
    while current > 0:
        out.append("</ul>")
        current -= 1
    out.append("</nav>")
    return "\n".join(out)


def source_files_in_order() -> list[Path]:
    main = (ROOT / "main.typ").read_text(encoding="utf-8")
    includes = INCLUDE_RE.findall(main)
    files = [ROOT / inc for inc in includes if (ROOT / inc).exists()]
    # Belt and braces: pick up any séance file not yet wired in main.typ.
    for extra in sorted((ROOT / "seances").glob("seance-*.typ")):
        if extra not in files:
            files.append(extra)
    return files


def build_fragment() -> tuple[str, str]:
    """Return (toc_html, content_html) with unique heading ids."""
    _SLUG_COUNTS.clear()
    parts: list[str] = []
    for path in source_files_in_order():
        text = path.read_text(encoding="utf-8")
        parts.append(render_blocks(text.splitlines()))
    fragment = "\n".join(p for p in parts if p.strip())
    # Drop the source "Sommaire" section: it only held the Typst outline.
    fragment = re.sub(
        r'<h1 id="sommaire">.*?</h1>\s*',
        "",
        fragment,
        count=1,
        flags=re.DOTALL,
    )
    headings = collect_headings(fragment)
    toc = build_toc(headings)
    return toc, fragment.strip() + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Build clean HTML from Typst sources.")
    parser.add_argument("-o", "--output", default=None, help="Write content fragment to file.")
    parser.add_argument("--toc", default=None, help="Write the Sommaire nav to a file.")
    args = parser.parse_args()
    toc, fragment = build_fragment()
    if args.toc:
        Path(args.toc).write_text(toc + "\n", encoding="utf-8")
        print(f"Sommaire écrit : {args.toc} ({len(toc)} caractères)")
    if args.output:
        Path(args.output).write_text(fragment, encoding="utf-8")
        print(f"Fragment écrit : {args.output} ({len(fragment)} caractères)")
    elif not args.toc:
        print(toc)
        print(fragment)


if __name__ == "__main__":
    main()
