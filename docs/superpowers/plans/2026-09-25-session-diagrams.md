# Session Diagram Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render every exported Typst diagram on the website, including the four diagrams in séance 02, and make CI prove that all 15 diagrams have a matching SVG with no HTML fallback.

**Architecture:** `scripts/build_site.py` remains the single registry source of truth, but each source filename maps to an ordered list of figure specifications. Rendering and exporting use the same zero-based occurrence order within that list. Integration is explicitly ordered `build fragment → export 15 SVG → audit generated markup (15 SVG + 4 séance 02 images + 0 placeholder) → assemble site`, and `scripts/assemble_site.py` copies source assets then repeats the final artifact audit before publication. The diagrams writer owns its scripts/tests; a separate integration/CI owner runs this common audit only after both the diagrams and index writers have finished.

**Tech Stack:** Typst 0.13.1, Python 3 standard library, `unittest`, `html.parser`, GitHub Actions.

**Spec:** `docs/superpowers/plans/2026-09-25-session-diagrams.md`.

## Global Constraints

- Do not edit the Typst diagram sources; this change repairs the website pipeline for existing content.
- Keep `scripts/build_site.py:FIGURE_SVGS` as the single registry source of truth; do not duplicate filenames, stems, alt text, or captions in the exporter or CI.
- A source filename must map to a non-empty ordered list. List index is the zero-based occurrence index shared by HTML rendering and SVG export.
- Preserve the 11 existing séance 01 figures and add the three occurrences from `seances/seance-02/02-les-menaces.typ` plus the one occurrence from `seances/seance-02/03-sensibilisation-zones-ombres.typ`.
- Extract both `#diagram(` and `#lq.diagram(` calls, in textual order, with balanced parentheses.
- Stop export when a registry list length differs from the source occurrence count; never silently associate every occurrence with the first SVG.
- Keep generated output under `public/assets/`; CI remains responsible for compiling the PDF and deploying GitHub Pages.
- Audit every local `<img src>` in the assembled page, ensure every registered SVG is referenced exactly once, and reject any `typst-only` fallback.
- Add no Python package, Node package, browser code, or CSS.
- The diagrams feature writer modifies only its six pipeline/test files listed in the File Map. It does not modify the index task’s `site/` or runtime-test files.
- The CI writer modifies only `.github/workflows/ci.yml`; it may add the index Node runtime command and the common build/audit/assembly integration, but touches no files owned by either feature writer. The workflow contains one `Generate website` step with no duplicated build/export/audit phases; the PDF step compiles only the PDF.
- The common integration owner runs only after both writers. Their worktrees are cumulative: no writer may revert, delete, or require exclusive ownership of the other task’s changes.
- Integration order is mandatory: `scripts/build_site.py` generates the fragment; `scripts/export_figures.py` exports 15 SVG; a pre-assembly audit proves 15 referenced SVG, 4 séance 02 images, and 0 fallback; only then does `scripts/assemble_site.py` assemble/copy and perform the final artifact audit.
- Implementation must leave changes uncommitted for user review. The diagrams feature writer never writes the index feature files or `.github/workflows/ci.yml`; only the separate CI owner writes the workflow.

## File Map

| File | Responsibility | Boundary |
|---|---|---|
| `scripts/build_site.py` | Own the ordered source-to-figure registry and select the SVG for each rendered occurrence. | Does not compile Typst. |
| `scripts/export_figures.py` | Extract every diagram occurrence, validate registry cardinality, and compile one SVG per registered job. | Does not define registry data. |
| `scripts/assemble_site.py` | Copy session assets into the staged site and audit assembled image references. | Does not render Typst. |
| `tests/test_build_site.py` | Prove séance 02 renders four distinct ordered SVGs and no fallback. | Does not require Typst. |
| `tests/test_export_figures.py` | Prove all 15 occurrences are extracted and paired with the correct source, order, stem, and diagram call. | Uses source files and standard-library mocks only. |
| `tests/test_site_pipeline.py` | Prove asset copying and audit failures for missing or fallback content. | Writes only to a temporary directory. |
| `.github/workflows/ci.yml` | Separate CI owner: run Python tests, run the index runtime test after that writer, then build/export/pre-audit/assemble/final-audit and assert 15/4/0. | Touches no feature-writer file; no generated `public/` commit. |

## Interfaces

```python
# scripts/build_site.py
FigureSvg = tuple[str, str, str | None]
FIGURE_SVGS: dict[str, list[FigureSvg]]

def figure_svg(source: Path, occurrence: int) -> str | None:
    """Return the figure HTML for one zero-based source occurrence."""


# scripts/export_figures.py
DIAGRAM_RE = re.compile(r"#(?:lq\.)?diagram\s*\(")

class FigureJob(NamedTuple):
    source: Path
    stem: str
    alt: str
    caption: str | None
    diagram: str

def extract_diagrams(source: Path) -> list[str]:
    """Return every diagram call in textual order."""


def figure_jobs() -> list[FigureJob]:
    """Pair every source occurrence with the registry entry at the same index."""


# scripts/assemble_site.py
class AuditReport(NamedTuple):
    svg_count: int
    session_svg_counts: dict[str, int]
    placeholder_count: int

def copy_session_assets(site_dir: Path) -> None:
    """Copy seances/<seance>/assets into site_dir/assets/<seance>."""

def audit_site(site_dir: Path, page: str) -> AuditReport:
    """Validate local image files, registered SVG coverage, and fallback absence."""


def audit_built_page(page: str) -> AuditReport:
    """Audit generated markup before assembly: 15 SVG refs, 4 séance 02 images, 0 fallback."""
```

Contract:

- `FIGURE_SVGS[filename][occurrence]` is the only association between rendered HTML and compiled output.
- A source with one diagram may still use a one-item list; this keeps one cardinality rule for all files.
- `figure_jobs()` raises `SystemExit` before Typst starts when `len(extract_diagrams(source)) != len(FIGURE_SVGS[filename])`.
- `audit_built_page(fragment)` validates the build product before assembly: exactly 15 unique registered SVG references, `counts.get('seance-02') == 4`, and zero `typst-only` fallbacks. It does not require copied files to exist yet.
- `audit_site(site_dir, page)` enforces the same `counts.get('seance-02') == 4` invariant after copy/assembly. `test_both_audits_reject_wrong_seance_02_count` proves both functions fail when the wrapper key is changed from `seance-02` to `seance-03`.
- `audit_site()` returns only when all local image files exist, all 15 registered SVG paths are referenced, and no `typst-only` element exists. `assemble_site.main()` calls this only after writing the assembled page and copying assets.
- Integration order is `build_site.py → export_figures.py (15 SVG) → audit_built_page(fragment) → assemble_site.py → audit_site(public/index.html)`.
- Local paths are resolved beneath `site_dir`; absolute URLs and parent traversal are rejected.

## Proof Matrix

| Requirement | Automated proof |
|---|---|
| Registry contains all occurrences | `test_registry_pairs_all_source_occurrences` and CI count `15`. |
| All occurrences are extracted | `test_registry_pairs_all_source_occurrences` plus the two source-specific cardinities 3 and 1. |
| Build and export agree by occurrence | Exact ordered stems for `02-les-menaces.typ` and `03-sensibilisation-zones-ombres.typ` in both test modules. |
| Every occurrence becomes an SVG | `test_registry_pairs_all_source_occurrences` returns exactly 15 jobs with exact occurrence order; `test_preassembly_audit_requires_15_svgs_4_seance_02_images_0_fallback`; CI exports exactly 15 `.svg` files. |
| Séance 02 renders four images | `test_session_02_renders_four_registered_svgs_in_order`; both audits enforce `counts.get('seance-02') == 4`; `test_both_audits_reject_wrong_seance_02_count` fails both audits when it differs. |
| No fallback remains | Build-site assertion, pre-assembly audit, `audit_site()` failure test, and final report require `placeholder_count == 0`. |
| Source assets are copied | `test_copy_and_audit_session_assets` checks both séance 01 JPEGs under the temporary site. |
| Missing or unknown images fail closed | `test_audit_rejects_missing_asset_and_fallback`. |
| CI cannot publish an incomplete artifact | CI runs Python and index tests, then one `Generate website` block performs `build → export → count 15 → pre-audit → assemble → final audit` before upload. |
| No duplicated CI generation | `test_generate_website_has_one_ordered_pipeline_block` requires one `Generate rapport data` before one `Generate website`, one website block, no old audit step, an export-free PDF block, and exact phase order. |
| Writers do not conflict | The diagrams writer owns only pipeline/tests; the CI owner owns only `.github/workflows/ci.yml`; integration runs after both writers. |

---

## Task 1: Make the build registry occurrence-aware

**Files:**
- Modify: `tests/test_build_site.py`.
- Modify: `scripts/build_site.py:75-147,434-541`.

**Interfaces:**
- Consumes: Typst visual markers detected in source order and `source.name`.
- Produces: `FIGURE_SVGS: dict[str, list[FigureSvg]]`, `figure_svg(source, occurrence)`, and four distinct séance 02 `<img>` elements.

- [ ] **Step 1: Write the failing séance 02 markup test**

Add this class to `tests/test_build_site.py`:

```python
class SessionDiagramMarkupTest(unittest.TestCase):
    def test_session_02_renders_four_registered_svgs_in_order(self) -> None:
        _, fragment = build_site.build_fragment()
        match = re.search(
            r'<div class="bloc-seance" data-seance="seance-02">'
            r'(?P<body>.*?)(?=<div class="bloc-seance"|\Z)',
            fragment,
            flags=re.DOTALL,
        )
        self.assertIsNotNone(match)
        body = match.group("body") if match is not None else ""
        self.assertEqual(
            re.findall(r'<img src="(assets/figs/[^"]+\.svg)"', body),
            [
                "assets/figs/menace-evenement.svg",
                "assets/figs/menace-vulnerabilite.svg",
                "assets/figs/menace-risque.svg",
                "assets/figs/traitement-risque.svg",
            ],
        )
        self.assertNotIn('class="typst-only"', body)
```

- [ ] **Step 2: Run the focused red test**

Run:

```bash
python3 -B -m unittest \
  tests.test_build_site.SessionDiagramMarkupTest.test_session_02_renders_four_registered_svgs_in_order \
  -v
```

Expected: FAIL because the generated séance 02 body contains four `typst-only` fallbacks and none of the four registered SVG paths.

- [ ] **Step 3: Convert the registry to ordered lists**

Add the type alias above `FIGURE_SVGS`, change the annotation to a list-valued mapping, and replace the complete registry with:

```python
FigureSvg = tuple[str, str, str | None]

FIGURE_SVGS: dict[str, list[FigureSvg]] = {
    "02-criteres-principaux-secondaires.typ": [
        (
            "cia-triangle",
            "Triangle CIA : Confidentialité, Intégrité, Disponibilité, entouré des critères secondaires",
            None,
        ),
    ],
    "03-triade-cia-cas-concrets.typ": [
        (
            "cia-notes-chart",
            "Notes C-I-A par cas (1 à 4). Rouge : C, noir : I, gris : A.",
            "Notes C-I-A par cas (1 à 4). Rouge : C, noir : I, gris : A.",
        ),
    ],
    "10-role-responsable-securite.typ": [
        (
            "rss-chain",
            "Chaîne des fonctions : Identifier, Protéger, Détecter, Répondre, Récupérer",
            None,
        ),
    ],
    "12-travail-personnel-iso-27001.typ": [
        (
            "iso27001-chain",
            "Flux ISO 27001 : Direction, Risques, SoA, Mesures",
            None,
        ),
    ],
    "04-secteurs-domaines-application.typ": [
        (
            "secteurs-spoke",
            "Secteurs public, transverses et privé reliés aux échelles moi, nous et tous",
            None,
        ),
    ],
    "05-facteur-humain-biais-cognitifs.typ": [
        (
            "biais-chain",
            "Six familles de biais cognitifs, du sensori-moteur à la personnalité",
            None,
        ),
    ],
    "06-competences-devsecops.typ": [
        (
            "devsecops-roadmap",
            "Feuille de route : socle acquis, Incident Response, Secure Architecture, Enterprise Ops",
            None,
        ),
    ],
    "08-recommandations-organismes.typ": [
        (
            "recos-groups",
            "Trois groupes de menaces : socle OFCS, confiance fournisseurs, patch critique Exchange",
            None,
        ),
    ],
    "09-vocabulaire-cybersecurite.typ": [
        (
            "teams-triangle",
            "Cycle Red team, Blue team, Purple team avec rejeu",
            None,
        ),
    ],
    "11-surface-attaque-kernel-linux.typ": [
        (
            "kernel-chain",
            "Plan en quatre étapes : réduire, isoler, patcher, surveiller",
            None,
        ),
    ],
    "13-synthese-seance.typ": [
        (
            "synthese-reperes",
            "Trois repères : CIA et SoA, facteur humain, pratique CI/CD",
            None,
        ),
    ],
    "02-les-menaces.typ": [
        (
            "menace-evenement",
            "Événement et dommage reliés à l'accident naturel, la malveillance intentionnelle et l'erreur humaine",
            None,
        ),
        (
            "menace-vulnerabilite",
            "Vulnérabilité comme faiblesse exploitable par une menace",
            None,
        ),
        (
            "menace-risque",
            "Risque comme probabilité de survenue d'une menace et impact sur le dommage",
            None,
        ),
    ],
    "03-sensibilisation-zones-ombres.typ": [
        (
            "traitement-risque",
            "Traitement du risque : réduire ou atténuer, transférer, accepter et éviter, avec les mesures associées",
            None,
        ),
    ],
}
```

Keep the existing explanatory comment above the mapping and change “value is” to “each list item is”.

- [ ] **Step 4: Select a figure by explicit occurrence index**

Replace `figure_svg` with:

```python
def figure_svg(source: Path, occurrence: int) -> str | None:
    """Render one registered diagram occurrence as a lazy HTML figure."""
    entries = FIGURE_SVGS.get(source.name)
    if entries is None or not 0 <= occurrence < len(entries):
        return None
    stem, alt, caption = entries[occurrence]
    src = html.escape(f"assets/figs/{stem}.svg", quote=True)
    img = f'<img src="{src}" alt="{html.escape(alt, quote=True)}" loading="lazy">'
    if caption:
        return f"<figure>{img}<figcaption>{inline_markup(caption)}</figcaption></figure>"
    return f"<figure>{img}</figure>"
```

At the start of each invocation of `render_blocks`, after `source = _CURRENT_SOURCE`, add one local selector:

```python
    figure_occurrence = 0

    def diagram_html() -> str:
        nonlocal figure_occurrence
        rendered = figure_svg(source, figure_occurrence)
        figure_occurrence += 1
        return rendered or typst_placeholder(source)
```

Replace the three visual branches in `render_blocks` with `diagram_html()`:

```python
            if IMAGE_RE.search(block):
                out.append(parse_image(block, source))
            else:
                out.append(diagram_html())
```

```python
            if VISUAL_MARKER_RE.search(block):
                out.append(diagram_html())
            elif IMAGE_RE.search(block):
                out.append(parse_image(block, source))
```

```python
        if VISUAL_MARKER_RE.search(stripped):
            flush_para()
            flush_list()
            block, i = balanced_block(lines, i, "(", ")")
            out.append(diagram_html())
            continue
```

- [ ] **Step 5: Run the focused green test and current Python suite**

Run:

```bash
python3 -B -m unittest \
  tests.test_build_site.SessionDiagramMarkupTest.test_session_02_renders_four_registered_svgs_in_order \
  -v
python3 -B -m unittest discover -s tests -p 'test_*.py'
```

Expected: the focused test and full Python suite PASS; séance 02 contains the four expected SVG paths and no fallback.

**Suggested commit, not executed:** `feat: associate website figures with source occurrences`

---

## Task 2: Extract and export every diagram occurrence

**Files:**
- Create: `tests/test_export_figures.py`.
- Modify: `scripts/export_figures.py:3-124`.

**Interfaces:**
- Consumes: `FIGURE_SVGS` imported from `build_site` and Typst source text.
- Produces: 15 validated `FigureJob` records and 15 Typst SVG compilations.

- [ ] **Step 1: Write the failing extraction and pairing tests**

Create `tests/test_export_figures.py`:

```python
import unittest
from collections import Counter
from unittest.mock import patch

from scripts import export_figures


class FigureJobsTest(unittest.TestCase):
    def test_registry_pairs_all_source_occurrences(self) -> None:
        jobs = export_figures.figure_jobs()

        self.assertEqual(len(jobs), 15)
        self.assertEqual(
            Counter(job.source.name for job in jobs),
            Counter(
                {
                    "02-criteres-principaux-secondaires.typ": 1,
                    "03-triade-cia-cas-concrets.typ": 1,
                    "10-role-responsable-securite.typ": 1,
                    "12-travail-personnel-iso-27001.typ": 1,
                    "04-secteurs-domaines-application.typ": 1,
                    "05-facteur-humain-biais-cognitifs.typ": 1,
                    "06-competences-devsecops.typ": 1,
                    "08-recommandations-organismes.typ": 1,
                    "09-vocabulaire-cybersecurite.typ": 1,
                    "11-surface-attaque-kernel-linux.typ": 1,
                    "13-synthese-seance.typ": 1,
                    "02-les-menaces.typ": 3,
                    "03-sensibilisation-zones-ombres.typ": 1,
                }
            ),
        )

        menaces = [job for job in jobs if job.source.name == "02-les-menaces.typ"]
        self.assertEqual(
            [job.stem for job in menaces],
            ["menace-evenement", "menace-vulnerabilite", "menace-risque"],
        )
        self.assertIn("Malveillance intentionnelle", menaces[0].diagram)
        self.assertIn("Faiblesse exploitable par une menace", menaces[1].diagram)
        self.assertIn("Probabilité de survenue", menaces[2].diagram)

        traitement = next(
            job
            for job in jobs
            if job.source.name == "03-sensibilisation-zones-ombres.typ"
        )
        self.assertEqual(traitement.stem, "traitement-risque")
        self.assertIn("Réduire / atténuer", traitement.diagram)

    def test_cardinality_mismatch_fails_before_export(self) -> None:
        one_spec = [("only-one", "Alt", None)]
        with patch.dict(
            export_figures.FIGURE_SVGS,
            {"02-les-menaces.typ": one_spec},
            clear=True,
        ):
            with self.assertRaisesRegex(
                SystemExit,
                r"02-les-menaces\.typ.*3.*1",
            ):
                export_figures.figure_jobs()


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run the red exporter tests**

Run:

```bash
python3 -B -m unittest tests.test_export_figures -v
```

Expected: ERROR with `AttributeError: module 'scripts.export_figures' has no attribute 'figure_jobs'` for the first test; the same missing interface is decisive for both tests.

- [ ] **Step 3: Replace first-match extraction with ordered extraction**

In `scripts/export_figures.py`, add `from typing import NamedTuple`, replace `DIAGRAM_RES` with:

```python
DIAGRAM_RE = re.compile(r"#(?:lq\.)?diagram\s*\(")
```

Replace `extract_diagram` with:

```python
def extract_diagrams(source: Path) -> list[str]:
    """Return every #diagram / #lq.diagram call in textual order."""
    text = source.read_text(encoding="utf-8")
    diagrams: list[str] = []
    for match in DIAGRAM_RE.finditer(text):
        open_idx = text.index("(", match.start(), match.end())
        depth = 0
        for index in range(open_idx, len(text)):
            if text[index] == "(":
                depth += 1
            elif text[index] == ")":
                depth -= 1
                if depth == 0:
                    diagrams.append(text[match.start():index + 1])
                    break
        else:
            raise SystemExit(
                f"export_figures: unbalanced parens in diagram of {source}"
            )
    if not diagrams:
        raise SystemExit(
            f"export_figures: no #diagram / #lq.diagram found in {source}"
        )
    return diagrams
```

Add this record and builder after `find_source`:

```python
class FigureJob(NamedTuple):
    source: Path
    stem: str
    alt: str
    caption: str | None
    diagram: str


def figure_jobs() -> list[FigureJob]:
    jobs: list[FigureJob] = []
    for filename, entries in FIGURE_SVGS.items():
        source = find_source(filename)
        diagrams = extract_diagrams(source)
        if len(diagrams) != len(entries):
            raise SystemExit(
                "export_figures: "
                f"{filename} has {len(diagrams)} diagram occurrences "
                f"but {len(entries)} registry entries"
            )
        jobs.extend(
            FigureJob(source, stem, alt, caption, diagram)
            for (stem, alt, caption), diagram in zip(entries, diagrams)
        )
    return jobs
```

- [ ] **Step 4: Compile the validated job list**

Replace the registry loop in `main` with:

```python
        for job in figure_jobs():
            stem = job.stem
            wrapper = workdir / f"{stem}.typ"
            wrapper.write_text(
                WRAPPER_TEMPLATE.format(
                    source=job.source.relative_to(ROOT),
                    diagram=job.diagram,
                ),
                encoding="utf-8",
            )
            dest = outdir / f"{stem}.svg"
            proc = subprocess.run(
                [typst, "compile", "--root", ".", "--format", "svg",
                 str(wrapper.relative_to(ROOT)), str(dest)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )
            if proc.returncode != 0:
                raise SystemExit(
                    f"export_figures: typst failed for {stem}:\n"
                    f"{proc.stderr.strip()}"
                )
            print(f"Figure exportée : {dest.relative_to(ROOT)}")
```

Update the module docstring from “the call from each known source” to “all calls from each known source in source order”.

- [ ] **Step 5: Run the exporter tests and Python suite**

Run:

```bash
python3 -B -m unittest tests.test_export_figures -v
python3 -B -m unittest discover -s tests -p 'test_*.py'
```

Expected: both exporter tests and the full Python suite PASS; `figure_jobs()` returns 15 records and rejects a 3-occurrence/1-entry mismatch.

**Suggested commit, not executed:** `fix: export every diagram occurrence`

---

## Task 3: Copy and audit the staged site assets

**Files:**
- Create: `tests/test_site_pipeline.py`.
- Modify: `scripts/assemble_site.py:1-50`.
- Do not modify `.github/workflows/ci.yml` in this diagrams writer; Task 4 assigns it to the separate CI owner.

**Interfaces:**
- Consumes: assembled HTML, `SEANCES_DIR`, and the flattened registry stems.
- Produces: copied session assets, an `AuditReport`, and a non-zero CI exit before deployment on any missing, extra, or fallback diagram.

- [ ] **Step 1: Write failing asset-copy and audit tests**

Create `tests/test_site_pipeline.py`:

```python
import re
import tempfile
import unittest
from pathlib import Path

from scripts import assemble_site, build_site


class SitePipelineTest(unittest.TestCase):
    def test_preassembly_audit_requires_15_svgs_4_seance_02_images_0_fallback(self) -> None:
        _, fragment = build_site.build_fragment()
        report = assemble_site.audit_built_page(fragment)
        self.assertEqual(report.svg_count, 15)
        self.assertEqual(report.session_svg_counts["seance-02"], 4)
        self.assertEqual(report.placeholder_count, 0)
        self.assertEqual(
            re.findall(r'<img src="(assets/figs/[^"]+\.svg)"', fragment).count("assets/figs/menace-evenement.svg"),
            1,
        )

    def test_copy_and_audit_session_assets(self) -> None:
        _, fragment = build_site.build_fragment()
        sources = re.findall(r'<img src="([^"]+)"', fragment)
        with tempfile.TemporaryDirectory() as temporary:
            site_dir = Path(temporary) / "public"
            assemble_site.copy_session_assets(site_dir)

            self.assertTrue(
                (site_dir / "assets/seance-01/devsecops-knowledge-p1.jpg").is_file()
            )
            self.assertTrue(
                (site_dir / "assets/seance-01/devsecops-knowledge-p2.jpg").is_file()
            )

            for source in sources:
                destination = site_dir / source
                destination.parent.mkdir(parents=True, exist_ok=True)
                if not destination.exists():
                    destination.write_text("test asset", encoding="utf-8")

            report = assemble_site.audit_site(site_dir, fragment)
            self.assertEqual(report.svg_count, 15)
            self.assertEqual(report.session_svg_counts["seance-02"], 4)
            self.assertEqual(report.placeholder_count, 0)

    def test_both_audits_reject_wrong_seance_02_count(self) -> None:
        _, fragment = build_site.build_fragment()
        broken = fragment.replace(
            '<div class="bloc-seance" data-seance="seance-02">',
            '<div class="bloc-seance" data-seance="seance-03">',
            1,
        )
        self.assertNotEqual(broken, fragment)
        with self.assertRaisesRegex(SystemExit, "Séance 02 SVG count"):
            assemble_site.audit_built_page(broken)
        with tempfile.TemporaryDirectory() as temporary:
            site_dir = Path(temporary) / "public"
            for source in re.findall(r'<img src="([^"]+)"', broken):
                destination = site_dir / source
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_text("test asset", encoding="utf-8")
            with self.assertRaisesRegex(SystemExit, "Séance 02 SVG count"):
                assemble_site.audit_site(site_dir, broken)

    def test_audit_rejects_missing_asset_and_fallback(self) -> None:
        _, fragment = build_site.build_fragment()
        with tempfile.TemporaryDirectory() as temporary:
            site_dir = Path(temporary) / "public"
            sources = re.findall(r'<img src="([^"]+)"', fragment)
            for source in sources:
                destination = site_dir / source
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_text("test asset", encoding="utf-8")

            missing = sources[0]
            (site_dir / missing).unlink()
            with self.assertRaisesRegex(SystemExit, "Missing site asset"):
                assemble_site.audit_site(site_dir, fragment)

            (site_dir / missing).write_text("test asset", encoding="utf-8")
            with self.assertRaisesRegex(SystemExit, "typst-only"):
                assemble_site.audit_site(
                    site_dir,
                    fragment + '<div class="typst-only">fallback</div>',
                )


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run the red pipeline tests**

Run:

```bash
python3 -B -m unittest tests.test_site_pipeline -v
```

Expected: ERROR with `AttributeError: module 'scripts.assemble_site' has no attribute 'audit_built_page'`; after that interface exists, the pre-assembly, copy/audit, and wrong-count negative tests drive the shared parser implementation.

- [ ] **Step 3: Add the copy and audit implementation**

Update `scripts/assemble_site.py` imports to include `HTMLParser`, `NamedTuple`, and the package-safe registry import:

```python
from html.parser import HTMLParser
from typing import NamedTuple

if __package__:
    from .build_site import FIGURE_SVGS
else:
    from build_site import FIGURE_SVGS
```

Add these exact definitions after `FRAGMENT_MARKER`:

```python
class AuditReport(NamedTuple):
    svg_count: int
    session_svg_counts: dict[str, int]
    placeholder_count: int


class ImageAuditParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.current_session: str | None = None
        self.sources: list[tuple[str | None, str]] = []
        self.placeholder_count = 0
        self.session_div_depth = 0

    def handle_starttag(
        self,
        tag: str,
        attrs: list[tuple[str, str | None]],
    ) -> None:
        values = dict(attrs)
        classes = (values.get("class") or "").split()
        if tag == "div" and "bloc-seance" in classes:
            self.current_session = values.get("data-seance")
            self.session_div_depth = 1
            return
        if self.current_session is not None and tag == "div":
            self.session_div_depth += 1
        if tag == "div" and "typst-only" in classes:
            self.placeholder_count += 1
        if tag == "img" and values.get("src"):
            self.sources.append((self.current_session, values["src"] or ""))


def copy_session_assets(site_dir: Path) -> None:
    for assets in sorted((ROOT / "seances").glob("*/assets")):
        destination = site_dir / "assets" / assets.parent.name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(assets, destination, dirs_exist_ok=True)


def count_session_svgs(
    sources: list[tuple[str | None, str]],
) -> dict[str, int]:
    counts: dict[str, int] = {}
    for session, source in sources:
        if session and source.startswith("assets/figs/"):
            counts[session] = counts.get(session, 0) + 1
    return counts


def audit_built_page(page: str) -> AuditReport:
    parser = ImageAuditParser()
    parser.feed(page)
    expected_svgs = {
        f"assets/figs/{stem}.svg"
        for entries in FIGURE_SVGS.values()
        for stem, _alt, _caption in entries
    }
    referenced_svgs = [
        source for _session, source in parser.sources
        if source.startswith("assets/figs/")
    ]
    referenced_set = set(referenced_svgs)
    if len(referenced_svgs) != len(referenced_set) or referenced_set != expected_svgs:
        raise SystemExit("Pre-assembly SVG registry mismatch")
    if parser.sources.count(("seance-02", "assets/figs/menace-evenement.svg")) != 1:
        raise SystemExit("Séance 02 occurrence mapping mismatch")
    counts = count_session_svgs(parser.sources)
    if counts.get('seance-02') != 4:
        raise SystemExit(
            f"Séance 02 SVG count must be 4, got {counts.get('seance-02', 0)}"
        )
    if parser.placeholder_count:
        raise SystemExit(
            f"Found {parser.placeholder_count} typst-only diagram fallback(s)"
        )
    return AuditReport(
        svg_count=len(referenced_svgs),
        session_svg_counts=counts,
        placeholder_count=parser.placeholder_count,
    )


def audit_site(site_dir: Path, page: str) -> AuditReport:
    parser = ImageAuditParser()
    parser.feed(page)

    for _, source in parser.sources:
        path = Path(source)
        if path.is_absolute() or ".." in path.parts:
            raise SystemExit(f"Invalid site asset path: {source}")
        destination = site_dir / path
        if not destination.is_file() or destination.stat().st_size == 0:
            raise SystemExit(f"Missing site asset: {source}")

    expected_svgs = {
        f"assets/figs/{stem}.svg"
        for entries in FIGURE_SVGS.values()
        for stem, _alt, _caption in entries
    }
    referenced_svgs = [
        source
        for _session, source in parser.sources
        if source.startswith("assets/figs/")
    ]
    referenced_set = set(referenced_svgs)
    if len(referenced_svgs) != len(referenced_set) or referenced_set != expected_svgs:
        missing = sorted(expected_svgs - referenced_set)
        unknown = sorted(referenced_set - expected_svgs)
        duplicates = sorted(
            source
            for source in referenced_set
            if referenced_svgs.count(source) > 1
        )
        raise SystemExit(
            "SVG registry mismatch: "
            f"missing={missing}, unknown={unknown}, duplicates={duplicates}"
        )

    counts = count_session_svgs(parser.sources)
    if counts.get('seance-02') != 4:
        raise SystemExit(
            f"Séance 02 SVG count must be 4, got {counts.get('seance-02', 0)}"
        )
    if parser.placeholder_count:
        raise SystemExit(
            f"Found {parser.placeholder_count} typst-only diagram fallback(s)"
        )

    return AuditReport(
        svg_count=len(referenced_svgs),
        session_svg_counts=counts,
        placeholder_count=parser.placeholder_count,
    )
```

Add this method to `ImageAuditParser` so a session wrapper is cleared only at its own closing `div`:

```python
    def handle_endtag(self, tag: str) -> None:
        if tag != "div" or self.current_session is None:
            return
        self.session_div_depth -= 1
        if self.session_div_depth == 0:
            self.current_session = None
```

The depth-aware `handle_starttag` above keeps nested callout `div` elements inside the active session scope.

- [ ] **Step 4: Enforce build → pre-audit → assembly → final audit (4 minutes)**

The CI/local integration sequence must call `build_site.py`, then `export_figures.py` for exactly 15 SVG, then `audit_built_page(fragment)` immediately before `assemble_site.py`. For defense in depth, `assemble_site.main()` may validate its supplied fragment again, but it must still assemble/copy first and finish with `audit_site(out.parent, page)`.

After `out.write_text(page, encoding="utf-8")` and before copying the shell assets, insert:

```python
    copy_session_assets(out.parent)
```

After the XLS copy and before the existing success print, insert:

```python
    report = audit_site(out.parent, page)
    print(
        "Assets vérifiés : "
        f"{report.svg_count} SVG, "
        f"{report.session_svg_counts.get('seance-02', 0)} images séance 02, "
        f"{report.placeholder_count} placeholder"
    )
```

Update the module docstring to state that assembly copies `seances/*/assets` and fails if generated diagram or image references are incomplete.

- [ ] **Step 5: Run the focused green test and full Python suite**

Run:

```bash
python3 -B -m unittest tests.test_site_pipeline -v
python3 -B -m unittest discover -s tests -p 'test_*.py'
```

Expected: the pre-assembly test, both copy/audit tests, and the wrong-count negative test PASS. Both audit implementations require `counts.get("seance-02") == 4`; reports are exactly 15 SVGs, 4 séance 02 images, and 0 placeholders.

**Suggested commit, not executed:** `test: audit staged diagram assets`

---

## Task 4: Gate publication on real artifacts — separate CI/integration owner

**Files:**
- Modify: `.github/workflows/ci.yml:28-54` only, after the diagrams and index writers finish.
- Reference only: `scripts/export_figures.py`, `scripts/build_site.py`, `scripts/assemble_site.py`, the three Python test modules, and `tests/test_app_runtime.js`.
- Do not modify any file owned by the diagrams or index writers.

**Interfaces:**
- Consumes: fresh CI checkout, Typst 0.13.1, and all source assets.
- Produces: a generated fragment, exactly 15 compiled SVGs, and a fully audited Pages artifact from the single `Generate website` block.

- [ ] **Step 1: Add both feature test gates before compilation (3 minutes)**

Insert these steps after checkout and before Typst setup:

```yaml
      - name: Run Python tests
        run: python3 -B -m unittest discover -s tests -p 'test_*.py'
      - name: Run index runtime tests
        run: node --test tests/test_app_runtime.js
```

The CI owner modifies only `.github/workflows/ci.yml`. Expected after both feature writers: both test steps PASS, then the single `Generate website` block runs without duplication.

- [ ] **Step 2: Replace all website-generation steps with one ordered block (5 minutes)**

The PDF step must compile only `cahier.pdf`; remove `export_figures.py`, the SVG count, and diagram listing from that step. Keep `Generate rapport data` immediately after the PDF step. Delete the old “Generate website” and “Audit published diagram references” steps and replace them with this single CI step immediately after `Generate rapport data`:

```yaml
      - name: Generate website
        run: |
          set -e
          python3 scripts/build_site.py -o /tmp/fragment.html --toc /tmp/toc.html
          python3 scripts/export_figures.py --outdir public/assets/figs --workdir /tmp/diagram-wrappers
          test "$(find public/assets/figs -maxdepth 1 -type f -name '*.svg' | wc -l | tr -d ' ')" = "15"
          python3 -B - <<'PY'
          from pathlib import Path
          from scripts.assemble_site import audit_built_page

          fragment = Path('/tmp/fragment.html').read_text(encoding='utf-8')
          report = audit_built_page(fragment)
          assert report.svg_count == 15, report
          counts = report.session_svg_counts
          assert counts.get('seance-02') == 4, report
          assert report.placeholder_count == 0, report
          print('Pre-assembly audit: 15 SVG, 4 images séance 02, 0 placeholder')
          PY
          python3 scripts/assemble_site.py --toc /tmp/toc.html --fragment /tmp/fragment.html --out public/index.html
          python3 -B - <<'PY'
          from pathlib import Path
          from scripts.assemble_site import audit_site

          root = Path('public')
          report = audit_site(root, (root / 'index.html').read_text(encoding='utf-8'))
          assert report.svg_count == 15, report
          counts = report.session_svg_counts
          assert counts.get('seance-02') == 4, report
          assert report.placeholder_count == 0, report
          print('Final artifact audit: 15 SVG, 4 images séance 02, 0 placeholder')
          PY
          cp rapport-activite-template.xls public/rapport-activite-template.xls
          ls -lh public/
```

Expected: `.github/workflows/ci.yml` contains exactly one `name: Generate website` block after the single `name: Generate rapport data` step and the exact phase order `build_site.py → export_figures.py → count 15 → audit_built_page → assemble_site.py → audit_site`. `upload-pages-artifact` remains a later step. The CI writer modifies only this workflow file.

- [ ] **Step 3: Review the one-block workflow contract (3 minutes)**

Add a static CI contract test to `tests/test_site_pipeline.py`:

```python
class WorkflowContractTest(unittest.TestCase):
    def test_generate_website_has_one_ordered_pipeline_block(self) -> None:
        root = Path(__file__).resolve().parent.parent
        workflow = (root / ".github/workflows/ci.yml").read_text(encoding="utf-8")
        self.assertEqual(workflow.count("- name: Generate website"), 1)
        self.assertEqual(workflow.count("python3 scripts/export_figures.py"), 1)
        self.assertEqual(workflow.count("- name: Generate website"), 1)
        self.assertNotIn("- name: Audit published diagram references", workflow)
        self.assertEqual(workflow.count("- name: Generate rapport data"), 1)
        rapport = workflow.index("- name: Generate rapport data")
        website = workflow.index("- name: Generate website")
        upload = workflow.index("upload-pages-artifact")
        self.assertLess(rapport, website)
        self.assertLess(website, upload)
        ordered = [
            "python3 scripts/build_site.py",
            "python3 scripts/export_figures.py",
            "= \"15\"",
            "audit_built_page(fragment)",
            "python3 scripts/assemble_site.py",
            "audit_site(root",
        ]
        positions = [workflow.index(signature) for signature in ordered]
        self.assertEqual(positions, sorted(positions))
        pdf = workflow.split("- name: Compile Typst", 1)[1].split(
            "- name: Generate rapport data", 1
        )[0]
        self.assertNotIn("export_figures.py", pdf)
        self.assertNotIn("audit_built_page", pdf)
        self.assertNotIn("assemble_site.py", pdf)
```

Expected RED before the workflow replacement and GREEN afterward; no second website/audit block, `Generate rapport data` precedes `Generate website`, website precedes upload, and the PDF block contains neither export nor pre-audit.

- [ ] **Step 4: Run the complete joint local equivalent after both writers (5 minutes)**

Use a clean checkout or a disposable generated-output directory; do not delete tracked/user files. Run:

```bash
python3 -B -m unittest discover -s tests -p 'test_*.py'
node --test tests/test_app_runtime.js
rm -rf .build/session-diagrams-ci
mkdir -p .build/session-diagrams-ci/wrappers
rm -rf public/assets/figs
python3 scripts/build_site.py \
  -o .build/session-diagrams-ci/fragment.html \
  --toc .build/session-diagrams-ci/toc.html
python3 scripts/export_figures.py \
  --outdir public/assets/figs \
  --workdir .build/session-diagrams-ci/wrappers \
  --keep-wrappers
test "$(find public/assets/figs -maxdepth 1 -type f -name '*.svg' | wc -l | tr -d ' ')" = "15"
python3 -B - <<'PY'
from pathlib import Path
from scripts.assemble_site import audit_built_page

fragment = Path('.build/session-diagrams-ci/fragment.html').read_text(encoding='utf-8')
report = audit_built_page(fragment)
assert report.svg_count == 15, report
counts = report.session_svg_counts
assert counts.get('seance-02') == 4, report
assert report.placeholder_count == 0, report
print('Pre-assembly audit: 15 SVG, 4 images séance 02, 0 placeholder')
PY
python3 scripts/assemble_site.py \
  --toc .build/session-diagrams-ci/toc.html \
  --fragment .build/session-diagrams-ci/fragment.html \
  --out public/index.html
python3 -B - <<'PY'
from pathlib import Path
from scripts.assemble_site import audit_site

root = Path('public')
report = audit_site(root, (root / 'index.html').read_text(encoding='utf-8'))
assert report.svg_count == 15, report
counts = report.session_svg_counts
assert counts.get('seance-02') == 4, report
assert report.placeholder_count == 0, report
print('Final artifact audit: 15 SVG, 4 images séance 02, 0 placeholder')
PY
git diff --check
```

Expected: Python and index runtime tests PASS; after clearing only generated `public/assets/figs`, build and Typst export produce 15 SVGs; pre-assembly prints `Pre-assembly audit: 15 SVG, 4 images séance 02, 0 placeholder`; assembly and final audit pass the same 15/4/0 invariants; `git diff --check` reports no whitespace errors. This command is intentionally cumulative and runs after both writers. Restore any pre-existing generated assets when using a dirty local worktree; CI starts clean.

- [ ] **Step 5: Review the final implementation scope (3 minutes)**

Run:

```bash
git status --short
git diff --stat
git diff --check
git diff -- \
  scripts/build_site.py \
  scripts/export_figures.py \
  scripts/assemble_site.py \
  tests/test_build_site.py \
  tests/test_export_figures.py \
  tests/test_site_pipeline.py \
  .github/workflows/ci.yml
```

Expected for the diagrams writer: only its six pipeline/test files are changed by that writer. Expected for the separate CI owner: only `.github/workflows/ci.yml` is additionally changed. Joint status may include the index writer’s four files; none are reverted or removed. No Typst source, local user file, generated `public/` artifact, or commit is included.

**Suggested commit, not executed:** `ci: publish complete session diagrams`

## Self-Review

- Registry cardinality: 11 séance 01 entries plus 3 + 1 séance 02 entries equals 15.
- Occurrence order: HTML and export use the same source list index; no filename-derived or “first diagram” fallback remains.
- Extraction: one combined regular expression covers both supported diagram call forms and returns every balanced call.
- Failure mode: source/registry cardinality mismatch aborts before compilation; missing or extra SVG references abort before artifact upload.
- Session evidence: the build unit test and final CI assertion both require four séance 02 images.
- Fallback evidence: the build unit test, audit failure test, assembly report, and CI assertion all require zero.
- Asset handling: the CI shell loop is replaced by a tested Python copy function; the same audit validates copied JPEG files and compiled SVGs.
- Pre-assembly proof: after build and 15-SVG export, `audit_built_page` requires 15 unique registered SVG references, `counts.get('seance-02') == 4`, and zero fallbacks before assembly runs. `audit_site` repeats the count check, and the negative test proves both reject a different count.
- Final proof: `audit_site` repeats 15/4/0 after copy/assembly, and the CI writer runs it again before upload.
- Build/export integration order: Python tests → index runtime tests → PDF-only compile → `Generate rapport data` → one `Generate website` block (`build fragment → export 15 → count 15 → pre-assembly audit → assemble/copy → final artifact audit`) → upload.
- Writer boundaries: diagrams writer owns six pipeline/test files; index writer owns four UI/runtime files; CI owner owns only `.github/workflows/ci.yml`; all run cumulatively after both feature writers.
- Scope: no UI, CSS, Typst, dependency, or generated artifact change is owned by the diagrams or CI writers.
