import json
import re
import unittest

from scripts import site_model, site_pages


def heading(level: int, hid: str, num: str, title: str) -> str:
    return (f'<h{level} id="{hid}" data-seance="seance-09"><span class="num">{num}</span> '
            f'{title} <a class="ancre" href="#{hid}" aria-label="x">¶</a></h{level}>')


OBJECTIFS = ('<aside class="callout callout-objectifs"><p class="callout-title">Objectifs</p>\n'
             '<p>Comprendre X.</p>\n</aside>')


class RubricStatusTest(unittest.TestCase):
    def _entry(self, body: str, title: str = "Exercice 4 : Cas concret") -> site_model.Entree:
        html = heading(2, "e", "5.1.", title) + body
        entree = site_model.Entree(site_model.headings_in(html)[0][1], html, site_model.ROOT)
        site_model.assess(entree)
        return entree

    def test_all_required_rubrics_written_is_complete(self) -> None:
        entree = self._entry(
            OBJECTIFS
            + heading(3, "m", "5.1.1.", "Métiers pertinents") + "<p>SOC</p>"
            + heading(3, "r", "5.1.2.", "Résultats") + "<p>Tableau</p>"
            + heading(3, "i", "5.1.3.", "Interprétation des résultats") + "<p>Recul</p>"
        )
        self.assertTrue(entree.complete)
        self.assertEqual(entree.rubriques["deroulement"], "absent")
        self.assertEqual(entree.rubrique_ids, {"metiers": "m", "resultats": "r",
                                               "interpretation": "i"})
        self.assertEqual(entree.objectif, "Comprendre X.")

    def test_a_compléter_marks_the_rubric_and_the_entry_in_progress(self) -> None:
        entree = self._entry(
            OBJECTIFS
            + heading(3, "m", "5.1.1.", "Métiers pertinents") + "<p>À compléter.</p>"
            + heading(3, "r", "5.1.2.", "Résultats") + "<p>ok</p>"
            + heading(3, "i", "5.1.3.", "Interprétation des résultats") + "<p>ok</p>"
        )
        self.assertEqual(entree.rubriques["metiers"], "todo")
        self.assertFalse(entree.complete)
        self.assertEqual(entree.todo_count, 1)

    def test_interpretation_is_not_mistaken_for_results(self) -> None:
        entree = self._entry(heading(3, "i", "5.1.1.", "Interprétation des résultats") + "<p>x</p>")
        self.assertEqual(entree.rubriques["resultats"], "absent")
        self.assertEqual(entree.rubriques["interpretation"], "ok")

    def test_entry_kind_reference_and_name(self) -> None:
        cases = {
            "Exercice 11 : Analyse de risque": ("Exercice", "11", "Analyse de risque"),
            "Activité 7 : Kernel Linux": ("Activité", "7", "Kernel Linux"),
            "Travail personnel : ISO 27001": ("Travail personnel", None, "ISO 27001"),
            "Synthèse de la séance": ("Synthèse", None, "Synthèse de la séance"),
            "Intervention Pascal Linder": ("Intervention", None, "Intervention Pascal Linder"),
        }
        for title, (kind, ref, name) in cases.items():
            entree = self._entry("", title)
            self.assertEqual((entree.kind, entree.ref, entree.name), (kind, ref, name), title)


class SeanceTitleTest(unittest.TestCase):
    def _seance(self, title: str) -> site_model.Seance:
        h = site_model.headings_in(heading(1, "s", "9.", title))[0][1]
        return site_model.Seance("seance-09", h, "")

    def test_date_and_theme_are_parsed_from_the_h1(self) -> None:
        seance = self._seance("Séance du 18 septembre 2026 : découverte et auto-évaluation")
        self.assertEqual(seance.date_iso, "2026-09-18")
        self.assertEqual(seance.date_label, "18 septembre 2026")
        self.assertEqual(seance.theme, "découverte et auto-évaluation")
        self.assertEqual((seance.number, seance.slug, seance.label),
                         (9, "seance-09.html", "Séance 09"))

    def test_title_without_theme(self) -> None:
        seance = self._seance("Séance du 1er octobre 2026")
        self.assertEqual(seance.date_iso, "2026-10-01")
        self.assertIsNone(seance.theme)


class RealDocumentTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.doc = site_model.build_document(with_git=False)
        cls.meta = site_pages.build_meta()

    def test_every_session_directory_is_a_seance_in_order(self) -> None:
        keys = [s.key for s in self.doc.seances]
        self.assertEqual(keys, sorted(keys))
        self.assertIn("seance-01", keys)
        self.assertTrue(all(e.heading.level == 2 for e in self.doc.entrees))

    def test_entry_numbers_match_the_pdf_numbering(self) -> None:
        first = self.doc.seances[0]
        self.assertEqual(first.heading.num, "2.")
        self.assertEqual([e.heading.num for e in first.entrees][:2], ["2.1.", "2.2."])

    def test_session_page_keeps_every_heading_id_once(self) -> None:
        page = site_pages.page_seance(self.doc, self.meta, 0)
        ids = re.findall(r'\sid="([^"]+)"', page)
        self.assertEqual(len(ids), len(set(ids)))
        for entree in self.doc.seances[0].entrees:
            self.assertIn(f'id="{entree.heading.id}"', page)

    def test_legacy_anchor_map_points_to_session_pages(self) -> None:
        mapping = json.loads(site_pages.legacy_anchor_map(self.doc))
        entree = self.doc.seances[0].entrees[0]
        self.assertEqual(mapping[entree.heading.id], "seance-01.html")

    def test_search_index_covers_entries_and_subsections(self) -> None:
        records = site_pages.search_index(self.doc)
        urls = {r["u"] for r in records}
        for seance in self.doc.seances:
            for entree in seance.entrees:
                self.assertIn(f"{seance.slug}#{entree.heading.id}", urls)
                for sub in entree.sous_titres:
                    self.assertIn(f"{seance.slug}#{sub.id}", urls)
        self.assertTrue(all(set(r) == {"u", "t", "c", "x"} for r in records))

    def test_layout_rejects_unknown_placeholders_but_not_content(self) -> None:
        page = site_pages.render_layout(
            self.meta, title="t", description="d", page_class="p",
            sidebar_html="", main="<p>{{pas_un_gabarit}}</p>",
        )
        self.assertIn("{{pas_un_gabarit}}", page)
        self.assertNotRegex(page.replace("{{pas_un_gabarit}}", ""), r"\{\{\w+\}\}")


if __name__ == "__main__":
    unittest.main()
