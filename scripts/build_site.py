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
SEANCES_DIR = ROOT / "seances"

# The site flattens every séance's images under public/assets/<seance-dir>/,
# so a source-relative "assets/foo.jpg" must become "assets/seance-01/foo.jpg".
_REL_ASSET_RE = re.compile(r"^(?:\./)?assets/(.+)$")


def asset_src(path: str, source: Path) -> str:
    """Rewrite a source-relative asset path for the deployed public/ layout."""
    try:
        relative = source.relative_to(SEANCES_DIR)
    except ValueError:
        return path
    if len(relative.parts) < 2:
        return path
    seance = relative.parts[0]
    m = _REL_ASSET_RE.match(path)
    if not m:
        return path
    return f"assets/{seance}/{m.group(1)}"


SKIP_PREFIXES = (
    "#import", "#set", "#show", "#let", "#pagebreak", "#outline",
    "#grid", "#box", "#block", "#v(", "#v[", "#line(",
    "#counter", "#datetime", "#hydra", "#codly", "#table.cell",
    "#page(", "#context", "#footnote",
)

HEADING_RE = re.compile(r"^(=+)\s+(.*?)\s*$")
INCLUDE_RE = re.compile(r'#include\s+"([^"]+)"')
SHOWYBOX_TITLE_RE = re.compile(r'title:\s*"([^"]+)"')
TABLE_COLUMNS_RE = re.compile(r"columns:\s*\(([^)]*)\)")
STRONG_RE = re.compile(r"\*([^*]+?)\*")
CODE_RE = re.compile(r"`([^`]+?)`")
LINK_RE = re.compile(r'#link\("([^"]+)"\)\[([^\]]+?)\]')
LINK_BARE_RE = re.compile(r'#link\("([^"]+)"\)')
IMAGE_RE = re.compile(r'image\(\s*"([^"]+)"')
CAPTION_RE = re.compile(r"caption:\s*\[([^\]]*)\]", re.DOTALL)
# A directive whose body we cannot express in HTML (fletcher, lq, ...).
VISUAL_MARKER_RE = re.compile(r"#(?:diagram\b|lq\.)")


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


# Typst auto-numbers headings ("1.", "1.1.", "1.1.1.", "1.1.1.1.") via
# config.typ. The site must reproduce the same sequence while walking headings
# in order. The counter list grows to whatever depth the sources use.
_HEADING_COUNTERS: list[int] = []
_CURRENT_SOURCE: Path = ROOT / "main.typ"


def next_heading_number(level: int) -> str:
    """Increment the hierarchical counter and return e.g. ``1.2.1.``."""
    level = max(level, 1)
    while len(_HEADING_COUNTERS) < level:
        _HEADING_COUNTERS.append(0)
    _HEADING_COUNTERS[level - 1] += 1
    # Zero only the slots deeper than this level; shallower ones stay.
    for deeper in range(level, len(_HEADING_COUNTERS)):
        _HEADING_COUNTERS[deeper] = 0
    return ".".join(str(_HEADING_COUNTERS[i]) for i in range(level)) + "."


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


def directive_block(lines: list[str], start: int) -> tuple[str, int]:
    """Consume a directive that opens a multi-line body.

    Picks the delimiter left unbalanced on the opening line, so a body never
    leaks as literal Typst text when the closing bracket sits lines later.
    """
    line = lines[start]
    if line.count("(") > line.count(")"):
        return balanced_block(lines, start, "(", ")")
    if line.count("[") > line.count("]"):
        return balanced_block(lines, start, "[", "]")
    return line, start + 1


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


MENTION_RE = re.compile(
    r'#text\([^)]*fill:\s*(?:gray|grey|gris)[^)]*\)\s*\[(.*)\]\s*$',
    re.DOTALL,
)


def parse_mention(block: str) -> str:
    """#text(size: ..., fill: gray)[...] -> a discreet provenance line."""
    m = MENTION_RE.search(block)
    if m:
        body = m.group(1)
    else:
        # Any other #text(...)[body]: keep the body as a plain paragraph.
        tail = re.search(r"\]\s*\[(.*)\]\s*$", block, flags=re.DOTALL)
        body = tail.group(1) if tail else ""
    return f'<p class="mention">{inline_markup(" ".join(body.split()))}</p>'


def parse_image(block: str, source: Path) -> str:
    """Render image(...) / figure(image(...), caption: [...]) as HTML <figure>."""
    m = IMAGE_RE.search(block)
    if not m:
        return ""
    src = html.escape(asset_src(m.group(1), source), quote=True)
    alt = ""
    caption_html = ""
    cap = CAPTION_RE.search(block)
    if cap:
        cap_text = " ".join(cap.group(1).split())
        caption_html = f"<figcaption>{inline_markup(cap_text)}</figcaption>"
        alt = html.escape(re.sub(r"[*`]", "", cap_text), quote=True)
    img = f'<img src="{src}" alt="{alt}" loading="lazy">'
    if caption_html:
        return f"<figure>{img}{caption_html}</figure>"
    return f"<figure>{img}</figure>"


def typst_placeholder(source: Path) -> str:
    """PDF-only placeholder for a construct HTML cannot express."""
    return (f'<div class="typst-only" role="note">'
            f'<p>Diagramme — voir la version PDF.</p>'
            f'<p class="typst-only-source">Source : <code>{html.escape(source.name)}</code></p>'
            f'</div>')


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
    # Source file of the lines being rendered; set by build_fragment so nested
    # callout bodies keep the same séance context for asset/diagram rewriting.
    source = _CURRENT_SOURCE
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

        # #figure(...) either wraps an image (HTML-friendly) or a fletcher
        # #diagram / lq chart (PDF-only placeholder).
        if stripped.startswith("#figure("):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "(", ")")
            # A content figure: the `[ … ]` body may open on the same line as
            # the closing paren (`)[`) or on a following line.
            look = i
            while look < len(lines) and not lines[look].strip():
                look += 1
            if block.rstrip().endswith("[") or (look < len(lines)
                                                and lines[look].strip().startswith("[")):
                body, i = balanced_block(lines, look, "[", "]")
                block = block + "\n" + body
            if IMAGE_RE.search(block):
                out.append(parse_image(block, source))
            else:
                out.append(typst_placeholder(source))
            continue

        # Bare #image("...") anywhere on the line.
        if stripped.startswith("#image(") or IMAGE_RE.search(stripped):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "(", ")")
            out.append(parse_image(block, source))
            continue

        # #text(size: ..., fill: gray)[...] -> provenance/aside line.
        if stripped.startswith("#text("):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "[", "]")
            out.append(parse_mention(block))
            continue

        # A container (`#align(center)[ … ]`) wrapping a visual directive or an
        # image. Skip the whole balanced body so nothing leaks as raw Typst.
        if stripped.startswith("#align(") or stripped.startswith("#box(") \
                or stripped.startswith("#block("):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "[", "]")
            if VISUAL_MARKER_RE.search(block):
                out.append(typst_placeholder(source))
            elif IMAGE_RE.search(block):
                out.append(parse_image(block, source))
            continue

        # fletcher #diagram / lq.* appearing without a wrapper.
        if VISUAL_MARKER_RE.search(stripped):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "(", ")")
            out.append(typst_placeholder(source))
            continue

        if stripped.startswith("#"):
            if is_skippable(stripped):
                # Known-but-non-rendered directive: still consume a multi-line
                # body so its contents never leak as literal Typst text.
                if stripped.count("(") > stripped.count(")") \
                        or stripped.count("[") > stripped.count("]"):
                    _, i = directive_block(lines, i)
                else:
                    i += 1
                continue
            if stripped.count("(") > stripped.count(")") \
                    or stripped.count("[") > stripped.count("]"):
                # Unrecognized multi-line directive: consume the whole call and
                # surface it as a PDF-only placeholder.
                flush_para()
                flush_list()
                _, i = directive_block(lines, i)
                out.append(typst_placeholder(source))
                continue
            # Single-line unknown directive: skip rather than leaking it.
            i += 1
            continue

        m = HEADING_RE.match(stripped)
        if m:
            flush_para()
            flush_list()
            level = len(m.group(1))
            text = m.group(2)
            hid = unique_slug(re.sub(r"\*", "", text))
            # Typst numbering: level N gets "1.", "1.2.", "1.2.3.", "1.2.3.1.".
            num = next_heading_number(level)
            title_html = (f'<span class="num">{num}</span> '
                          f'{inline_markup(text)}')
            tag = f"h{level}"
            out.append(f'<{tag} id="{hid}">{title_html} '
                       f'<a class="ancre" href="#{hid}" aria-label="Lien vers cette section">¶</a></{tag}>')
            headings.append((level, hid, num + " " + text.replace("*", "")))
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


TOC_MAX_LEVEL = 3  # main.typ pins #outline(depth: 3); the site TOC must match.

# Rubriques identiques dans chaque travail : présentes dans le corps, absentes
# du sommaire. Doit rester synchronisé avec rubriques-repetees dans main.typ.
TOC_HIDDEN_LABELS = frozenset({
    "Métiers pertinents",
    "Déroulement",
    "Résultats",
    "Interprétation des résultats",
})


def collect_headings(fragment: str) -> list[tuple[int, str, str, str]]:
    """Return (level, id, number, label) for every TOC heading (levels 1-3).

    Level-4+ headings are rendered in the body but excluded here, mirroring the
    PDF outline depth so the two summaries stay exactly comparable. Headings
    whose label repeats in every activity are also dropped, mirroring the
    `rubriques-repetees` filter in main.typ.
    """
    found = []
    for m in re.finditer(r'<h([1-9]) id="([^"]+)">(.*?) <a class="ancre"', fragment):
        level = int(m.group(1))
        if level > TOC_MAX_LEVEL:
            continue
        inner = m.group(3)
        num_m = re.match(r'<span class="num">([^<]*)</span>\s*', inner)
        num = num_m.group(1) if num_m else ""
        if num_m:
            inner = inner[num_m.end():]
        label = html.unescape(re.sub(r"<[^>]+>", "", inner)).strip()
        if label in TOC_HIDDEN_LABELS:
            continue
        found.append((level, m.group(2), num, label))
    return found


def build_toc(headings: list[tuple[int, str, str, str]]) -> str:
    if not headings:
        return ""
    out = ['<nav class="toc" aria-label="Sommaire"><p class="toc-titre">Sommaire</p>']
    current = 0
    for level, hid, num, label in headings:
        while current < level:
            out.append("<ul>")
            current += 1
        while current > level:
            out.append("</ul>")
            current -= 1
        prefix = f'<span class="num">{html.escape(num)}</span> ' if num else ""
        out.append(f'<li><a href="#{hid}">{prefix}{html.escape(label)}</a></li>')
    while current > 0:
        out.append("</ul>")
        current -= 1
    out.append("</nav>")
    return "\n".join(out)


def source_files_in_order() -> list[Path]:
    main = (ROOT / "main.typ").read_text(encoding="utf-8")
    files: list[Path] = []
    seen: set[Path] = set()

    def add(path: Path) -> None:
        # Nested #include: a séance lives in its own folder, so includes inside
        # a sub-document resolve relative to that file's directory.
        path = path.resolve()
        if path in seen or not path.exists():
            return
        seen.add(path)
        files.append(path)
        for inc in INCLUDE_RE.findall(path.read_text(encoding="utf-8")):
            add(path.parent / inc)

    for inc in INCLUDE_RE.findall(main):
        add(ROOT / inc)
    # Fallback only: séance entry points are seances/<name>/index.typ. main.typ
    # remains the single source of truth for document order; this picks up a
    # séance folder that exists but is not yet #include-ed in main.typ.
    for extra in sorted((ROOT / "seances").glob("*/index.typ")):
        add(extra)
    return files


def build_fragment() -> tuple[str, str]:
    """Return (toc_html, content_html) with unique heading ids."""
    global _CURRENT_SOURCE
    _SLUG_COUNTS.clear()
    _HEADING_COUNTERS[:] = []
    parts: list[str] = []
    for path in source_files_in_order():
        _CURRENT_SOURCE = path
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
