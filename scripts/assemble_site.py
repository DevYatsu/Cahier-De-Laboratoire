#!/usr/bin/env python3
"""Assemble public/index.html from the versioned site shell.

Stdlib only. Reads site/template.html and substitutes the <!--TOC--> and
<!--FRAGMENT--> placeholders with the fragment files produced by
scripts/build_site.py. Copies site/style.css and site/app.js next to the
output so the page stays a fully static GitHub Pages artifact.

Usage:
    python3 scripts/build_site.py -o /tmp/fragment.html --toc /tmp/toc.html
    python3 scripts/assemble_site.py --toc /tmp/toc.html \\
        --fragment /tmp/fragment.html --out public/index.html
"""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "site"
TOC_MARKER = "<!--TOC-->"
FRAGMENT_MARKER = "<!--FRAGMENT-->"


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
