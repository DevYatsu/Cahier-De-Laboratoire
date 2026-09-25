# Vue exclusive d’une séance — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permettre à une URL statique GitHub Pages d’afficher uniquement la séance demandée avec `?seance=seance-NN`, avec une option « Toutes les séances », sans perdre les ancres, la recherche, le scroll spy, la navigation, l’accessibilité, les chemins relatifs et le PDF global.

**Architecture:** Le build regroupe le HTML de chaque clé structurelle `contexte` ou `seance-NN` dans un unique wrapper `data-seance` et propage cette clé aux titres et entrées du sommaire. Un unique cycle runtime `URL → état → filtrage → navigation/sommaire → scroll spy` pilote le document; les événements d’historique et les actions utilisateur réutilisent ce cycle, avec un garde anti-double exécution.

**Tech Stack:** Typst 0.13.1, Python 3 standard library, HTML sémantique, JavaScript navigateur sans dépendance, Node.js built-ins (`node:test`, `node:assert/strict`, `node:vm`), GitHub Pages.

**Spec:** `docs/superpowers/plans/2026-09-25-session-exclusive-viewer.md` — Goal, Architecture, Global Constraints, File Map, Tasks, Self-Review.

## Global Constraints

- Ne modifier que `scripts/build_site.py`, `tests/test_build_site.py`, `site/template.html`, `site/app.js` et `tests/test_app_runtime.js` pendant l’implémentation future décrite ici.
- Préserver et exclure les changements locaux existants `M main.typ` et `?? seances/seance-02/`.
- Ne modifier ni `main.typ`, ni `seances/seance-02/`, ni `public/`, ni `site/style.css`, ni les sources Typst.
- La clé stable vient du premier segment de `seances/<clé>/<fichier>.typ`; la seule forme valide est `seance-\d{2}`. Aucun slug, numéro rendu ou texte h1 ne sert de clé.
- Le h1 conserve son id textuel uniquement comme ancre. Le select, la navigation et le masquage utilisent `data-seance`.
- Le Contexte porte exactement `data-seance="contexte"`; il est visible dans le document complet, masqué dans une séance connue, absent des options et absent de la navigation précédent/suivant.
- Sans `seance`, le comportement existant est conservé: `view` valide d’abord, puis `localStorage['cahier-vue']`, sinon Document.
- La simple présence de `seance`, même `?seance=`, force Document et ne modifie pas `localStorage`, sauf si `view=pdf` est explicitement valide. Dans ce cas uniquement, le PDF global gagne, `seance` est retiré de l’URL et le hash est conservé. Une valeur non vide différente d’une clé connue produit un état visible réversible.
- Une clé inconnue retire `seance` de l’URL avec `replaceState`; le message et son texte sont préparés avant de rendre l’état visible. Le bouton de retour supprime également la key residuale et rend le focus au select.
- Un hash existant qui cible une autre clé connue est retiré avant le scroll spy. Un hash mal encodé ou sans cible est conservé sans lever d’exception.
- `popstate` et `hashchange` sont testés séparément et ensemble. Un garde fondé sur l’URL déjà traitée empêche un second cycle quand le navigateur émet les deux événements.
- Le focus vers un h1 n’est déclenché que par `choisirSeance(cle, ancre, true)`. Aucun chargement, `popstate`, `hashchange` ou scroll ne déplace le focus.
- PDF global: l’entrée en PDF, au chargement ou au clic, supprime immédiatement `seance`, conserve `view=pdf` et le hash, et ne filtre pas `cahier.pdf`. Le retour Document impose `view=doc`, supprime `seance` et conserve le hash.
- Toutes les URL restent relatives à la page courante. Aucun nom de dépôt GitHub n’est codé dans l’application ou dans les liens générés.
- Les deux commandes de test exactes sont `python3 -B -m unittest discover -s tests -p 'test_*.py'` et `node --test tests/test_app_runtime.js`.
- Les artefacts HTML, PDF et copied assets sont écrits uniquement sous un unique `TMP_DIR` créé hors du dépôt.
- Aucun build, commit ou changement de source n’est exécuté dans la tâche de rédaction du plan.

## File Map

| Fichier | Responsabilité | Limite |
|---|---|---|
| `scripts/build_site.py` | Dériver la clé, créer un wrapper par clé, propager `data-seance` aux titres et au TOC. | Aucun filtre PDF. |
| `tests/test_build_site.py` | Vérifier la structure, la cardinalité des wrappers et le placement de leurs enfants. | Aucun artefact dans le dépôt. |
| `site/template.html` | Ajouter « Toutes les séances » et le panneau d’erreur réversible. | Aucun changement CSS ou resource path. |
| `site/app.js` | Centraliser URL, mode, filtrage, TOC, navigation, hash, historique, focus et PDF. | Vanilla JS dans l’IIFE existante. |
| `tests/test_app_runtime.js` | Exécuter le vrai runtime dans un faux DOM complet et sans dépendance. | Node built-ins uniquement. |
| `main.typ`, `seances/seance-02/`, `public/` | Changements locaux protégés; lecture seulement. | Aucun diff fonctionnel. |

## Runtime Contract

```javascript
var etat = {
  demandee: null,  // Valeur brute de seance, chaîne vide comprise.
  courante: null,  // Clé connue, ou null pour le document complet.
  index: -1,       // Index de la clé connue dans seances, sinon -1.
  dernierHref: null
};

function ancreDepuisHash(hash) {}
function sourceSeanceKey(element) {}
function urlPourSeance(cle, ancre) {}
function appliquerFiltre() {}
function majNavigation() {}
function mettreAJour() {}
function actualiserEtat(options) {}
function choisirSeance(cle, ancre, focusUtilisateur) {}
```

Règles de contrat:

- `ancreDepuisHash(hash)` retourne `null` pour un pourcentage mal formé, une erreur `decodeURIComponent` ou un id absent.
- Le mode initial respecte strictement: `view=pdf` valide gagne; sinon `view=doc` valide gagne; sinon la présence de `seance` force Document; sinon `localStorage['cahier-vue']`; sinon Document. Le mode PDF global supprime `seance` et ne filtre pas le PDF.
- `choisirSeance(cle, ancre, focusUtilisateur)` est l’unique fonction qui focalise un h1 et seulement avec le troisième argument vrai.
- `actualiserEtat(options)` accepte `{force:Boolean, focusAncre:String|null}`; `force:true` autorise le recalcul d’une URL identique après une action utilisateur.
- `seances` est toujours `Array<{cle:String, titre:String, ancre:String}>`; aucun élément h1 n’y est stocké après la Task 2.
- `actif` est toujours le lien de TOC actif ou `null`; il n’est jamais un index numérique.

## Proof Matrix

| Claim | Preuve |
|---|---|
| Sans paramètre, document complet | Test Node `absent session keeps the full document`. |
| `?seance=` vaut absence | Test Node `empty seance means all sessions`. |
| `seance` force Document malgré le stockage PDF | Test Node `seance parameter forces document instead of stored pdf`. |
| Clé connue et Contexte distinct | Tests Python de markup et Node `known session hides context and other sessions`. |
| Clé inconnue, message, URL nettoyée et retour clavier | Tests Node inconnu, audit d’ordre et focus. |
| Début : précédent disabled, suivant séance 01, Contexte exclu | Test Node `document start navigation`. |
| Ancres, hash valide, hash croisé, hash mal encodé et `#id-absent` | Tests Node hash. |
| Select toutes, base path, navigation précédente/suivante | Tests Node URL, focus et précédent/suivant. |
| `popstate` et `hashchange`, sans double cycle | Tests Node historiques séparés et test combiné. |
| Sommaire/recherche/`aria-current` | Test Node de composition et rectangles. |
| Navigation Document complète | Test Node `next and previous sequence visits sessions in order` et `direct session hash without query derives navigation index`. |
| Sommaire mobile | Test Node `toc button toggles aria-expanded` avec l’élément `sommaire` du faux DOM. |
| PDF global et retour Document | Tests Node PDF. |
| Wrappers fermés et enfants dans leur section | Test Python `SectionAuditParser`. |
| Base path manuel | Serveur local lancé depuis le parent de `$TMP_DIR/Cahier-De-Laboratoire`. |

---

## Task 1: Propager une structure de séance stable et fermée

**Files exacts:**
- Modify: `tests/test_build_site.py`.
- Modify: `scripts/build_site.py`.

**Interfaces consumes/produces:**
- Consumes: `source_files_in_order() -> list[Path]`, `render_blocks(lines: list[str]) -> str`.
- Produces:
  - `SEANCE_KEY_RE = re.compile(r"seance-\d{2}\Z")`.
  - `source_seance_key(path: Path) -> str`.
  - `collect_headings(fragment) -> list[tuple[int, str, str, str, str]]`.
  - Un unique `<div class="bloc-seance" data-seance="seance-01">` par clé.
  - Un attribut `data-seance` sur chaque titre et chaque `<li>` du TOC.

- [ ] **Step 1: Écrire les tests rouges du markup (4 minutes)**

Ajouter `import re` et `from html.parser import HTMLParser` à `tests/test_build_site.py`, puis ajouter :

```python
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
            self.sections[self.current].append((tag, values.get("data-seance") or self.current))

    def handle_endtag(self, tag: str) -> None:
        if tag != "div" or self.current is None:
            return
        self.div_depth -= 1
        if self.div_depth == 0:
            self.current = None


class SessionMarkupTest(unittest.TestCase):
    def test_key_comes_from_session_directory(self) -> None:
        root = build_site.ROOT
        self.assertEqual(
            build_site.source_seance_key(root / "seances" / "seance-01" / "index.typ"),
            "seance-01",
        )
        self.assertEqual(
            build_site.source_seance_key(
                root / "seances" / "seance-01" / "01-auto-evaluation-initiale.typ"
            ),
            "seance-01",
        )
        self.assertEqual(build_site.source_seance_key(root / "contexte.typ"), "contexte")

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
        self.assertEqual(parser.current, None)
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
```

Adapter le test `CollectHeadingsTest` existant pour ajouter `data-seance="seance-01"` sur ses fragments et attendre cinq membres dans le résultat :

```python
self.assertEqual(
    build_site.collect_headings(fragment),
    [
        (1, "session", "2.", "Séance", "seance-01"),
        (2, "activity", "2.1.", "Activité", "seance-01"),
    ],
)
```

- [ ] **Step 2: Exécuter le test rouge (2 minutes)**

Run:

```bash
python3 -B -m unittest discover -s tests -p 'test_*.py'
```

Expected: FAIL avec `AttributeError: module 'scripts.build_site' has no attribute 'source_seance_key'`, puis après ajout partiel avec un tuple de quatre membres au lieu de cinq.

- [ ] **Step 3: Implémenter la clé et le markup minimal (5 minutes)**

Dans `scripts/build_site.py`, ajouter :

```python
SEANCE_KEY_RE = re.compile(r"seance-\d{2}\Z")


def source_seance_key(path: Path) -> str:
    try:
        first = path.resolve().relative_to(SEANCES_DIR.resolve()).parts[0]
    except (ValueError, IndexError):
        return "contexte"
    return first if SEANCE_KEY_RE.fullmatch(first) else "contexte"
```

Dans la branche heading de `render_blocks`, conserver le slug existant et écrire :

```python
key = source_seance_key(source)
title_html = f'<span class="num">{num}</span> {inline_markup(text)}'
tag = f"h{level}"
out.append(
    f'<{tag} id="{hid}" data-seance="{html.escape(key, quote=True)}">'
    f'{title_html} <a class="ancre" href="#{hid}" '
    f'aria-label="Lien vers cette section">¶</a></{tag}>'
)
```

Remplacer `collect_headings` et `build_toc` par :

```python
def collect_headings(fragment: str) -> list[tuple[int, str, str, str, str]]:
    found: list[tuple[int, str, str, str, str]] = []
    for match in re.finditer(
        r'<h([1-9]) id="([^"]+)" data-seance="([^"]+)">'
        r'(.*?) <a class="ancre"',
        fragment,
    ):
        level = int(match.group(1))
        if level > TOC_MAX_LEVEL:
            continue
        inner = match.group(4)
        num_match = re.match(r'<span class="num">([^<]*)</span>\s*', inner)
        num = num_match.group(1) if num_match else ""
        if num_match:
            inner = inner[num_match.end():]
        label = html.unescape(re.sub(r"<[^>]+>", "", inner)).strip()
        found.append((level, match.group(2), num, label, match.group(3)))
    return found


def build_toc(headings: list[tuple[int, str, str, str, str]]) -> str:
    if not headings:
        return ""
    out = ['<nav class="toc" aria-label="Sommaire"><p class="toc-titre">Sommaire</p>']
    current = 0
    for level, hid, num, label, key in headings:
        while current < level:
            out.append("<ul>")
            current += 1
        while current > level:
            out.append("</ul>")
            current -= 1
        prefix = f'<span class="num">{html.escape(num)}</span> ' if num else ""
        out.append(
            f'<li data-seance="{html.escape(key, quote=True)}">'
            f'<a href="#{hid}">{prefix}{html.escape(label)}</a></li>'
        )
    while current > 0:
        out.append("</ul>")
        current -= 1
    out.append("</nav>")
    return "\n".join(out)
```

Dans `build_fragment`, remplacer le groupement par :

```python
    grouped: dict[str, list[str]] = {}
    for path in source_files_in_order():
        _CURRENT_SOURCE = path
        rendered = render_blocks(path.read_text(encoding="utf-8").splitlines())
        if rendered.strip():
            grouped.setdefault(source_seance_key(path), []).append(rendered)
    fragment = "\n".join(
        f'<div class="bloc-seance" data-seance="{html.escape(key, quote=True)}">\n'
        + "\n".join(parts)
        + "\n</div>"
        for key, parts in grouped.items()
    )
```

Conserver ensuite la suppression du h1 Sommaire, la collecte, la construction du TOC et le retour existants.

- [ ] **Step 4: Exécuter le test vert (2 minutes)**

Run:

```bash
python3 -B -m unittest discover -s tests -p 'test_*.py'
```

Expected: PASS; chaque clé possède un wrapper fermé, chaque enfant reste dans son wrapper et un h1 garde un id différent de sa clé.

**Commit suggéré, non exécuté:** `feat: add stable session metadata to generated HTML`

---

## Task 2: Un cycle runtime complet pour URL, filtrage, navigation, sommaire et PDF

**Files exacts:**
- Modify: `tests/test_build_site.py`.
- Modify: `tests/test_app_runtime.js`.
- Modify: `site/template.html`.
- Modify: `site/app.js`.

**Interfaces consumes/produces:**
- Consumes: wrappers et TOC portant `data-seance`, query `seance`/`view`, hash, historique, `localStorage['cahier-vue']`.
- Produces: une application entièrement testée par le faux DOM complet ci-dessous; un seul cycle `actualiserEtat`; aucune représentation mixte de `seances` ou `actif`.

- [ ] **Step 1: Ajouter les éléments fake du harness (2 minutes)**Ajouter `ClassList` et `Element` avec `attributes`, `hidden`, `href`, `value`, `classList`, `closest`, `querySelectorAll`, `cloneNode`, `focus`, `scrollIntoView`, `getBoundingClientRect`, `dispatch` et audit. Chaque méthode doit être celle du bloc complet ci-dessous, sans dépendance externe.

- [ ] **Step 2: Monter le fixture DOM (4 minutes)**Ajouter `runApp`, les IDs `contenu`, `sommaire`, `btn-toc`, les blocs `data-seance`, les headings, les entrées TOC et les options. Enregistrer chaque élément avec `register` avant de l’exposer dans `ids`.

- [ ] **Step 3: Monter history, événements et VM (4 minutes)**Ajouter `updateLocation`, `replaceState`, `pushState`, `windowListeners`, `requestAnimationFrame`, `localStorage`, `document.querySelector*`, puis exécuter le vrai `site/app.js` avec `vm.runInNewContext`. Retourner `listenerCount`, `writeCount`, `navigate` et `fire` afin que les tests puissent mesurer les cycles.

- [ ] **Step 4: Ajouter les tests rouges de la feature (5 minutes)**Ajouter les tests Node d’absence, de stockage PDF, d’erreur, de hash, de séquence Suivant/Précédent, d’historique, de sommaire, de recherche, de PDF et de bouton TOC. Les tests doivent être ajoutés avant le runtime; la suite doit être non verte avec les nouveaux tests fonctionnels qui échouent sur l’ancien `site/app.js`.

Le bloc JavaScript ci-dessous est le résultat complet de ces quatre sous-étapes; l’implémentant l’applique dans cet ordre, sans coller le fichier entier comme une action unique.

Remplacer entièrement `tests/test_app_runtime.js` par le fichier complet suivant :

```javascript
'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

class ClassList {
  constructor() { this.values = new Set(); }
  add(value) { this.values.add(value); }
  remove(value) { this.values.delete(value); }
  contains(value) { return this.values.has(value); }
}

class Element {
  constructor(tagName, text = '', className = '') {
    this.tagName = tagName.toUpperCase();
    this.children = [];
    this.parentElement = null;
    this.attributes = new Map();
    this.listeners = new Map();
    this.classList = new ClassList();
    this.id = '';
    this.style = {};
    this.dataset = {};
    this.value = '';
    this.offsetTop = 0;
    this.offsetHeight = 20;
    this.scrollTop = 0;
    this.scrollHeight = 400;
    this.clientHeight = 300;
    this._hidden = false;
    this._textContent = text;
    this.audit = [];
    if (className) className.split(/\s+/).forEach(value => this.classList.add(value));
  }
  appendChild(child) {
    child.parentElement = this;
    this.children.push(child);
    return child;
  }
  remove() {
    if (!this.parentElement) return;
    this.parentElement.children = this.parentElement.children.filter(child => child !== this);
    this.parentElement = null;
  }
  addEventListener(type, listener) {
    const listeners = this.listeners.get(type) || [];
    listeners.push(listener);
    this.listeners.set(type, listeners);
  }
  dispatch(type, supplied = {}) {
    const event = Object.assign({ preventDefault() {} }, supplied);
    for (const listener of this.listeners.get(type) || []) listener(event);
    return event;
  }
  setAttribute(name, value) {
    const text = String(value);
    this.attributes.set(name, text);
    if (name === 'class') text.split(/\s+/).forEach(item => this.classList.add(item));
    if (name === 'aria-current' && text === 'location') {
      this.audit.push('aria-current');
    }
    if (name === 'href') {
      this.audit.push('href');
    }
  }
  getAttribute(name) { return this.attributes.has(name) ? this.attributes.get(name) : null; }
  removeAttribute(name) { this.attributes.delete(name); }
  get href() { return this.getAttribute('href') || ''; }
  set href(value) { this.setAttribute('href', value); }
  get value() { return this.getAttribute('value') || ''; }
  set value(value) { this.setAttribute('value', value); }
  get hidden() { return this._hidden; }
  set hidden(value) {
    this._hidden = Boolean(value);
    this.audit.push((value ? 'hide:' : 'show:') + this.id);
  }
  get textContent() { return this._textContent; }
  set textContent(value) {
    this._textContent = String(value);
    if (this.id === 'seance-erreur-texte') this.audit.push('error-text');
  }
  click() { this.dispatch('click'); }
  focus() { globalAudit.focusLog.push(this.id); }
  scrollIntoView() { globalAudit.scrollLog.push(this.id); }
  getBoundingClientRect() {
    if (this.id === 'site-header') return { top: 0, height: 64 };
    return { top: globalAudit.rects[this.id] || 1000, height: 100 };
  }
  compareDocumentPosition(other) {
    const order = node => {
      let current = node;
      while (current.parentElement) current = current.parentElement;
      return globalAudit.order.indexOf(current);
    };
    return order(this) < order(other) ? 4 : 2;
  }
  cloneNode() {
    const copy = new Element(this.tagName, this._textContent);
    for (const [name, value] of this.attributes) copy.setAttribute(name, value);
    for (const child of this.children) copy.appendChild(child.cloneNode(true));
    return copy;
  }
  forEach(callback) { this.children.forEach(callback); }
  closest(selector) {
    let current = this;
    while (current) {
      if (selector === '.bloc-seance' && current.classList.contains('bloc-seance')) return current;
      if (selector === 'a[href^="#"]' && current.tagName === 'A' && current.href.startsWith('#')) return current;
      current = current.parentElement;
    }
    return null;
  }
  descendants() {
    const values = [];
    for (const child of this.children) {
      values.push(child);
      for (const descendant of child.descendants()) values.push(descendant);
    }
    return values;
  }
  querySelectorAll(selector) {
    const values = this.descendants();
    if (selector === 'li') return values.filter(node => node.tagName === 'LI');
    if (selector === 'ul') return values.filter(node => node.tagName === 'UL');
    if (selector === 'span') return values.filter(node => node.tagName === 'SPAN');
    if (selector === '.ancre') return values.filter(node => node.classList.contains('ancre'));
    return [];
  }
  querySelector(selector) { return this.querySelectorAll(selector)[0] || null; }
}

const globalAudit = { focusLog: [], scrollLog: [], rects: {}, order: [] };

function element(tag, text = '', className = '') {
  return new Element(tag, text, className);
}

function withDataSeance(node, key) {
  node.setAttribute('data-seance', key);
  return node;
}

function heading(level, id, key, label) {
  const node = withDataSeance(element('h' + level, label), key);
  node.id = id;
  node.setAttribute('tabindex', '-1');
  const anchor = element('a', '¶', 'ancre');
  anchor.setAttribute('href', '#' + id);
  node.appendChild(anchor);
  return node;
}

function runApp(options = {}) {
  globalAudit.focusLog = [];
  globalAudit.scrollLog = [];
  globalAudit.order = [];
  globalAudit.rects = Object.assign({
    contexte: 10,
    'contexte-intro': 50,
    'seance-01-h1': 100,
    'activite-01': 180,
    'seance-02-h1': 300,
    'activite-02': 380
  }, options.rects || {});

  const ids = new Map();
  const roots = [];
  function register(node) {
    if (node.id) ids.set(node.id, node);
    roots.push(node);
    return node;
  }
  function control(id, tag = 'div') {
    const node = element(tag);
    node.id = id;
    return register(node);
  }

  const body = register(element('body'));
  const article = control('contenu', 'article');
  const blocks = new Map();
  const definitions = [
    ['contexte', 'contexte', 'Contexte', 'contexte-intro', 'Introduction contexte'],
    ['seance-01', 'seance-01-h1', 'Séance 01', 'activite-01', 'Activité 01 café'],
    ['seance-02', 'seance-02-h1', 'Séance 02', 'activite-02', 'Activité 02 thé']
  ];
  for (const [key, h1Id, h1Label, h2Id, h2Label] of definitions) {
    const block = register(element('div', '', 'bloc-seance'));
    block.setAttribute('data-seance', key);
    block.appendChild(register(heading(1, h1Id, key, h1Label)));
    block.appendChild(register(heading(2, h2Id, key, h2Label)));
    article.appendChild(block);
    blocks.set(key, block);
  }

  const sidebar = element('aside', '', 'col-sommaire');
  sidebar.id = 'sommaire';
  register(sidebar);
  const search = control('recherche', 'input');
  search.value = options.search || '';
  const count = control('recherche-compte', 'p');
  const toc = register(element('nav', '', 'toc'));
  const rootList = element('ul');
  const tocByKey = new Map();
  const tocLinks = [];
  for (const [key, h1Id, h1Label, h2Id, h2Label] of definitions) {
    const parent = withDataSeance(element('li'), key);
    const parentAnchor = element('a', h1Label);
    parentAnchor.setAttribute('href', '#' + h1Id);
    parent.appendChild(parentAnchor);
    const children = element('ul');
    const child = withDataSeance(element('li'), key);
    const childAnchor = element('a', h2Label);
    childAnchor.setAttribute('href', '#' + h2Id);
    child.appendChild(childAnchor);
    children.appendChild(child);
    parent.appendChild(children);
    rootList.appendChild(parent);
    tocByKey.set(key, parent);
    tocLinks.push(parentAnchor, childAnchor);
  }
  toc.appendChild(rootList);
  sidebar.appendChild(search);
  sidebar.appendChild(count);
  sidebar.appendChild(toc);

  for (const id of [
    'vue-doc', 'vue-pdf', 'btn-doc', 'btn-pdf', 'btn-theme', 'btn-toc',
    'nav-seances', 'seance-prec', 'seance-suiv', 'seance-select',
    'seance-erreur', 'seance-erreur-texte', 'btn-toutes'
  ]) control(id, id === 'seance-select' ? 'select' : 'div');
  ids.get('vue-doc').classList.add('doc');
  ids.get('vue-pdf').hidden = true;
  ids.get('nav-seances').hidden = true;
  ids.get('seance-erreur').hidden = true;
  const allOption = element('option', 'Toutes les séances');
  allOption.setAttribute('value', '');
  ids.get('seance-select').appendChild(allOption);
  for (const id of ['seance-prec', 'seance-suiv']) ids.get(id).appendChild(element('span'));
  ids.get('btn-toutes').classList.add('bouton');

  const header = register(element('header', '', 'site'));
  header.id = 'site-header';
  const doc = ids.get('vue-doc');
  doc.appendChild(sidebar);
  doc.appendChild(article);
  body.appendChild(header);
  body.appendChild(doc);
  body.scrollHeight = 1200;
  globalAudit.order = roots;

  const initial = new URL(options.url || 'https://example.test/Cahier-De-Laboratoire/index.html');
  const location = { href: initial.toString(), hash: initial.hash };
  const listeners = new Map();
  const frames = [];
  const historyAudit = [];
  function updateLocation(value) {
    const parsed = new URL(value, location.href);
    location.href = parsed.toString();
    location.hash = parsed.hash;
  }
  const history = {
    replaceState(_state, _title, value) {
      updateLocation(value);
      const entry = 'replace:' + location.href;
      historyAudit.push(entry);
      ids.get('seance-erreur').audit.push(entry);
    },
    pushState(_state, _title, value) {
      updateLocation(value);
      const entry = 'push:' + location.href;
      historyAudit.push(entry);
      ids.get('seance-erreur').audit.push(entry);
    }
  };
  const windowListeners = new Map();
  const window = {
    location,
    innerHeight: 800,
    scrollY: 0,
    history,
    addEventListener(type, listener) {
      const values = windowListeners.get(type) || [];
      values.push(listener);
      windowListeners.set(type, values);
    },
    requestAnimationFrame(callback) { frames.push(callback); return frames.length; },
    setTimeout(callback) { callback(); return 1; },
    matchMedia() { return { matches: false, addEventListener() {}, addListener() {} }; }
  };

  const document = {
    body,
    documentElement: element('html'),
    createElement: tag => element(tag),
    getElementById: id => ids.get(id) || null,
    querySelector(selector) {
      if (selector === '.col-sommaire') return sidebar;
      if (selector === '.col-sommaire nav.toc') return toc;
      if (selector === 'header.site') return header;
      return null;
    },
    querySelectorAll(selector) {
      if (selector === '.col-sommaire nav.toc a[href^="#"]') return tocLinks;
      if (selector === '.col-sommaire nav.toc li') return toc.querySelectorAll('li');
      if (selector === '#contenu > .bloc-seance[data-seance]') return Array.from(blocks.values());
      if (selector === '#contenu h1[data-seance]') return article.descendants().filter(node => node.tagName === 'H1');
      if (selector === '.doc .ancre') return article.descendants().filter(node => node.classList.contains('ancre'));
      return [];
    }
  };
  const storage = new Map();
  if (options.storageMode) storage.set('cahier-vue', options.storageMode);
  const context = {
    document,
    window,
    navigator: {},
    localStorage: {
      getItem: key => storage.has(key) ? storage.get(key) : null,
      setItem: (key, value) => storage.set(key, String(value))
    },
    URL,
    matchMedia: window.matchMedia
  };
  const source = fs.readFileSync(path.join(__dirname, '..', 'site', 'app.js'), 'utf8');
  vm.runInNewContext(source, context, { filename: 'site/app.js' });

  return {
    ids,
    blocks,
    tocByKey,
    location,
    historyAudit,
    audit: ids.get('seance-erreur').audit,
    hiddenByKey() {
      const values = {};
      for (const [key, node] of blocks) values[key] = node.hidden;
      return values;
    },
    ariaCurrent() {
      return tocLinks.filter(link => link.getAttribute('aria-current') === 'location')
        .map(link => link.getAttribute('href'));
    },
    focusLog: globalAudit.focusLog,
    scrollLog: globalAudit.scrollLog,
    optionValues() {
      return ids.get('seance-select').children.map(option => option.getAttribute('value'));
    },
    resetWrites() { ids.get('seance-erreur').audit.length = 0; for (const link of tocLinks.concat([ids.get('seance-prec'), ids.get('seance-suiv')])) link.audit.length = 0; },
    writeCount(name) { return tocLinks.concat([ids.get('seance-prec'), ids.get('seance-suiv')]).reduce((sum, link) => sum + link.audit.filter(item => item === name).length, 0); },
    listenerCount(type) { return (windowListeners.get(type) || []).length; },
    navigate(url) { updateLocation(url); },
    fire(type) {
      for (const listener of windowListeners.get(type) || []) listener({ type });
      if (type === 'scroll') {
        const pending = frames.splice(0, frames.length);
        for (const frame of pending) frame();
      }
    }
  };
}

test('absent session keeps the full document', () => {
  const app = runApp();
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.equal(app.ids.get('seance-erreur').hidden, true);
});

test('empty seance means all sessions', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=' });
  assert.equal(new URL(app.location.href).searchParams.has('seance'), false);
  assert.equal(app.ids.get('seance-erreur').hidden, true);
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
});

test('seance parameter forces document instead of stored pdf', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01',
    storageMode: 'pdf'
  });
  assert.equal(new URL(app.location.href).searchParams.get('view'), 'doc');
  assert.equal(app.ids.get('vue-doc').hidden, false);
  assert.equal(app.ids.get('vue-pdf').hidden, true);
});

test('known session hides context and other sessions', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01'
  });
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': false, 'seance-02': true
  });
  assert.equal(app.ids.get('seance-select').value, 'seance-01');
});

test('document start disables previous and targets seance-01 next', () => {
  const app = runApp();
  assert.equal(app.ids.get('seance-prec').getAttribute('aria-disabled'), 'true');
  assert.equal(app.ids.get('seance-suiv').getAttribute('aria-disabled'), null);
  assert.match(app.ids.get('seance-suiv').getAttribute('href'), /#seance-01-h1$/);
  assert.deepEqual(app.optionValues(), ['', 'seance-01', 'seance-02']);
  assert.equal(app.ids.get('seance-prec').querySelector('span').textContent, 'Séance 01');
  assert.equal(app.ids.get('seance-suiv').querySelector('span').textContent, 'Séance 01');
});

test('next and previous sequence visits sessions in order', () => {
  const app = runApp();
  const next = app.ids.get('seance-suiv');
  const previous = app.ids.get('seance-prec');

  next.dispatch('click');
  let url = new URL(app.location.href);
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#seance-01-h1');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.equal(previous.getAttribute('aria-disabled'), 'true');
  assert.equal(next.getAttribute('aria-disabled'), null);

  next.dispatch('click');
  url = new URL(app.location.href);
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#seance-02-h1');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.equal(previous.getAttribute('aria-disabled'), null);
  assert.equal(next.getAttribute('aria-disabled'), 'true');

  previous.dispatch('click');
  url = new URL(app.location.href);
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#seance-01-h1');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.deepEqual(app.focusLog, [
    'seance-01-h1', 'seance-02-h1', 'seance-01-h1'
  ]);
  assert.deepEqual(app.scrollLog, [
    'seance-01-h1', 'seance-02-h1', 'seance-01-h1'
  ]);
});

test('direct session hash without query derives navigation index', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html#seance-02-h1'
  });
  const url = new URL(app.location.href);
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#seance-02-h1');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.equal(app.ids.get('seance-prec').getAttribute('aria-disabled'), null);
  assert.equal(app.ids.get('seance-suiv').getAttribute('aria-disabled'), 'true');
  assert.deepEqual(app.focusLog, []);
});

test('unknown session updates text and URL before becoming visible', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=contexte'
  });
  const audit = app.audit;
  assert.ok(audit.indexOf('error-text') < audit.indexOf('show:seance-erreur'));
  assert.ok(audit.indexOf('replace:https://example.test/Cahier-De-Laboratoire/index.html?view=doc')
    < audit.indexOf('show:seance-erreur'));
  assert.equal(app.ids.get('seance-erreur-texte').textContent, 'Séance introuvable : contexte.');
  assert.equal(new URL(app.location.href).searchParams.has('seance'), false);
  assert.deepEqual(app.focusLog, []);

  const withHash = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-99#seance-01-h1'
  });
  assert.equal(withHash.ids.get('seance-erreur').hidden, false);
  assert.equal(withHash.ids.get('seance-erreur-texte').textContent, 'Séance introuvable : seance-99.');
  assert.equal(new URL(withHash.location.href).searchParams.has('seance'), false);
  assert.deepEqual(withHash.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.deepEqual(withHash.focusLog, []);
});

test('keyboard-focused return button removes unknown state and focuses select', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-99'
  });
  const button = app.ids.get('btn-toutes');
  button.focus();
  button.dispatch('click');
  assert.deepEqual(app.focusLog, ['btn-toutes', 'seance-select']);
  assert.equal(app.ids.get('seance-erreur').hidden, true);
  assert.equal(new URL(app.location.href).searchParams.has('seance'), false);
});

test('all sessions preserves hash, path, and document', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02#activite-02'
  });
  app.ids.get('seance-select').value = '';
  app.ids.get('seance-select').dispatch('change');
  const url = new URL(app.location.href);
  assert.equal(url.pathname, '/Cahier-De-Laboratoire/index.html');
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#activite-02');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
});

test('valid and cross-session activity hashes never focus on load', () => {
  const valid = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-01'
  });
  assert.equal(new URL(valid.location.href).hash, '#activite-01');
  assert.deepEqual(valid.focusLog, []);

  const cross = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-02'
  });
  assert.equal(new URL(cross.location.href).hash, '');
  assert.deepEqual(cross.focusLog, []);

  const malformed = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite%ZZ'
  });
  assert.equal(new URL(malformed.location.href).hash, '#activite%ZZ');
  assert.deepEqual(malformed.focusLog, []);

  const absent = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#id-absent'
  });
  assert.equal(new URL(absent.location.href).hash, '#id-absent');
  assert.deepEqual(absent.focusLog, []);
  assert.equal(absent.ids.get('seance-prec').getAttribute('aria-disabled'), 'true');
});

test('user selection focuses visible h1 and next changes exclusive session', () => {
  const app = runApp();
  app.ids.get('seance-select').value = 'seance-02';
  app.ids.get('seance-select').dispatch('change');
  assert.equal(app.hiddenByKey()['seance-02'], false);
  assert.deepEqual(app.focusLog, ['seance-02-h1']);
  assert.deepEqual(app.scrollLog, ['seance-02-h1']);
  assert.equal(new URL(app.location.href).searchParams.get('seance'), 'seance-02');
});

test('popstate restores a known session without focus', () => {
  const app = runApp({ rects: { 'activite-02': 10 } });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02#activite-02');
  app.fire('popstate');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': false
  });
  assert.deepEqual(app.focusLog, []);
  assert.ok(app.ariaCurrent().length <= 1);
});

test('popstate restores unknown state without focus', () => {
  const app = runApp();
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-99');
  app.fire('popstate');
  assert.equal(app.ids.get('seance-erreur').hidden, false);
  assert.equal(new URL(app.location.href).searchParams.has('seance'), false);
  assert.deepEqual(app.focusLog, []);
  assert.ok(app.ariaCurrent().length <= 1);
});

test('hashchange restores hash state without focus', () => {
  const app = runApp({ rects: { 'activite-01': 10 } });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-01');
  app.fire('hashchange');
  assert.equal(new URL(app.location.href).hash, '#activite-01');
  assert.deepEqual(app.focusLog, []);
  assert.ok(app.ariaCurrent().length <= 1);
});

test('popstate followed by hashchange runs one state cycle', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01',
    rects: { 'activite-01': 10 }
  });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-01');
  app.resetWrites();
  app.fire('popstate');
  app.fire('hashchange');
  assert.ok(app.writeCount('aria-current') <= 1);
  assert.equal(app.writeCount('href'), 2);
  assert.equal(app.listenerCount('popstate'), 1);
  assert.equal(app.listenerCount('hashchange'), 1);
  assert.deepEqual(app.focusLog, []);
});

test('toc search and scroll spy only expose current session', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01',
    search: 'cafe',
    rects: { 'activite-01': 10 }
  });
  assert.equal(app.tocByKey.get('contexte').hidden, true);
  assert.equal(app.tocByKey.get('seance-01').hidden, false);
  assert.equal(app.tocByKey.get('seance-02').hidden, true);
  assert.equal(app.ids.get('recherche-compte').textContent, '2 résultats');
  app.fire('scroll');
  assert.ok(app.ariaCurrent().every(href => href === '#activite-01'));

  app.ids.get('recherche').value = '02';
  app.ids.get('recherche').dispatch('input');
  app.fire('scroll');
  assert.deepEqual(app.ariaCurrent(), []);
});

test('toc button toggles aria-expanded on the fake sommaire element', () => {
  const app = runApp();
  const button = app.ids.get('btn-toc');
  const summary = app.ids.get('sommaire');
  assert.equal(button.getAttribute('aria-expanded'), 'false');
  assert.equal(summary.hidden, true);
  button.dispatch('click');
  assert.equal(button.getAttribute('aria-expanded'), 'true');
  assert.equal(summary.hidden, false);
});

test('initial PDF is global and removes seance', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=pdf&seance=seance-02#activite-02'
  });
  const url = new URL(app.location.href);
  assert.equal(url.searchParams.get('view'), 'pdf');
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#activite-02');
  assert.equal(app.ids.get('vue-pdf').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
});

test('PDF to document preserves hash and final URL is complete document', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-01'
  });
  app.ids.get('btn-pdf').dispatch('click');
  app.ids.get('btn-doc').dispatch('click');
  const url = new URL(app.location.href);
  assert.equal(url.searchParams.get('view'), 'doc');
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#activite-01');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
});
```

- [ ] **Step 5: Ajouter le test rouge du template (2 minutes)**

Dans `tests/test_build_site.py`, ajouter :

```python
class SessionControlsMarkupTest(unittest.TestCase):
    def test_template_has_all_sessions_and_reversible_error(self) -> None:
        template = (build_site.ROOT / "site" / "template.html").read_text(encoding="utf-8")
        self.assertIn('<option value="">Toutes les séances</option>', template)
        self.assertIn('id="seance-erreur"', template)
        self.assertIn('id="seance-erreur-texte"', template)
        self.assertIn('id="btn-toutes"', template)
```

- [ ] **Step 6: Exécuter les tests rouges (2 minutes)**

Run:

```bash
python3 -B -m unittest discover -s tests -p 'test_*.py'
node --test tests/test_app_runtime.js
```

Expected: Python FAIL sur les IDs du template absents; Node signale plusieurs échecs, notamment le filtre de blocs, l’état initial, le stockage PDF, les événements historiques et le PDF. Aucun test n’est ignoré.

- [ ] **Step 7: Modifier le template sans CSS (3 minutes)**

Dans `site/template.html`, remplacer le select vide par :

```html
<select id="seance-select">
  <option value="">Toutes les séances</option>
</select>
```

Ajouter avant `.toc-barre` :

```html
<div class="note" id="seance-erreur" role="alert" hidden>
  <p id="seance-erreur-texte"></p>
  <button type="button" id="btn-toutes" class="bouton">Voir toutes les séances</button>
</div>
```

- [ ] **Step 8: Ajouter mode, URL et état shareable (3 minutes)**Dans `site/app.js`, remplacer la logique de mode par `modeInitial`, `afficherMode`, `ecrireMode` et `changerMode`. La priorité exacte est: `view=pdf` valide, `view=doc` valide, présence de `seance` sans `view`, puis `localStorage['cahier-vue']`, sinon Document. `seance` force donc Document sauf `view=pdf` explicite.

- [ ] **Step 9: Ajouter filtre, hash et index de navigation (4 minutes)**Ajouter `appliquerFiltre`, `ancreDepuisHash`, `sourceSeanceKey` et la déduction de `etat.index` depuis le hash quand aucune séance connue n’est demandée. Ajouter la règle de suppression du hash croisé, le hash absent conservé et le test de séquence.

- [ ] **Step 10: Ajouter navigation, focus et scroll spy (4 minutes)**Ajouter `majNavigation`, `seanceDepuisClic`, `choisirSeance(cle, ancre, focusUtilisateur)`, `reinitialiserScrollSpy` et `mettreAJour`. Le focus reste conditionné au troisième argument; le mode PDF ne filtre pas le document et la navigation produit deux écritures `href` par cycle.

- [ ] **Step 11: Ajouter événements, historique et recherche (3 minutes)**Enregistrer un seul listener `popstate` et un seul listener `hashchange`, tous deux vers `actualiserEtat`. Ajouter les wrappers de recherche, les gestionnaires Document/PDF, le bouton de retour et le bouton TOC. Le test d’unicité doit vérifier directement `listenerCount('popstate') === 1`, `listenerCount('hashchange') === 1` et exactement deux écritures `href` après reset.

Le bloc JavaScript suivant est la référence de contrôle des Steps 8 à 11. L’implémentant ajoute les fonctions par responsabilité fonctionnelle dans cet ordre, sans supprimer ni dupliquer les gestionnaires déjà installés :

```javascript
(function(){
  var doc=document.getElementById('vue-doc'),
      pdf=document.getElementById('vue-pdf'),
      bDoc=document.getElementById('btn-doc'),
      bPdf=document.getElementById('btn-pdf'),
      bRapport=document.getElementById('btn-rapport'),
      bTheme=document.getElementById('btn-theme'),
      navSeances=document.getElementById('nav-seances'),
      lienPrec=document.getElementById('seance-prec'),
      lienSuiv=document.getElementById('seance-suiv'),
      selectSeance=document.getElementById('seance-select'),
      erreur=document.getElementById('seance-erreur'),
      erreurTexte=document.getElementById('seance-erreur-texte'),
      btnToutes=document.getElementById('btn-toutes');
  var etat={demandee:null,courante:null,index:-1,dernierHref:null},
      modeCourante='doc',
      actif=null,
      planifie=false;

  function libelleSeance(h){
    var copie=h.cloneNode(true),
        ancre=copie.querySelector('.ancre');
    if(ancre){ancre.remove();}
    return copie.textContent.replace(/\s+/g,' ').trim();
  }
  var seances=Array.prototype.slice.call(
    document.querySelectorAll('#contenu h1[data-seance]')).filter(function(h){
      return /^seance-\d{2}$/.test(h.getAttribute('data-seance')||'');
    }).map(function(h){
      return {cle:h.getAttribute('data-seance'),titre:libelleSeance(h),ancre:h.id};
    });
  var blocsParCle={};
  Array.prototype.slice.call(
    document.querySelectorAll('#contenu > .bloc-seance[data-seance]')
  ).forEach(function(el){
    var cle=el.getAttribute('data-seance');
    if(blocsParCle[cle]){throw new Error('Duplicate session wrapper: '+cle);}
    blocsParCle[cle]=el;
  });

  function blocDe(element){
    var noeud=element;
    while(noeud&&noeud.id!=='contenu'){
      if(noeud.classList&&noeud.classList.contains('bloc-seance')){return noeud;}
      noeud=noeud.parentElement;
    }
    return null;
  }
  function sourceSeanceKey(element){
    var bloc=blocDe(element);
    return bloc?bloc.getAttribute('data-seance')||'':'';
  }
  function ancreDepuisHash(hash){
    var brut=hash.slice(1);
    if(/%(?![0-9A-Fa-f]{2})/.test(brut)){return null;}
    var id;
    try{id=decodeURIComponent(brut);}catch(e){return null;}
    return document.getElementById(id);
  }
  function urlPourSeance(cle,ancre){
    var u=new URL(window.location.href);
    if(cle){
      u.searchParams.set('view','doc');
      u.searchParams.set('seance',cle);
    }else{
      u.searchParams.delete('seance');
    }
    if(ancre){u.hash=ancre;}
    return (u.search?'?'+u.searchParams.toString():'')+(u.hash||'');
  }
  function modeInitial(){
    var u=new URL(window.location.href),
        q=u.searchParams.get('view');
    if(q==='pdf'||q==='doc'){return q;}
    if(u.searchParams.has('seance')){return 'doc';}
    try{
      var stocke=localStorage.getItem('cahier-vue');
      if(stocke==='pdf'||stocke==='doc'){return stocke;}
    }catch(e){}
    return 'doc';
  }
  function afficherMode(mode){
    var isPdf=mode==='pdf';
    modeCourante=mode;
    pdf.hidden=!isPdf;
    doc.hidden=isPdf;
    bPdf.setAttribute('aria-pressed',isPdf?'true':'false');
    bDoc.setAttribute('aria-pressed',isPdf?'false':'true');
  }
  function ecrireMode(mode,save){
    afficherMode(mode);
    try{
      if(save!==false){try{localStorage.setItem('cahier-vue',mode);}catch(e){}}
      var u=new URL(window.location.href);
      u.searchParams.set('view',mode);
      if(mode==='pdf'){u.searchParams.delete('seance');}
      window.history.replaceState(null,'',u.toString());
    }catch(e){}
  }
  function changerMode(mode){
    ecrireMode(mode,true);
    actualiserEtat({force:true,focusAncre:null});
  }

  var liens=Array.prototype.slice.call(
    document.querySelectorAll('.col-sommaire nav.toc a[href^="#"]'));
  var entrees=Array.prototype.slice.call(
    document.querySelectorAll('.col-sommaire nav.toc li'));
  var sommaire=document.querySelector('.col-sommaire');
  function ancreDirecte(li){
    for(var i=0;i<li.children.length;i++){
      var child=li.children[i];
      if(child.tagName==='A'&&child.getAttribute('href')&&
         child.getAttribute('href').charAt(0)==='#'){return child;}
    }
    return null;
  }
  function normaliser(value){
    value=(value||'').toLowerCase();
    if(value.normalize){value=value.normalize('NFD').replace(/[\u0300-\u036f]/g,'');}
    return value;
  }
  function appliquerFiltre(){
    var champ=document.getElementById('recherche'),
        compte=document.getElementById('recherche-compte'),
        q=champ?normaliser(champ.value.trim()):'',
        visibles=[];
    entrees.forEach(function(li){
      var lien=ancreDirecte(li),
          dansSeance=!etat.courante||li.getAttribute('data-seance')===etat.courante;
      li._m=dansSeance&&!!q&&!!lien&&normaliser(lien.textContent).indexOf(q)!==-1;
    });
    function descendant(li){
      var found=li.querySelectorAll('li');
      for(var i=0;i<found.length;i++){if(found[i]._m){return true;}}
      return false;
    }
    function ascendant(li){
      var parent=li.parentElement;
      while(parent){
        if(parent.tagName==='LI'&&parent._m){return true;}
        parent=parent.parentElement;
      }
      return false;
    }
    entrees.forEach(function(li){
      var lien=ancreDirecte(li),
          dansSeance=!etat.courante||li.getAttribute('data-seance')===etat.courante,
          montrer=dansSeance&&(!q||li._m||descendant(li)||ascendant(li));
      li.hidden=!montrer;
      if(montrer&&lien){visibles.push(lien);}
    });
    var nav=document.querySelector('.col-sommaire nav.toc');
    if(nav){
      Array.prototype.slice.call(nav.querySelectorAll('ul')).forEach(function(ul){
        var enfants=Array.prototype.slice.call(ul.children);
        ul.hidden=enfants.length>0&&enfants.every(function(child){return child.hidden;});
      });
    }
    if(compte){
      compte.textContent=!q?'':visibles.length===0?'Aucun résultat':
        visibles.length===1?'1 résultat':visibles.length+' résultats';
    }
    return visibles;
  }
  function majNavigation(){
    if(!navSeances||seances.length<2){return;}
    var idx=etat.index;
    var indexPrec=idx<0?0:Math.max(0,idx-1);
    var indexSuiv=idx<0?0:Math.min(seances.length-1,idx+1);
    var precedent=seances[indexPrec],
        suivant=seances[indexSuiv];
    if(lienPrec){
      lienPrec.href=urlPourSeance(etat.courante,precedent.ancre);
      if(idx<=0){lienPrec.setAttribute('aria-disabled','true');}
      else{lienPrec.removeAttribute('aria-disabled');}
      var textePrec=lienPrec.querySelector('span');
      if(textePrec){textePrec.textContent=precedent.titre;}
    }
    if(lienSuiv){
      lienSuiv.href=urlPourSeance(etat.courante,suivant.ancre);
      if(idx===seances.length-1){lienSuiv.setAttribute('aria-disabled','true');}
      else{lienSuiv.removeAttribute('aria-disabled');}
      var texteSuiv=lienSuiv.querySelector('span');
      if(texteSuiv){texteSuiv.textContent=suivant.titre;}
    }
    if(selectSeance){selectSeance.value=etat.courante||'';}
    navSeances.hidden=modeCourante==='pdf';
  }
  function offsetBandeau(){
    var h=document.querySelector('header.site');
    return (h?h.getBoundingClientRect().height:0)+16;
  }
  function entreesVisibles(){
    var paires=[];
    liens.forEach(function(lien){
      var li=ancreDirecte(lien),
          cible=ancreDepuisHash(lien.getAttribute('href'));
      if(li&&!li.hidden&&cible&&(!blocDe(cible)||!blocDe(cible).hidden)){
        paires.push({lien:li,cible:cible});
      }
    });
    return paires;
  }
  function reinitialiserScrollSpy(){
    if(actif){
      actif.classList.remove('active');
      actif.removeAttribute('aria-current');
    }
    actif=null;
  }
  function mettreAJour(){
    planifie=false;
    if(modeCourante==='pdf'){return;}
    var paires=entreesVisibles();
    if(!paires.length){
      reinitialiserScrollSpy();
      return;
    }
    var seuil=offsetBandeau()+8,
        courant=0;
    for(var i=0;i<paires.length;i++){
      if(paires[i].cible.getBoundingClientRect().top<=seuil){courant=i;}
    }
    if(window.innerHeight+window.scrollY>=document.body.scrollHeight-2){
      courant=paires.length-1;
    }
    if(paires[courant].lien===actif){return;}
    reinitialiserScrollSpy();
    actif=paires[courant].lien;
    actif.classList.add('active');
    actif.setAttribute('aria-current','location');
    if(sommaire&&sommaire.scrollHeight>sommaire.clientHeight){
      var haut=actif.offsetTop,
          bas=haut+actif.offsetHeight;
      if(haut<sommaire.scrollTop){sommaire.scrollTop=haut-8;}
      else if(bas>sommaire.scrollTop+sommaire.clientHeight){
        sommaire.scrollTop=bas-sommaire.clientHeight+8;
      }
    }
  }
  function planifier(){
    if(planifie){return;}
    planifie=true;
    window.requestAnimationFrame(mettreAJour);
  }
  function actualiserEtat(options){
    options=options||{};
    var u=new URL(window.location.href),
        href=u.toString();
    if(!options.force&&href===etat.dernierHref){return;}
    etat.dernierHref=href;
    etat.demandee=u.searchParams.get('seance');
    if(etat.demandee===''){
      u.searchParams.delete('seance');
      try{window.history.replaceState(null,'',u.toString());}catch(e){}
      etat.dernierHref=u.toString();
    }
    etat.courante=null;
    etat.index=-1;
    for(var i=0;i<seances.length;i++){
      if(seances[i].cle===etat.demandee){
        etat.courante=seances[i].cle;
        etat.index=i;
        break;
      }
    }
    if(!etat.demandee&&etat.index<0&&u.hash){
      var cleDuHash=sourceSeanceKey(ancreDepuisHash(u.hash));
      for(var j=0;j<seances.length;j++){
        if(seances[j].cle===cleDuHash){etat.index=j;break;}
      }
    }
    var inconnue=!!etat.demandee&&!etat.courante;
    erreurTexte.textContent=inconnue?'Séance introuvable : '+etat.demandee+'.':'';
    if(inconnue){
      u.searchParams.delete('seance');
      try{window.history.replaceState(null,'',u.toString());}catch(e){}
      etat.dernierHref=u.toString();
    }
    var ancre=u.hash?ancreDepuisHash(u.hash):null;
    if(etat.courante&&ancre&&sourceSeanceKey(ancre)!==etat.courante){
      u.hash='';
      try{window.history.replaceState(null,'',u.toString());}catch(e){}
      etat.dernierHref=u.toString();
    }
    Object.keys(blocsParCle).forEach(function(cle){
      blocsParCle[cle].hidden=!!etat.courante&&cle!==etat.courante;
    });
    erreur.hidden=!inconnue;
    appliquerFiltre();
    majNavigation();
    mettreAJour();
    if(options.focusAncre){
      var cible=ancreDepuisHash(options.focusAncre);
      if(cible&&(!blocDe(cible)||!blocDe(cible).hidden)){
        cible.setAttribute('tabindex','-1');
        cible.focus({preventScroll:true});
        cible.scrollIntoView();
      }
    }
  }
  function choisirSeance(cle,ancre,focusUtilisateur){
    var u=new URL(window.location.href);
    if(cle){
      u.searchParams.set('view','doc');
      u.searchParams.set('seance',cle);
    }else{
      u.searchParams.delete('seance');
    }
    if(ancre){u.hash=ancre;}
    try{window.history.pushState(null,'',u.toString());}catch(e){}
    actualiserEtat({force:true,focusAncre:focusUtilisateur&&ancre?'#'+ancre:null});
  }
  function seanceDepuisClic(lien,direction){
    if(lien.getAttribute('aria-disabled')==='true'){return;}
    var base=etat.index<0?(direction>0?-1:0):etat.index;
    var cible=seances[Math.max(0,Math.min(seances.length-1,base+direction))];
    choisirSeance(etat.courante?cible.cle:null,cible.ancre,true);
  }

  if(selectSeance&&seances.length){
    seances.forEach(function(seance){
      var option=document.createElement('option');
      option.value=seance.cle;
      option.textContent=seance.titre;
      selectSeance.appendChild(option);
    });
    selectSeance.addEventListener('change',function(){
      var value=selectSeance.value,
          trouve=null;
      seances.forEach(function(seance){if(seance.cle===value){trouve=seance;}});
      if(trouve){choisirSeance(trouve.cle,trouve.ancre,true);}
      else{choisirSeance('', '', false);}
    });
  }
  if(btnToutes){
    btnToutes.addEventListener('click',function(){
      choisirSeance('', '', false);
      selectSeance.focus({preventScroll:true});
    });
  }
  if(lienPrec){
    lienPrec.addEventListener('click',function(ev){
      ev.preventDefault();
      seanceDepuisClic(lienPrec,-1);
    });
  }
  if(lienSuiv){
    lienSuiv.addEventListener('click',function(ev){
      ev.preventDefault();
      seanceDepuisClic(lienSuiv,1);
    });
  }
  bDoc.addEventListener('click',function(){changerMode('doc');});
  bPdf.addEventListener('click',function(){changerMode('pdf');});
  if(bRapport){bRapport.addEventListener('click',function(){window.location.href='rapport.html';});}
  window.addEventListener('popstate',function(){actualiserEtat();});
  window.addEventListener('hashchange',function(){actualiserEtat();});

  var bToc=document.getElementById('btn-toc'),
      colonne=document.getElementById('sommaire'),
      pointRupture=window.matchMedia&&window.matchMedia('(min-width: 1000px)');
  function replierToc(){return pointRupture&&pointRupture.matches;}
  function appliquerToc(ouvert){
    if(!colonne||!bToc){return;}
    colonne.hidden=!ouvert;
    bToc.setAttribute('aria-expanded',ouvert?'true':'false');
  }
  if(bToc&&colonne){
    bToc.addEventListener('click',function(){appliquerToc(colonne.hidden);});
    appliquerToc(replierToc());
    if(pointRupture&&pointRupture.addEventListener){
      pointRupture.addEventListener('change',function(){appliquerToc(replierToc());});
    }else if(pointRupture&&pointRupture.addListener){
      pointRupture.addListener(function(){appliquerToc(replierToc());});
    }
    colonne.addEventListener('click',function(ev){
      var lien=ev.target&&ev.target.closest?ev.target.closest('a[href^="#"]'):null;
      if(lien&&!replierToc()){appliquerToc(false);bToc.focus();}
    });
  }

  var reduction=window.matchMedia&&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  document.querySelectorAll('.doc .ancre').forEach(function(ancre){
    ancre.addEventListener('click',function(){
      var url=null;
      try{url=new URL(ancre.getAttribute('href'),window.location.href).toString();}catch(e){}
      if(!url){return;}
      try{
        if(navigator.clipboard&&navigator.clipboard.writeText){
          navigator.clipboard.writeText(url).catch(function(){});
        }
      }catch(e){}
      var retour=document.createElement('span');
      retour.textContent=reduction?'Lien copié.':'Lien copié !';
      retour.setAttribute('role','status');
      retour.classList.add('ancre-retour');
      ancre.parentElement.appendChild(retour);
      window.setTimeout(function(){retour.remove();},1600);
    });
  });
  var champ=document.getElementById('recherche');
  if(champ){
    champ.addEventListener('input',function(){
      appliquerFiltre();
      reinitialiserScrollSpy();
      mettreAJour();
    });
    champ.addEventListener('keydown',function(ev){
      if(ev.key==='Enter'){
        var premiers=appliquerFiltre();
        reinitialiserScrollSpy();
        mettreAJour();
        if(premiers.length){ev.preventDefault();premiers[0].click();}
      }else if(ev.key==='Escape'||ev.key==='Esc'){
        if(champ.value){champ.value='';appliquerFiltre();}
        reinitialiserScrollSpy();
        mettreAJour();
      }
    });
  }

  function appliquerTheme(theme,save){
    var dark=theme==='dark';
    if(dark){document.documentElement.dataset.theme='dark';}
    else{delete document.documentElement.dataset.theme;}
    if(bTheme){
      bTheme.setAttribute('aria-pressed',dark?'true':'false');
      bTheme.setAttribute('aria-label',dark?'Activer le thème clair':'Activer le thème sombre');
    }
    if(save!==false){
      try{localStorage.setItem('cahier-theme',dark?'dark':'light');}catch(e){}
    }
  }
  function themeInitial(){
    try{
      var stocke=localStorage.getItem('cahier-theme');
      if(stocke==='dark'||stocke==='light'){return stocke;}
      if(window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches){return 'dark';}
    }catch(e){}
    return 'light';
  }
  if(bTheme){
    bTheme.addEventListener('click',function(){
      appliquerTheme(document.documentElement.dataset.theme==='dark'?'light':'dark',true);
    });
  }
  appliquerTheme(themeInitial(),false);

  window.addEventListener('scroll',planifier,{passive:true});
  window.addEventListener('resize',planifier,{passive:true});
  ecrireMode(modeInitial(),false);
  actualiserEtat({force:true,focusAncre:null});
})();
```

- [ ] **Step 12: Exécuter les tests verts (3 minutes)**

Run:

```bash
python3 -B -m unittest discover -s tests -p 'test_*.py'
node --test tests/test_app_runtime.js
```

Expected: les deux commandes sortent avec code 0; Python rapporte `OK`; Node ne signale aucun test en échec. Le nombre de listeners `popstate` et `hashchange` est un chacun, indirectement vérifié par le test d’un seul `aria-current`.

- [ ] **Step 13: Construire le site autonome et démarrer le serveur (5 minutes)**

Run:

```bash
TMP_DIR="$(mktemp -d /tmp/cahier-session-view.XXXXXX)"
SITE_DIR="$TMP_DIR/Cahier-De-Laboratoire"
mkdir -p "$SITE_DIR"
typst compile main.typ "$SITE_DIR/cahier.pdf"
python3 -B scripts/build_site.py -o "$TMP_DIR/fragment.html" --toc "$TMP_DIR/toc.html"
python3 scripts/assemble_site.py --toc "$TMP_DIR/toc.html" --fragment "$TMP_DIR/fragment.html" --out "$SITE_DIR/index.html"
if [ -d public/assets ]; then cp -R public/assets/. "$SITE_DIR/assets/"; fi
for source_assets in seances/*/assets; do
  [ -d "$source_assets" ] || continue
  seance_key="$(basename "$(dirname "$source_assets")")"
  mkdir -p "$SITE_DIR/assets/$seance_key"
  cp -R "$source_assets/." "$SITE_DIR/assets/$seance_key/"
done
python3 -B - "$SITE_DIR" "$TMP_DIR/manual-urls.txt" <<'PY'
import re
import sys
from pathlib import Path

site = Path(sys.argv[1])
output = Path(sys.argv[2])
page = (site / "index.html").read_text(encoding="utf-8")
fragment = (site / "index.html").read_text(encoding="utf-8")
match = re.search(r'<h2 id="([^"]+)" data-seance="seance-01">', fragment)
assert match, "seance-01 activity h2 not found"
for required in ("cahier.pdf", "style.css", "app.js", "index.html"):
    assert (site / required).is_file(), required
assert "data-seance=\"contexte\"" in page
base = "http://127.0.0.1:8765/Cahier-De-Laboratoire/index.html"
urls = [
    base,
    base + "?seance=seance-01",
    base + "?seance=seance-01#" + match.group(1),
    base + "?seance=contexte",
    base + "?view=pdf&seance=seance-02",
]
output.write_text("\n".join(urls) + "\n", encoding="utf-8")
print(output)
PY
printf '%s\n' "$TMP_DIR" > /tmp/cahier-session-view.path
python3 -m http.server 8765 --directory "$TMP_DIR" >"$TMP_DIR/server.log" 2>&1 &
printf '%s\n' "$!" > /tmp/cahier-session-view.pid
```

Expected: `SITE_DIR` contient `index.html`, `style.css`, `app.js`, `cahier.pdf` et les assets existants. Seul `$TMP_DIR` reçoit des fichiers. Le serveur est démarré dans ce même shell; `/tmp/cahier-session-view.path` et `/tmp/cahier-session-view.pid` rendent son état explicitement disponible à l’étape manuelle suivante.

- [ ] **Step 14: Valider manuellement les URLs persistées (5 minutes)**

Reprendre le chemin persisté par l’étape précédente; ne pas supposer une variable shell encore active:

```bash
TMP_DIR="$(< /tmp/cahier-session-view.path)"
test -f "$TMP_DIR/manual-urls.txt"
test -f "$TMP_DIR/Cahier-De-Laboratoire/index.html"
```

Ouvrir chaque URL concrete de `$TMP_DIR/manual-urls.txt` et vérifier:

1. La première URL affiche Document complet, précédent désactivé, suivant vers séance 01 et aucune option Contexte.
2. La deuxième n’affiche que séance 01; le bouton PDF mène au PDF global puis Document restaure toutes les séances.
3. La troisième conserve le hash réel d’activité et ne déclenche aucun focus au chargement.
4. La quatrième affiche l’erreur réversible, nettoie l’URL avant l’affichage du panneau et rend le focus au select via le bouton.
5. La cinquième affiche le PDF global et retire `seance`; revenir à Document donne `view=doc`, aucun `seance`, le même hash et toutes les sections visibles.

Arrêter le serveur après validation avec :

```bash
kill "$(< /tmp/cahier-session-view.pid)"
rm -f /tmp/cahier-session-view.path /tmp/cahier-session-view.pid
```

Ne pas assembler dans `public/`.

- [ ] **Step 15: Contrôler la portée (2 minutes)**

Run:

```bash
git status --short
git diff -- scripts/build_site.py tests/test_build_site.py site/template.html site/app.js tests/test_app_runtime.js
```

Expected: seuls les cinq fichiers fonctionnels apparaissent; `M main.typ` et `?? seances/seance-02/` restent les changements protégés; `public/` et `site/style.css` n’ont aucun diff.

**Commit suggéré, non exécuté:** `feat: add shareable exclusive session viewer`

## Manual Alternative Proof

Si le test Node ne peut pas être exécuté dans l’environnement d’implémentation, servez uniquement le même `$TMP_DIR`, ouvrez les cinq URLs extraites et utilisez DevTools:

- `Array.from(document.querySelectorAll('#contenu > .bloc-seance:not([hidden])')).map(node => node.dataset.seance)` doit produire la liste visible attendue.
- Le select doit avoir exactement les valeurs `seance-01` et `seance-02`; `contexte` ne doit jamais y figurer.
- Un `popstate` ou `hashchange` manuel ne doit déplacer aucun élément vers `document.activeElement`.
- Après sélection clavier, `document.activeElement` doit être le h1 choisi et son bloc doit être visible.

Limite: DevTools ne remplace pas les assertions automatisées sur l’ordre message/URL, le nombre de cycles et le contrat PDF; ces points restent couverts par Node.

## Plan Self-Review

- [x] La navigation Document ne retire jamais `seance`; le test couvre la séquence complète, le hash direct et la déduction d’index.
- [x] La query inconnue reste inconnue malgré un hash valide; seul un hash sans query déduit l’index.
- [x] `sommaire` est l’unique `aside.col-sommaire` du fake DOM et le test drawer utilise ce même élément.
- [x] Les étapes runtime sont fonctionnelles et numérotées séquentiellement; aucun remplacement monolithique final n’est demandé.
- [x] Le faux DOM, les événements, les liens, l’historique, les rectangles, `requestAnimationFrame`, le focus et l’audit sont fournis en JavaScript complet.
- [x] `?seance=`, stockage PDF, clé inconnue `contexte`, hash valide, croisé et mal encodé sont testés.
- [x] `popstate` et `hashchange` sont testés séparément et leur couple est exécuté une seule fois.
- [x] Le début exclut Contexte, désactive Précédent et cible la première séance avec Suivant.
- [x] `choisirSeance(cle, ancre, focusUtilisateur)` est cohérent dans le contrat et l’implémentation.
- [x] Le message et l’URL inconnus sont préparés avant `hidden=false`; le bouton reçoit puis cède le focus.
- [x] Les wrappers Python vérifient cardinalité, fermeture et placement des enfants.
- [x] Le cycle URL→filtrage→navigation/sommaire→scroll spy est centralisé; les actions et événements ne l’appellent qu’une fois.
- [x] Les tests couvrent absence, séance connue, inconnue, toutes, navigation, hash, historique, TOC/recherche, focus, base path et PDF.
- [x] Le build manuel utilise un unique `TMP_DIR`, un vrai hash extrait, un PDF, un site assemblé et des assets copiés hors dépôt.
- [x] Aucun marqueur de travail incomplet, symbole indéfini, étape non exécutable ou test dépendant d’un autre travail n’est présent.
- [x] Aucun commit ni build n’est exécuté par la rédaction de ce plan.
