import unittest
from pathlib import Path

from scripts import build_site


class CollectHeadingsTest(unittest.TestCase):
    def test_excludes_every_activity_subpart_from_summary(self) -> None:
        fragment = "\n".join(
            [
                '<h1 id="session"><span class="num">2.</span> Séance <a class="ancre"></a></h1>',
                '<h2 id="activity"><span class="num">2.1.</span> Activité <a class="ancre"></a></h2>',
                '<h3 id="deroulement"><span class="num">2.1.1.</span> Déroulement <a class="ancre"></a></h3>',
                '<h3 id="references"><span class="num">2.1.2.</span> Références <a class="ancre"></a></h3>',
                '<h4 id="detail"><span class="num">2.1.2.1.</span> Détail <a class="ancre"></a></h4>',
            ]
        )

        self.assertEqual(
            build_site.collect_headings(fragment),
            [
                (1, "session", "2.", "Séance"),
                (2, "activity", "2.1.", "Activité"),
            ],
        )


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
