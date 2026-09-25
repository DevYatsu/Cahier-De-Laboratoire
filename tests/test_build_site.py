import re
import unittest
from html.parser import HTMLParser
from pathlib import Path
from unittest.mock import patch

from scripts import build_site


class CollectHeadingsTest(unittest.TestCase):
    def test_excludes_every_activity_subpart_from_summary(self) -> None:
        fragment = "\n".join(
            [
                '<h1 id="session" data-seance="seance-01"><span class="num">2.</span> Séance <a class="ancre"></a></h1>',
                '<h2 id="activity" data-seance="seance-01"><span class="num">2.1.</span> Activité <a class="ancre"></a></h2>',
                '<h3 id="deroulement" data-seance="seance-01"><span class="num">2.1.1.</span> Déroulement <a class="ancre"></a></h3>',
                '<h3 id="references" data-seance="seance-01"><span class="num">2.1.2.</span> Références <a class="ancre"></a></h3>',
                '<h4 id="detail" data-seance="seance-01"><span class="num">2.1.2.1.</span> Détail <a class="ancre"></a></h4>',
            ]
        )

        self.assertEqual(
            build_site.collect_headings(fragment),
            [
                (1, "session", "2.", "Séance", "seance-01"),
                (2, "activity", "2.1.", "Activité", "seance-01"),
            ],
        )


class SectionAuditParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.sections: dict[str, list[tuple[str, str]]] = {}
        self.current: str | None = None
        self.div_depth = 0

    def handle_starttag(
        self, tag: str, attrs: list[tuple[str, str | None]]
    ) -> None:
        values = dict(attrs)
        classes = (values.get("class") or "").split()
        if tag == "div" and "bloc-seance" in classes:
            self.current = values.get("data-seance")
            self.sections[self.current or ""] = []
            self.div_depth = 1
            return
        if self.current is not None and tag == "div":
            self.div_depth += 1
        if self.current is not None and tag in {"h1", "h2", "h3", "h4", "p"}:
            self.sections[self.current].append(
                (tag, values.get("data-seance") or self.current)
            )

    def handle_endtag(self, tag: str) -> None:
        if tag != "div" or self.current is None:
            return
        self.div_depth -= 1
        if self.div_depth == 0:
            self.current = None


class TocAuditParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.stack: list[tuple[str, str | None]] = []
        self.current: dict[str, str | dict[str, str] | None] | None = None
        self.entries: list[dict[str, object]] = []

    def handle_starttag(
        self, tag: str, attrs: list[tuple[str, str | None]]
    ) -> None:
        values = dict(attrs)
        parent = self.current
        if tag == "li":
            self.current = {
                "key": values.get("data-seance") or "",
                "href": None,
                "parent": parent,
                "children": [],
            }
            self.entries.append(self.current)
            if parent is not None:
                parent["children"].append(self.current)
        if tag == "a" and self.current:
            self.current["href"] = values.get("href")
        self.stack.append((tag, self.current if tag == "li" else None))

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self.handle_starttag(tag, attrs)
        self.handle_endtag(tag)

    def handle_endtag(self, tag: str) -> None:
        if not self.stack:
            return
        opened_tag, item = self.stack.pop()
        if tag == "li" and self.current is item:
            self.current = item["parent"] if isinstance(item, dict) else None


class SessionMarkupTest(unittest.TestCase):
    def test_key_comes_from_session_directory(self) -> None:
        root = build_site.ROOT
        self.assertEqual(
            build_site.source_seance_key(
                root / "seances" / "seance-01" / "index.typ"
            ),
            "seance-01",
        )
        self.assertEqual(
            build_site.source_seance_key(
                root / "seances" / "seance-01" / "01-auto-evaluation-initiale.typ"
            ),
            "seance-01",
        )
        self.assertEqual(
            build_site.source_seance_key(root / "contexte.typ"), "contexte"
        )

    def test_one_closed_wrapper_per_key_keeps_children_inside(self) -> None:
        toc, fragment = build_site.build_fragment()
        wrapper_keys = re.findall(
            r'<div class="bloc-seance" data-seance="([^"]+)">', fragment
        )
        self.assertEqual(len(wrapper_keys), len(set(wrapper_keys)))
        self.assertEqual(wrapper_keys.count("contexte"), 1)
        self.assertIn("seance-01", wrapper_keys)

        parser = SectionAuditParser()
        parser.feed(fragment)
        self.assertIsNone(parser.current)
        self.assertIn("contexte", parser.sections)
        self.assertIn("seance-01", parser.sections)
        self.assertTrue(parser.sections["seance-01"])
        for tag, child_key in parser.sections["seance-01"]:
            self.assertIn(tag, {"h1", "h2", "h3", "h4", "p"})
            self.assertEqual(child_key, "seance-01")
        self.assertIn('<li data-seance="contexte">', toc)
        self.assertIn('<li data-seance="seance-01">', toc)

    def test_h1_slug_is_not_session_key(self) -> None:
        _, fragment = build_site.build_fragment()
        match = re.search(
            r'<h1 id="([^"]+)" data-seance="seance-01">', fragment
        )
        self.assertIsNotNone(match)
        self.assertNotEqual(match.group(1), "seance-01")

    def test_sommaire_heading_with_extra_attributes_is_removed(self) -> None:
        source = build_site.ROOT / "contexte.typ"
        rendered = '<h1 id="sommaire" class="generated">Sommaire</h1>'
        with patch.object(build_site, "source_files_in_order", return_value=[source]), \
                patch.object(build_site, "render_blocks", return_value=rendered):
            _, fragment = build_site.build_fragment()
        self.assertNotIn('id="sommaire"', fragment)
        self.assertNotIn("Sommaire</h1>", fragment)

    def test_build_output_supplies_runtime_navigation_contract(self) -> None:
        toc, fragment = build_site.build_fragment()
        runtime = (build_site.ROOT / "site" / "app.js").read_text(encoding="utf-8")
        self.assertIn('#contenu h1[data-seance]', runtime)
        self.assertIn('#contenu > .bloc-seance[data-seance]', runtime)
        self.assertIn('.col-sommaire nav.toc a[href^="#"]', runtime)
        self.assertIsNotNone(
            re.search(
                r'<div class="bloc-seance" data-seance="seance-01">.*?'
                r'<h1 id="[^"]+" data-seance="seance-01">',
                fragment,
                flags=re.DOTALL,
            )
        )
        self.assertRegex(fragment, r'<h2 id="[^"]+" data-seance="seance-01">')
        self.assertIn('<li data-seance="seance-01">', toc)

    def test_generated_toc_nests_activity_under_session_parent(self) -> None:
        toc, fragment = build_site.build_fragment()
        h1_id = re.search(
            r'<h1 id="([^"]+)" data-seance="seance-01">', fragment
        ).group(1)
        h2_id = re.search(
            r'<h2 id="([^"]+)" data-seance="seance-01">', fragment
        ).group(1)
        parser = TocAuditParser()
        parser.feed(toc)
        parent = next(entry for entry in parser.entries if entry["href"] == "#" + h1_id)
        activity = next(entry for entry in parser.entries if entry["href"] == "#" + h2_id)
        self.assertIs(activity["parent"], parent)
        self.assertEqual(activity["key"], parent["key"])

        def visible(entry: dict[str, object], matches: set[str]) -> bool:
            return entry["href"] in matches or any(
                visible(child, matches) for child in entry["children"]
            )

        self.assertTrue(
            visible(parent, {"#" + h2_id}),
            "a matching activity must keep its session title visible",
        )


class SessionControlsMarkupTest(unittest.TestCase):
    def test_template_has_all_sessions_and_reversible_error(self) -> None:
        template = (build_site.ROOT / "site" / "template.html").read_text(
            encoding="utf-8"
        )
        self.assertIn('<option value="">Toutes les séances</option>', template)
        self.assertIn('id="seance-erreur"', template)
        self.assertIn('id="seance-erreur-texte"', template)
        self.assertIn('id="btn-toutes"', template)


class ReportPageContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        root = Path(__file__).resolve().parent.parent
        cls.html = (root / "site" / "rapport.html").read_text(encoding="utf-8")

    def test_runtime_activities_contract(self) -> None:
        self.assertIn("fetch('rapport-data.json')", self.html)
        self.assertIn("nombreEstValide(activity.heures)", self.html)
        self.assertIn("typeof valeur==='number'&&Number.isFinite(valeur)", self.html)
        self.assertIn("textContent=contenu", self.html)
        self.assertNotIn("innerHTML", self.html)

    def test_obsolete_modules_section_stays_removed(self) -> None:
        self.assertNotIn("Modules, ECTS et périodes", self.html)
        self.assertNotIn('id="modules"', self.html)


if __name__ == "__main__":
    unittest.main()
