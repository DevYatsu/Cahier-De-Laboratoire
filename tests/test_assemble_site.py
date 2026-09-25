import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from scripts import assemble_site, build_site


class PreAssemblyAuditTest(unittest.TestCase):
    """The real build fragment must already carry every rendered diagram."""

    def test_real_fragment_reports_fifteen_svgs_four_seance_02_images(self) -> None:
        _, fragment = build_site.build_fragment()

        report = assemble_site.audit_built_page(fragment)

        self.assertEqual(report.svg_count, 15)
        self.assertEqual(report.session_svg_counts.get("seance-02"), 4)
        self.assertEqual(report.placeholder_count, 0)
        self.assertIn("svg_count=15", repr(report))


class AssembledPageAuditTest(unittest.TestCase):
    """The deployed page must carry the same inventory, with files on disk."""

    def _assemble(self, out: Path) -> Path:
        """Run the real CLI (build + assemble) into an out-of-repo directory."""
        with tempfile.TemporaryDirectory() as temporary:
            staging = Path(temporary)
            for script, args in (
                ("build_site.py", ["-o", str(staging / "fragment.html"),
                                   "--toc", str(staging / "toc.html")]),
                ("assemble_site.py", ["--toc", str(staging / "toc.html"),
                                      "--fragment", str(staging / "fragment.html"),
                                      "--out", str(out)]),
            ):
                subprocess.run([sys.executable, "-B",
                                str(assemble_site.ROOT / "scripts" / script), *args],
                               cwd=assemble_site.ROOT, check=True, capture_output=True)
        return out

    def _stage_figures(self, page: str, root: Path) -> list[str]:
        """Create one placeholder file per referenced diagram, return their srcs."""
        sources = [src for src in re.findall(r'<img src="([^"]+)"', page)
                   if src.startswith("assets/figs/")]
        for src in sources:
            destination = root / src
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text("<svg/>", encoding="utf-8")
        return sources

    def test_assembled_page_reports_the_same_inventory(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            page = self._assemble(root / "index.html").read_text(encoding="utf-8")
            self._stage_figures(page, root)

            report = assemble_site.audit_site(root, page)

        self.assertEqual(report.svg_count, 15)
        self.assertEqual(report.session_svg_counts.get("seance-02"), 4)
        self.assertEqual(report.placeholder_count, 0)


class MissingReferenceTest(unittest.TestCase):
    """audit_site must refuse a page that points at a diagram file absent on disk."""

    def _staged_page(self, root: Path) -> str:
        _, fragment = build_site.build_fragment()
        for src in re.findall(r'<img src="(assets/figs/[^"]+)"', fragment):
            destination = root / src
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text("<svg/>", encoding="utf-8")
        return fragment

    def test_missing_diagram_file_fails_the_audit(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            fragment = self._staged_page(root)
            (root / "assets/figs/menace-risque.svg").unlink()

            with self.assertRaisesRegex(SystemExit, "menace-risque.svg"):
                assemble_site.audit_site(root, fragment)

    def test_escaping_reference_is_refused_before_any_lookup(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            fragment = self._staged_page(root).replace(
                'src="assets/figs/menace-risque.svg"',
                'src="../../../etc/passwd.svg"',
                1,
            )

            with self.assertRaisesRegex(SystemExit, "Invalid asset path"):
                assemble_site.audit_site(root, fragment)

    def test_preassembly_audit_ignores_the_filesystem(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            fragment = self._staged_page(Path(temporary))
            (Path(temporary) / "assets/figs/menace-risque.svg").unlink()

            report = assemble_site.audit_built_page(fragment)

        self.assertEqual(report.svg_count, 15)


class PlaceholderCountTest(unittest.TestCase):
    """A PDF-only fallback must show up in the report instead of passing silently."""

    def test_typst_only_placeholder_is_counted_per_session(self) -> None:
        _, fragment = build_site.build_fragment()
        injected = fragment.replace(
            '<div class="bloc-seance" data-seance="seance-02">',
            '<div class="bloc-seance" data-seance="seance-02">'
            '<div class="typst-only" role="note">'
            "<p>Diagramme - voir la version PDF.</p></div>",
            1,
        )
        self.assertNotEqual(injected, fragment)

        report = assemble_site.audit_built_page(injected)

        self.assertEqual(report.placeholder_count, 1)
        self.assertEqual(report.svg_count, 15)
        self.assertEqual(report.session_svg_counts.get("seance-02"), 4)
        self.assertIn("placeholder_count=1", repr(report))

    def test_placeholder_free_fragment_reports_none(self) -> None:
        _, fragment = build_site.build_fragment()

        self.assertEqual(assemble_site.audit_built_page(fragment).placeholder_count, 0)


class SessionKeyTest(unittest.TestCase):
    """Every session key must be present so a zero count is a real measurement."""

    # seance-01 carries no figure at all; seance-02 nests one inside a callout.
    MINIMAL_PAGE = (
        '<div class="bloc-seance" data-seance="contexte">\n'
        '<h1 id="c" data-seance="contexte">1. Contexte</h1>\n'
        '<figure><img src="assets/figs/intro.svg" alt="" loading="lazy"></figure>\n'
        "</div>\n"
        '<div class="bloc-seance" data-seance="seance-01">\n'
        '<h1 id="a" data-seance="seance-01">2. Séance 1</h1>\n'
        '<figure><img src="assets/seance-01/photo.jpg" alt="" loading="lazy"></figure>\n'
        "</div>\n"
        '<div class="bloc-seance" data-seance="seance-02">\n'
        '<h1 id="b" data-seance="seance-02">3. Séance 2</h1>\n'
        '<figure><img src="assets/figs/une.svg" alt="" loading="lazy"></figure>\n'
        '<aside class="callout"><figure>'
        '<img src="assets/figs/deux.svg" alt="" loading="lazy"></figure></aside>\n'
        "</div>\n"
    )

    def test_session_without_figure_gets_a_zero_key(self) -> None:
        report = assemble_site.audit_built_page(self.MINIMAL_PAGE)

        self.assertEqual(report.svg_count, 3)
        self.assertEqual(report.session_svg_counts, {"seance-01": 0, "seance-02": 2})
        self.assertNotIn("contexte", report.session_svg_counts)

    def test_context_figures_count_towards_the_page_but_not_a_session(self) -> None:
        _, fragment = build_site.build_fragment()
        page = fragment.replace(
            '<div class="bloc-seance" data-seance="contexte">',
            '<div class="bloc-seance" data-seance="contexte">'
            '<figure><img src="assets/figs/contexte.svg" alt="" loading="lazy"></figure>',
            1,
        )

        report = assemble_site.audit_built_page(page)

        self.assertEqual(report.svg_count, 16)
        self.assertNotIn("contexte", report.session_svg_counts)
        self.assertEqual(report.session_svg_counts.get("seance-02"), 4)

    def test_real_fragment_keys_every_session_of_the_document(self) -> None:
        _, fragment = build_site.build_fragment()

        counts = assemble_site.audit_built_page(fragment).session_svg_counts

        self.assertEqual(set(counts), {"seance-01", "seance-02"})
        self.assertEqual(counts["seance-01"] + counts["seance-02"], 15)


if __name__ == "__main__":
    unittest.main()
