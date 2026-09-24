# Activity Summary Subpart Exclusion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Ensure PDF and website summaries contain session and activity/work titles only, with no activity subparts at heading level 3 or deeper.

**Architecture:** Keep the document body unchanged and make both summary generators share the same structural boundary: include heading levels 1–2 and exclude every level-3+ heading by depth, independent of its label. Preserve the existing Typst outline-entry styling while removing label-specific filtering that becomes unreachable at the new depth.

**Tech Stack:** Typst 0.13.1, Python 3 standard library, `unittest`

**Spec:** `docs/superpowers/plans/2026-09-25-activity-summary-subparts.md` (Goal and Global Constraints)

## Global Constraints

- Do not change activity body content or heading levels.
- Do not hide subparts by title; exclude them structurally so every current and future level-3+ subpart is excluded.
- Keep PDF and website summary depth synchronized.
- Preserve the existing Typst outline-entry visual treatment.
- Do not modify unrelated working-tree changes.

---

### Task 1: Enforce the summary depth boundary

**Files:**
- Create: `tests/test_build_site.py`
- Modify: `scripts/build_site.py:603-636`
- Modify: `main.typ:15-34`

**Interfaces:**
- Consumes: rendered heading fragments shaped as `<hN id="…">… <a class="ancre"…>`.
- Produces: `collect_headings(fragment) -> list[tuple[int, str, str, str]]` containing only levels 1–2; a Typst outline with `depth: 2`.

- [x] **Step 1: Write the failing regression test**

Create `tests/test_build_site.py`:

```python
import unittest

from scripts import build_site


class CollectHeadingsTest(unittest.TestCase):
    def test_excludes_every_activity_subpart_from_summary(self) -> None:
        fragment = "\n".join(
            [
                '<h1 id="session"><span class="num">2.</span> <a class="ancre"></a>Séance</h1>',
                '<h2 id="activity"><span class="num">2.1.</span> <a class="ancre"></a>Activité</h2>',
                '<h3 id="deroulement"><span class="num">2.1.1.</span> <a class="ancre"></a>Déroulement</h3>',
                '<h3 id="references"><span class="num">2.1.2.</span> <a class="ancre"></a>Références</h3>',
                '<h4 id="detail"><span class="num">2.1.2.1.</span> <a class="ancre"></a>Détail</h4>',
            ]
        )

        self.assertEqual(
            build_site.collect_headings(fragment),
            [
                (1, "session", "2.", "Séance"),
                (2, "activity", "2.1.", "Activité"),
            ],
        )


if __name__ == "__main__":
    unittest.main()
```

- [x] **Step 2: Run the regression test and verify the current failure**

Run:

```bash
python3 -m unittest discover -s tests -p 'test_build_site.py' -v
```

Expected: FAIL because `collect_headings` currently includes level-3 and level-4 entries.

- [x] **Step 3: Restrict the website summary to levels 1–2**

In `scripts/build_site.py`:

1. Change `TOC_MAX_LEVEL` from `3` to `2` and update its comment to state that sessions and activity/work titles are the deepest summary entries.
2. Remove `TOC_HIDDEN_LABELS` and its label-based exclusion branch; a structural depth boundary makes label filtering unreachable and cannot guarantee the requirement for future subpart names.
3. Update the `collect_headings` docstring to say it returns headings for levels 1–2 and that level-3+ headings remain in the body but are excluded from the summary.

The resulting collection logic must retain this behavior:

```python
TOC_MAX_LEVEL = 2  # Sessions and activity/work titles only; mirrors main.typ.


def collect_headings(fragment: str) -> list[tuple[int, str, str, str]]:
    """Return summary headings through level 2, independent of their labels."""
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
        found.append((level, m.group(2), num, label))
    return found
```

- [x] **Step 4: Restrict the PDF summary to levels 1–2 while preserving styling**

In `main.typ`:

1. Remove the `rubriques-repetees` content list and conditional exclusion because level 3 is now outside the outline.
2. Retain the `show outline.entry` rule as an unconditional delegation to `_outrageous.show-entry` so the summary keeps its current visual treatment.
3. Replace the obsolete repeated-label comment with a comment explaining that `depth: 2` includes sessions and activity/work titles while excluding every subpart.
4. Change `#outline(title: none, indent: auto, depth: 3)` to `#outline(title: none, indent: auto, depth: 2)`.

The relevant source must remain equivalent to:

```typ
// Le sommaire retient les séances et les travaux (niveaux 1 et 2).
// La profondeur 2 exclut toutes les sous-rubriques d'activité, quel que soit
// leur intitulé, sans les retirer du corps du document.
#show outline.entry: it =>
  _outrageous.show-entry(it, .._outrageous.presets.typst)
#outline(title: none, indent: auto, depth: 2)
```

- [x] **Step 5: Run targeted and integration verification**

Run:

```bash
python3 -m unittest discover -s tests -p 'test_build_site.py' -v
python3 scripts/build_site.py -o /tmp/cahier-fragment.html --toc /tmp/cahier-toc.html
python3 - <<'PY'
import re
from pathlib import Path

toc = Path('/tmp/cahier-toc.html').read_text(encoding='utf-8')
numbers = re.findall(r'<span class="num">([^<]+)</span>', toc)
assert numbers
assert not any(re.search(r'\d+\.\d+\.\d+', number) for number in numbers), numbers
print(f'HTML summary: {len(numbers)} entries, no activity subparts')
PY
typst compile main.typ /tmp/cahier.pdf
```

Expected: unit test PASS; website generation succeeds; generated summary numbers contain no three-component activity subpart number (for example `2.1.`, never `2.1.1.`); Typst compilation succeeds.

- [x] **Step 6: Review the scoped diff**

Run:

```bash
git diff -- main.typ scripts/build_site.py tests/test_build_site.py
git status --short
```

Expected: the implementation changes only the three scoped files; all pre-existing unrelated modifications and the parent-owned plan document remain untouched by the implementer.

- [x] **Step 7: Leave changes uncommitted**

Do not stage or commit. Return the scoped diff and verification evidence to the parent orchestrator for review.
