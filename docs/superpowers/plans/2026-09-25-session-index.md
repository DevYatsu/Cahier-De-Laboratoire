# Index des séances — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task by task. Track every checkbox and execute one RED → GREEN slice at a time. Do not batch all tests before implementation.

**Goal:** Afficher par défaut un index accessible listant toutes les séances, puis permettre d’ouvrir une séance seule par clic ou clavier. Une URL `?seance=seance-02` ouvre exclusivement cette séance, tandis que « Toutes les séances » revient à l’index sans routeur ni nouvelle page.

**Architecture:** Le template expose deux régions principales, `#index-seances` et `#vue-doc`, avec un lien d’évitement dont la cible est pilotée par l’état visible. Le runtime transforme les `h1[data-seance]` existants en liens natifs, puis applique exactement cet ordre à chaque cycle : `1. lecture URL/mode → 2. résolution et normalisation de l’état → 3. erreur → 4. blocs → 5. afficherRegions() → 6. filtre TOC → 7. majNavigation() → 8. scroll spy → 9. focus utilisateur`. `afficherRegions()` est l’unique propriétaire de cycle des régions `indexSeances.hidden`, `doc.hidden`, `navSeances.hidden`, `pdf.hidden`, `contenu.hidden`, `tocBarre.hidden` et `sommaire.hidden`; il appelle `appliquerToc` pour le drawer, tandis qu’`afficherMode()` ne fait que fixer le mode et les états `aria-pressed`. Le PDF reste une vue globale explicite; le stockage local ne décide plus du mode au chargement.

**Tech Stack:** HTML5 sémantique, JavaScript navigateur sans dépendance, CSS avec variables et media queries existantes, Node.js 24 built-ins (`node:test`, `node:assert/strict`, `node:vm`, `node:fs`, `node:path`), Python `unittest` pour la non-régression du build existant.

**Spec:** `docs/superpowers/plans/2026-09-25-session-index.md` — Goal, Architecture, URL Contract, File Map, Proof Matrix, Tasks, Final Verification.

## Global Constraints

- Le writer de la feature index ne modifie que `site/template.html`, `site/app.js`, `site/style.css` et `tests/test_app_runtime.js`. Un owner CI distinct ajoute ensuite `node --test tests/test_app_runtime.js` dans `.github/workflows/ci.yml`; il ne modifie aucun fichier de feature. Aucun feature writer n’exige un worktree exclusif ni ne réinitialise les changements de l’autre writer.
- Ne pas modifier `scripts/build_site.py`, `tests/test_build_site.py`, les sources Typst, les artefacts sous `public/`, la configuration, le build ou les dépendances.
- Préserver le viewer, le TOC, la recherche, le scroll spy, les ancres de titres, les liens précédent/suivant, le sélecteur de séance, le thème, le rapport d’activité, le PDF global et les chemins relatifs.
- Ne créer aucune page, aucun routeur, aucun framework et aucune dépendance npm.
- L’index est la vue par défaut; `localStorage['cahier-vue']` ne peut pas remplacer l’index au chargement.
- Seul `?view=pdf` affiche le PDF global. Il retire `seance` de l’URL, conserve le hash et masque index, document, TOC et navigation de séance.
- `?view=doc&seance=seance-02#<h1-id>` affiche le document et seul le bloc `data-seance="seance-02"`. Le hash cible sa propre séance; un hash vers une autre séance connue est retiré.
- Une URL sans `seance` montre l’index. Une ancienne ancre directe vers un `h1` de séance ouvre cette séance de manière exclusive afin de ne pas casser les liens d’ancrage existants.
- `?seance=` est normalisé en absence de paramètre. Une clé inconnue retire `seance` par `replaceState`, conserve `view=doc` si utile, affiche l’erreur au-dessus de l’index et fournit le retour réversible.
- Les liens d’index restent des liens natifs avec `href="?view=doc&seance=<clé>#<h1-id>"`; le runtime n’intercepte que le clic primaire non modifié, pour conserver l’activation clavier, le nouvel onglet et le clic milieu.
- Le focus vers un `h1` est réservé à l’ouverture d’une séance par l’utilisateur. Le focus vers `#index-seances` est réservé au retour explicite par `#btn-index`, l’option « Toutes les séances » ou le bouton d’erreur. Le bouton Document après PDF appelle le même chemin avec `false`, donc sans focus.
- Le chargement direct, `popstate`, `hashchange`, le scroll et le choix PDF ne déplacent jamais le focus.
- `#index-seances`, `#contenu`, `#sommaire`, `#btn-toc`/`#toc-barre`, `#nav-seances` et `#vue-pdf` sont contrôlés pendant le cycle par `afficherRegions`. Un seul `#btn-index` est nécessaire dans le template.
- L’ordre de rendu est fixe: URL/mode, état, erreur, blocs, régions, filtre TOC, labels/select de `majNavigation`, scroll spy, puis focus autorisé. `afficherRegions()` est appelé une fois par cycle après les blocs; `majNavigation()` ne modifie plus aucun `hidden`.
- Le bouton Document après PDF appelle `choisirIndex(false)`: il produit `?view=doc`, supprime `seance` et le hash, affiche l’index et ne déplace jamais le focus.
- En PDF, une ancre ne peut jamais alimenter `etat.courante`. En Document, seule une cible `H1[data-seance]` valide peut ouvrir une séance depuis une ancre; un H2/activité, un id absent, un pourcentage mal encodé ou `contexte` ne déduisent aucune séance.
- Une H1 portant `data-seance="contexte"` est rejetée par la forme `seance-\d{2}`; aucune recherche par `sourceSeanceKey` n’est autorisée pour l’inférence legacy.
- Les changements restent non commités; chaque commit ci-dessous est uniquement suggéré. Chaque feature writer n’écrit que ses fichiers de feature, puis l’owner CI et l’audit conjoint s’exécutent sur le worktree cumulatif.

## URL and Visibility Contract

| URL/state | Index | Document | Blocs visibles | PDF | Focus automatique |
|---|---:|---:|---|---:|---|
| `/index.html` | visible | hidden | aucun | hidden | aucun |
| `?view=doc` | visible | hidden | aucun | hidden | aucun |
| `?seance=seance-02` | hidden | visible | `seance-02` | hidden | aucun |
| `?view=doc&seance=seance-02#seance-02-h1` | hidden | visible | `seance-02` | hidden | aucun au chargement |
| `#seance-02-h1` sans query | hidden | visible | `seance-02` | hidden | aucun |
| `#activite-02`, `#id-absent`, `#contexte` ou hash mal encodé | visible | hidden | aucun | hidden | aucun |
| `?view=pdf` | hidden | hidden | aucun | visible | aucun |
| `?view=pdf#seance-02-h1` | hidden | hidden | aucun | visible | aucun; hash conservé, aucune séance déduite |
| `?view=pdf&seance=seance-02#x` | hidden | hidden | aucun | visible | aucun; `seance` retiré |
| `?view=doc&seance=seance-99` | visible + erreur | hidden | aucun | hidden | aucun |

Retour vers l’index: `?view=doc`, sans `seance` ni hash, afin qu’un hash ne cible pas une région cachée.

## File Map

| File | Responsibility | Boundary |
|---|---|---|
| `site/template.html` | Déclarer l’index, les régions, le lien d’évitement, le retour visible et des états HTML initialisés sans flash du document. | Aucun contenu de séance codé en dur. |
| `site/app.js` | Construire l’index depuis les h1, résoudre l’URL, appliquer la visibilité, gérer clic/natif, historique et focus utilisateur. | Vanilla JS dans l’IIFE existante; aucun router. |
| `site/style.css` | Donner au lien-ligne une surface focusable, un focus visible et un repli sans débordement à 320 px. | Réutiliser les variables et règles existantes; ne pas modifier le viewer. |
| `tests/test_app_runtime.js` | Étendre le faux DOM, faire bubbler les événements, contrôler le breakpoint et tester les comportements observables, l’historique et le focus. | Node built-ins uniquement. |
| `.github/workflows/ci.yml` | Owner CI postérieur aux deux writers: exécuter aussi `node --test tests/test_app_runtime.js`. | Seul fichier CI touché par cet owner; aucun fichier de feature. |
| `scripts/build_site.py` | Fournir le markup existant `h1[data-seance]` et les ancres. | Lecture seulement; aucun changement par le writer index. |

## Exact Interfaces

### HTML contract

```html
<a class="saut" id="saut-region" href="#index-seances">Aller à l’index des séances</a>

<section id="index-seances" aria-labelledby="titre-index-seances" tabindex="-1">
  <h2 id="titre-index-seances">Choisir une séance</h2>
  <ul id="liste-seances" aria-labelledby="titre-index-seances"></ul>
</section>

<nav class="seances" id="nav-seances" aria-label="Navigation entre les séances" hidden>
  <button type="button" id="btn-index" class="bouton">Toutes les séances</button>
  <!-- Les éléments précédent/suivant/sélecteur existants restent inchangés. -->
</nav>

<div class="panneau-pdf" id="vue-pdf" tabindex="-1" hidden>
  <!-- La visionneuse PDF existante reste inchangée. -->
</div>
```

Required attributes:

- `#index-seances`: semantic `section`, named by its h2, programmatically focusable.
- `#liste-seances`: semantic `ul`, empty in the template and populated from valid `h1[data-seance]`.
- Each generated child: `<li data-seance="seance-NN">` containing one full-row native `<a data-seance="seance-NN" href="?view=doc&seance=seance-NN#h1-id">`.
- Link content: one session title span and one visible action span with exact text `Ouvrir la séance`.
- `#contenu`, `#sommaire`, `#toc-barre`, and `#nav-seances`: `tabindex="-1"` only where needed for a skip target; existing document anchors keep their ids.
- `#vue-pdf`: `tabindex="-1"` so the dynamic skip link always targets a programmatically focusable visible region.

### Runtime contract

```javascript
var seances = Array<{
  cle: String,
  titre: String,
  ancre: String,
  activiteAncre: String
}>;

var etat = {
  demandee: String|null,
  courante: String|null,
  index: Number,
  dernierHref: String|null
};

function modePourUrl(url: URL): 'pdf'|'doc' {}
function urlPourSeance(cle: String|null, ancre: String|null): String {}
function construireIndex(): void {}
function seanceDepuisH1(element: Element|null): String|null {}
function afficherMode(mode: 'pdf'|'doc'): void {}
function afficherRegions(): void {}
function majNavigation(): void {}
function majLienEvitement(): void {}
function choisirSeance(cle: String, ancre: String, focusUtilisateur: Boolean): void {}
function choisirIndex(focusUtilisateur: Boolean): void {}
function actualiserEtat(options?: {force?: Boolean, focusAncre?: String|null, focusIndex?: String|null}): void {}
```

Invariants:

- `seances` includes only keys matching `/^seance-\d{2}$/`, in DOM order, and contains no `contexte`.
- `modePourUrl` returns `pdf` only for explicit `view=pdf`; every other URL is `doc`.
- `afficherRegions` is the only state-cycle owner of `indexSeances.hidden`, `doc.hidden`, `navSeances.hidden`, `pdf.hidden`, `contenu.hidden`, `tocBarre.hidden`, and `sommaire.hidden`; it updates the skip link and delegates the TOC drawer’s `aria-expanded` update to `appliquerToc`. No other state-cycle function writes those region properties.
- `afficherMode` writes only `modeCourante` and the Document/PDF `aria-pressed` values. `majNavigation` writes only navigation hrefs, labels, disabled state, and `seance-select.value`; it never writes a `hidden` property.
- The sole visibility order is: resolve URL/state, normalize unknown/empty values, set error text/visibility, set block visibility, call `afficherRegions`, apply TOC filter, call `majNavigation`, update scroll spy, then apply an explicitly authorized focus.
- `choisirSeance` is the only path that focuses a session h1, and only when its third argument is `true`.
- `choisirIndex` is the only path that focuses the index, and only when its argument is `true`.
- `popstate` and `hashchange` call `actualiserEtat()` with no focus option.

## Test Harness Interfaces

Extend `Element` and `runApp` in `tests/test_app_runtime.js` with these exact capabilities before adding the first feature test:

```javascript
dispatch(type, supplied = {}) {
  const event = Object.assign({
    defaultPrevented: false,
    preventDefault() { this.defaultPrevented = true; }
  }, supplied);
  if (!event.target) event.target = this;
  if (!event.currentTarget) event.currentTarget = this;
  let node = this;
  while (node) {
    event.currentTarget = node;
    for (const listener of node.listeners.get(type) || []) listener(event);
    if (event.cancelBubble) break;
    node = node.parentElement;
  }
  return event;
}

focus(options) {
  globalAudit.focusLog.push(this.id);
}

Extend the existing `Element.querySelectorAll` with this selector branch, then extend `closest`:

```javascript
if (selector === 'h1[data-seance]') {
  return values.filter(node =>
    node.tagName === 'H1' &&
    /^seance-\d{2}$/.test(node.getAttribute('data-seance') || '')
  );
}
```

```javascript
closest(selector) {
  let current = this;
  while (current) {
    if (selector === 'a[data-seance]' &&
        current.tagName === 'A' &&
        /^seance-\d{2}$/.test(current.getAttribute('data-seance') || '')) return current;
    if (selector === '.bloc-seance' &&
        current.classList.contains('bloc-seance')) return current;
    if (selector === 'a[href^="#"]' &&
        current.tagName === 'A' && current.href.startsWith('#')) return current;
    current = current.parentElement;
  }
  return null;
}
```

The fixture must register these controls and return them through `ids`:

```javascript
[
  'index-seances', 'titre-index-seances', 'liste-seances', 'saut-region',
  'toc-barre', 'btn-index', 'vue-pdf'
]
```

Every explicit `runApp` URL must begin with `https://example.test/Cahier-De-Laboratoire/index.html`; do not pass a query-relative string. The default remains the same absolute base.

Make `runApp(options)` configure the desktop breakpoint explicitly. The same fake `matchMedia(query)` must still return `false` for reduced-motion:

```javascript
const desktopBreakpoint = options.desktopBreakpoint !== false;
const mediaListeners = new Map();
function fakeMedia(query, matches) {
  const listeners = [];
  const media = {
    matches,
    addEventListener(type, listener) {
      if (type === 'change') listeners.push(listener);
    },
    addListener(listener) { listeners.push(listener); }
  };
  mediaListeners.set(query, { media, listeners });
  return media;
}
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
  matchMedia(query) {
    return fakeMedia(
      query,
      query === '(min-width: 1000px)' ? desktopBreakpoint : false
    );
  }
};
```

Initialize the fixture to mirror the new template:

```javascript
article.hidden = true;
ids.get('index-seances').hidden = false;
ids.get('sommaire').hidden = true;
ids.get('toc-barre').hidden = true;
ids.get('nav-seances').hidden = true;
ids.get('vue-pdf').hidden = true;
ids.get('seance-erreur').hidden = true;
```

Add these helpers after the runtime starts:

```javascript
function indexItems() {
  return ids.get('liste-seances').children;
}

function keyboardActivate(link) {
  // Un lien natif produit un click après une activation clavier Enter.
  link.dispatch('click', { button: 0 });
}

function indexLinks() {
  return indexItems().map(item => item.children[0]);
}
```

Return `ids`, `indexItems` and `indexLinks` from `runApp`, retain `fire('popstate')` and `fire('hashchange')`, and keep `focusLog`, `historyAudit`, `hiddenByKey`, and `writeCount` unchanged. Return the exact fake lookup as `documentGetElementById(id)`, backed by:

```javascript
function documentGetElementById(id) {
  return ids.get(id) || body.descendants().find(node => node.id === id) || null;
}
```

After the RED propagation check, the fake event’s `target` is the dispatched link and `currentTarget` changes at each ancestor. The detached-H1 test appends the unregistered H1 to `#contenu` and asserts `ids.has(id) === false`; it must not add the H1 to `ids`. A second negative case places an H1 in a `.bloc-seance` wrapper whose key is not in `blocsParCle`; neither target may be inserted into `ids`. The production fake `document.getElementById` calls `documentGetElementById`, proving the target is found only through the descendant fallback. Return a media helper that mutates the stored `matches` and invokes only listeners registered for the requested query:

```javascript
setMedia(query, matches) {
  const entry = mediaListeners.get(query);
  if (!entry) return;
  entry.media.matches = matches;
  for (const listener of entry.listeners) listener({ type: 'change', matches });
}
```

This enables a dedicated media-listener test without counting `appliquerToc(replierToc())` across the whole file.

## Proof Matrix

| Requirement | Executable proof in `tests/test_app_runtime.js` |
|---|---|
| Index default | `default route shows the semantic index and hides document chrome` |
| One index item per h1 session | `index contains one native session link per h1` |
| Event propagation | `delegated index click propagates from link to session list` |
| Click opening | `primary click opens exactly one session and focuses its h1` |
| Keyboard opening | `keyboard activation opens exactly one session` |
| Direct URL | `known session query shows only that session without focus` |
| Return button | `session return button returns to the index and moves focus` |
| “Toutes les séances” option | `all sessions option returns to the index and moves focus` |
| Unknown query | `unknown session shows reversible error above the index` |
| `popstate` | `popstate between index and session does not focus` |
| `hashchange` | `hashchange within a session does not focus` |
| Combined history | `popstate followed by hashchange runs one state cycle` |
| Legacy anchors | Delete `direct session hash without query derives navigation index`; use `legacy session hash opens only its session without focus` with an absolute URL and exclusive session assertions. |
| PDF | `explicit PDF remains global and hides index and document`; `PDF to Document returns to index without focus`; `PDF never derives a session from a hash` |
| Invalid hash | `document index ignores activity, malformed, and unknown hashes` |
| Media listener | `desktop media listener routes breakpoint changes through afficherRegions`; no global call-count assertion. |
| Visibility ownership/order | `region visibility is settled before navigation and scroll-spy updates` |
| Default beats stored PDF | `default route ignores stored PDF preference` |
| TOC/activities hidden | Assertions in the default-index test over `#sommaire`, `#toc-barre`, and all blocks |
| Skip target | Assertions in default, session, and PDF tests over `#saut-region` |
| Template semantics | `template exposes index, skip, return, and focusable visible regions` |
| CSS hidden regions | `session index has visible focus and mobile-safe rules` asserts `.col-sommaire[hidden]` and `.toc-barre[hidden]` use `display:none`. |
| Focus visible | Static assertion for `#liste-seances a:focus-visible` in the CSS contract test |
| Mobile 320 px | Static assertions for unbreakable titles and the `@media (max-width:480px)` row rule |
| Theme/responsive preservation | Existing theme code untouched; final diff review confirms no selector outside index/return changes |

---

### Task 1: Add the semantic regions and RED default-index test

**Files:**
- Modify: `tests/test_app_runtime.js`
- Modify: `site/template.html`

**Interfaces produced:** `index-seances`, `liste-seances`, `saut-region`, `btn-index`, and an initially hidden viewer.

- [ ] **Step 1: Add only the new runtime IDs needed to expose the old dispatch failure (3 minutes)**

Register the new controls and return `ids`, but deliberately leave `Element.dispatch` unchanged for this RED step. Do not yet add `indexItems`/`indexLinks`; the propagation test creates a local `li` and `a`, appends both under `#liste-seances`, and proves the parent listener is missed by the old dispatch.

- [ ] **Step 2: Write the RED propagation test before the delegated listener exists (4 minutes)**

Add:

```javascript
test('delegated index click propagates from link to session list', () => {
  const app = runApp();
  const list = app.ids.get('liste-seances');
  const item = element('li');
  const link = element('a', 'Ouvrir la séance');
  item.setAttribute('data-seance', 'seance-01');
  link.setAttribute('data-seance', 'seance-01');
  link.setAttribute('href', '?view=doc&seance=seance-01#seance-01-h1');
  item.appendChild(link);
  list.appendChild(item);
  let received = null;
  list.addEventListener('click', event => { received = event; });
  link.dispatch('click', { button: 0 });
  assert.equal(received, null);
});
```

Expected RED with the old non-bubbling `dispatch`: `received` remains `null` even though the test listener is attached to the delegated ancestor. The GREEN version of this test is the same test after the harness bubbles and sets `target === link` and `currentTarget === #liste-seances`; replace the final assertion with:

```javascript
assert.equal(received.target, link);
assert.equal(received.currentTarget, app.ids.get('liste-seances'));
```

The feature click test in Task 3 is the behavioral proof that the runtime delegate runs; this test is the isolated harness proof. Do not add a production listener merely to make this harness test pass.

- [ ] **Step 3: Make event dispatch bubble and prove the propagation test GREEN (4 minutes)**

Replace the old `Element.dispatch` with the exact bubbling `dispatch` contract above. Apply `focus`, `closest`, configurable `matchMedia`, hidden initialization, `indexItems`, `keyboardActivate`, and `indexLinks` now that the isolated harness failure is proven, then run:

```bash
node --test --test-name-pattern='delegated index click propagates' tests/test_app_runtime.js
```

Expected: PASS; the test’s parent listener receives the same event with `target === link` and `currentTarget === #liste-seances`. This isolates the harness fix before any runtime delegate exists.

- [ ] **Step 4: Write the RED default-index test (3 minutes)**

Replace the old test `absent session keeps the full document` with:

```javascript
test('default route shows the semantic index and hides document chrome', () => {
  const app = runApp();
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.equal(app.ids.get('contenu').hidden, true);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('toc-barre').hidden, true);
  assert.equal(app.ids.get('nav-seances').hidden, true);
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': true
  });
  assert.equal(app.ids.get('saut-region').getAttribute('href'), '#index-seances');
  assert.deepEqual(app.focusLog, []);
});
```

- [ ] **Step 5: Run the focused RED default test (2 minutes)**

Run:

```bash
node --test --test-name-pattern='default route shows the semantic index' tests/test_app_runtime.js
```

Expected: FAIL because `#index-seances` does not exist in the current fake DOM or template and because the current runtime leaves `#contenu` visible.

- [ ] **Step 6: Add the static semantic regions to the template (4 minutes)**

In `site/template.html`:

1. Add `id="saut-region"`, `href="#index-seances"`, and text `Aller à l’index des séances` to the existing skip link.
2. Keep `#seance-erreur` before the new index so the error remains above it.
3. Insert the exact `#index-seances` and empty `#liste-seances` markup from the HTML contract between the error and `#toc-barre`.
4. Add `id="toc-barre"` and `hidden` to the existing TOC bar.
5. Add `hidden` to `#vue-doc`.
6. Add `#btn-index` as the first child of `#nav-seances`, before the previous link; keep `hidden` on the nav.
7. Add `tabindex="-1"` to `#vue-pdf`.
8. Do not hard-code any session item or modify `<!--TOC-->` or `<!--FRAGMENT-->`.

- [ ] **Step 7: Run the RED test again to isolate runtime behavior (2 minutes)**

Run the command from Step 5.

Expected: FAIL only because `site/app.js` still exposes the document and does not create index rows.

**Commit suggéré, non exécuté:** `feat: add semantic session index shell`

---

### Task 2: Build the index and make it the GREEN default view

**Files:**
- Modify: `tests/test_app_runtime.js`
- Modify: `site/app.js`

**Interfaces produced:** `construireIndex`, `afficherRegions`, `majLienEvitement`, index rows and stable default visibility.

- [ ] **Step 1: Write the RED index-content test (3 minutes)**

Add:

```javascript
test('index contains one native session link per h1', () => {
  const app = runApp();
  assert.deepEqual(app.indexItems().map(item => item.getAttribute('data-seance')), [
    'seance-01', 'seance-02'
  ]);
  assert.deepEqual(app.indexLinks().map(link => link.getAttribute('href')), [
    '?view=doc&seance=seance-01#seance-01-h1',
    '?view=doc&seance=seance-02#seance-02-h1'
  ]);
  assert.deepEqual(app.indexItems()[0].children[0].children.map(node => node.textContent), [
    'Séance 01', 'Ouvrir la séance'
  ]);
  assert.equal(app.indexItems()[1].querySelectorAll('span')[1].textContent, 'Ouvrir la séance');
});
```

- [ ] **Step 2: Run the RED test (2 minutes)**

Run:

```bash
node --test --test-name-pattern='index contains one native session link' tests/test_app_runtime.js
```

Expected: FAIL with an empty `#liste-seances` list.

- [ ] **Step 3: Register the new DOM references and construct rows (4 minutes)**

In the top `var` declaration in `site/app.js`, add:

```javascript
indexSeances=document.getElementById('index-seances'),
listeSeances=document.getElementById('liste-seances'),
sautRegion=document.getElementById('saut-region'),
contenu=document.getElementById('contenu'),
tocBarre=document.getElementById('toc-barre'),
btnIndex=document.getElementById('btn-index')
```

After `urlPourSeance` is defined, add:

```javascript
function construireIndex(){
  if(!listeSeances)return;
  seances.forEach(function(seance){
    var item=document.createElement('li'),
        lien=document.createElement('a'),
        titre=document.createElement('span'),
        action=document.createElement('span');
    item.setAttribute('data-seance',seance.cle);
    lien.setAttribute('data-seance',seance.cle);
    lien.setAttribute('href',urlPourSeance(seance.cle,seance.ancre));
    titre.setAttribute('class','seance-index-titre');
    titre.textContent=seance.titre;
    action.setAttribute('class','seance-index-action');
    action.textContent='Ouvrir la séance';
    lien.appendChild(titre);
    lien.appendChild(action);
    item.appendChild(lien);
    listeSeances.appendChild(item);
  });
}
```

Call `construireIndex()` exactly once in the Task 2 implementation’s bottom startup block, immediately before the first `afficherMode(modeInitial())` and before `actualiserEtat({force:true,focusAncre:null})`:

```javascript
construireIndex();
afficherMode(modeInitial());
actualiserEtat({force:true,focusAncre:null});
```

At the time this bottom block executes, all three functions are already defined and initialized. Do not call `construireIndex()` from the test, from a helper defined before it, or from a function that may run earlier. Task 2’s GREEN test therefore runs against the real constructed list and callable `actualiserEtat`.

- [ ] **Step 4: Replace stored-mode resolution with explicit URL mode (3 minutes)**

Replace `modePourUrl` with:

```javascript
function modePourUrl(u){
  return u.searchParams.get('view')==='pdf'?'pdf':'doc';
}
```

Replace `afficherMode` so it no longer writes `pdf.hidden` or `doc.hidden`:

```javascript
function afficherMode(mode){
  modeCourante=mode;
  bPdf.setAttribute('aria-pressed',mode==='pdf'?'true':'false');
  bDoc.setAttribute('aria-pressed',mode==='pdf'?'false':'true');
}
```

Replace startup `ecrireMode(modeInitial(),false)` with `afficherMode(modeInitial())`. Keep `ecrireMode` only for URL mutation, not visibility: remove `afficherMode(mode)` and all `hidden` writes from it. Remove every read and write of `cahier-vue`.

- [ ] **Step 5: Give `afficherRegions` exclusive ownership of all visible regions (4 minutes)**

Use:

```javascript
function afficherRegions(){
  var pdfVisible=modeCourante==='pdf',
      seanceVisible=!pdfVisible&&!!etat.courante;
  indexSeances.hidden=!seanceVisible&&!pdfVisible;
  doc.hidden=!seanceVisible;
  contenu.hidden=!seanceVisible;
  tocBarre.hidden=!seanceVisible;
  navSeances.hidden=!seanceVisible;
  pdf.hidden=!pdfVisible;
  if(seanceVisible){appliquerToc(replierToc());}
  else{appliquerToc(false);}
  majLienEvitement();
}
```

Remove `pdf.hidden` and `doc.hidden` from `afficherMode`. Remove the `navSeances.hidden=modeCourante==='pdf'` line from `majNavigation`; `majNavigation` keeps only href, label, `aria-disabled`, and select-value updates. In the index/PDF branches, `afficherRegions` must call `appliquerToc(false)`, which writes both `sommaire.hidden=true` and `aria-expanded=false`. Remove the startup call `appliquerToc(replierToc())`; the only TOC initialization per state cycle is the `appliquerToc(replierToc())` call inside the visible-session branch of `afficherRegions`.

- [ ] **Step 6: Document and enforce the unique state order (3 minutes)**

Inside `actualiserEtat`, use this order without moving work across functions:

```javascript
var u=new URL(window.location.href);
appliquerModeDepuisUrl(u);       // 1. mode + PDF URL cleanup
var href=u.toString();
if(!options.force&&href===etat.dernierHref)return;
etat.demandee=u.searchParams.get('seance');
// 2. normalize empty/unknown keys and resolve courante/index
etat.dernierHref=u.toString();   // store only the final normalized href
// 3. set erreurTexte, then erreur.hidden
// 4. set every bloc.hidden
afficherRegions();               // 5. sole owner of region visibility
appliquerFiltre();               // 6. TOC entries
majNavigation();                 // 7. navigation values only
mettreAJour();                   // 8. scroll spy
// 9. focus only from options set by an explicit user action
```

Add a source-level ownership test:

```javascript
test('region visibility is settled before navigation and scroll-spy updates', () => {
  // This test slices the exact two-space IIFE function closures in site/app.js.
  const source = fs.readFileSync(
    path.join(__dirname, '..', 'site', 'app.js'), 'utf8'
  );
  const regionStart = source.indexOf('function afficherRegions');
  const regionEnd = source.indexOf('\n  }', regionStart) + 4;
  const navigationStart = source.indexOf('function majNavigation');
  const navigationEnd = source.indexOf('\n  }', navigationStart) + 4;
  assert.ok(regionStart >= 0 && regionEnd > regionStart);
  assert.ok(navigationStart > regionEnd && navigationEnd > navigationStart);
  const region = source.slice(regionStart, regionEnd);
  assert.match(region, /if\(seanceVisible\)\{appliquerToc\(replierToc\(\)\);\}/);
  assert.match(region, /else\{appliquerToc\(false\);\}/);
  assert.doesNotMatch(source, /^\s{4}appliquerToc\(replierToc\(\)\);/m);
  assert.doesNotMatch(region, /navSeances\.hidden\s*=\s*modeCourante/);
  const navigation = source.slice(navigationStart, navigationEnd);
  assert.doesNotMatch(navigation, /(?:indexSeances|doc|navSeances|pdf|contenu|tocBarre|sommaire)\.hidden\s*=/);
  const legacy = source.slice(
    source.indexOf('function seanceDepuisH1'),
    source.indexOf('function afficherMode')
  );
  assert.match(legacy, /var bloc=element\.parentElement/);
  assert.match(legacy, /blocsParCle\[cle\]!==bloc/);
  const mediaRegistration = source.slice(
    source.indexOf('function reagirAuPointRupture'),
    source.indexOf('var reduction')
  );
  assert.match(mediaRegistration, /function reagirAuPointRupture\(\)\{\s*afficherRegions\(\);\s*\}/);
  assert.doesNotMatch(mediaRegistration, /appliquerToc\(replierToc\(\)\);/);
  const modeStart = source.indexOf('function afficherMode');
  const modeBodyEnd = source.indexOf('\n  }', modeStart) + 4;
  assert.ok(modeStart >= 0 && modeBodyEnd > modeStart);
  const mode = source.slice(modeStart, modeBodyEnd);
  assert.match(region, /(?:indexSeances|doc|navSeances|pdf|contenu|tocBarre)\.hidden\s*=/);
  assert.match(region, /majLienEvitement\(\);/);
  assert.doesNotMatch(mode, /(?:indexSeances|doc|navSeances|pdf|contenu|tocBarre|sommaire)\.hidden\s*=/);
  const writeModeStart = source.indexOf('function ecrireMode');
  const writeModeEnd = source.indexOf('\n  }', writeModeStart) + 4;
  assert.ok(writeModeStart >= 0 && writeModeEnd > writeModeStart);
  const writeMode = source.slice(writeModeStart, writeModeEnd);
  assert.doesNotMatch(writeMode, /(?:indexSeances|doc|navSeances|pdf|contenu|tocBarre|sommaire)\.hidden\s*=/);
  const stateStart = source.indexOf('function actualiserEtat');
  const chooseStart = source.indexOf('function choisirSeance');
  assert.ok(stateStart >= 0 && chooseStart > stateStart);
  const order = source.slice(stateStart, chooseStart);
  const regionCall = order.indexOf('afficherRegions();');
  const filterCall = order.indexOf('appliquerFiltre();');
  const navigationCall = order.indexOf('majNavigation();');
  const scrollCall = order.indexOf('mettreAJour();');
  assert.ok(
    regionCall >= 0 && regionCall < filterCall &&
    filterCall < navigationCall && navigationCall < scrollCall
  );
});
```

The runtime behavior remains covered by the index/session/PDF assertions; this test prevents ownership regressions.

- [ ] **Step 7: Add exact skip-link rendering (3 minutes)**

Add:

```javascript
function majLienEvitement(){
  if(!sautRegion)return;
  var cible='#index-seances',
      texte='Aller à l’index des séances';
  if(modeCourante==='pdf'){cible='#vue-pdf';texte='Aller au PDF';}
  else if(etat.courante){cible='#contenu';texte='Aller à la séance';}
  sautRegion.setAttribute('href',cible);
  sautRegion.textContent=texte;
}
```

`afficherMode` owns only mode and `aria-pressed`; `afficherRegions` remains the only visibility owner.

- [ ] **Step 8: Make all blocks hidden outside an exclusive session (3 minutes)**

In `actualiserEtat`, replace the block loop with:

```javascript
Object.keys(blocsParCle).forEach(function(cle){
  blocsParCle[cle].hidden=modeCourante==='pdf'||!etat.courante||cle!==etat.courante;
});
```

Call `afficherRegions` before `appliquerFiltre`, `majNavigation`, and `mettreAJour`.

- [ ] **Step 9: Run the two GREEN tests (2 minutes)**

Run:

```bash
node --test --test-name-pattern='default route shows|index contains one native session link' tests/test_app_runtime.js
```

Expected: both tests PASS; `#contenu` and every activity block are hidden on the default route.

**Commit suggéré, non exécuté:** `feat: default to generated session index`

---

### Task 3: Open one session by mouse, keyboard, and direct URL

**Files:**
- Modify: `tests/test_app_runtime.js`
- Modify: `site/app.js`

**Interfaces produced:** modified-primary click interception, native-link fallback, exclusive known-session rendering, user-only h1 focus.

- [ ] **Step 1: Write RED click and keyboard tests (5 minutes)**

Add:

```javascript
test('primary click opens exactly one session and focuses its h1', () => {
  const app = runApp();
  const link = app.indexLinks()[1];
  const event = link.dispatch('click', { button: 0 });
  assert.equal(event.defaultPrevented, true);
  assert.equal(new URL(app.location.href).search,
               '?view=doc&seance=seance-02');
  assert.equal(new URL(app.location.href).hash, '#seance-02-h1');
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('contenu').hidden, false);
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': false
  });
  assert.deepEqual(app.focusLog, ['seance-02-h1']);
  assert.deepEqual(app.scrollLog, ['seance-02-h1']);
});

test('keyboard activation opens exactly one session', () => {
  const app = runApp();
  app.keyboardActivate(app.indexLinks()[0]);
  assert.equal(new URL(app.location.href).search,
               '?view=doc&seance=seance-01');
  assert.equal(new URL(app.location.href).hash, '#seance-01-h1');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': false, 'seance-02': true
  });
  assert.deepEqual(app.focusLog, ['seance-01-h1']);
});
```

The event object is already created by the bubbling `dispatch` contract in Task 1. Do not replace it with the old target-less implementation.

- [ ] **Step 2: Write the RED direct-URL test and update the old direct-query assertions (4 minutes)**

Replace the known-session test with:

```javascript
test('known session query shows only that session without focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-02#seance-02-h1'
  });
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, false);
  assert.equal(app.ids.get('contenu').hidden, false);
  assert.equal(app.ids.get('sommaire').hidden, false);
  assert.equal(app.ids.get('toc-barre').hidden, false);
  assert.equal(app.ids.get('nav-seances').hidden, false);
  assert.equal(app.ids.get('saut-region').getAttribute('href'), '#contenu');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': false
  });
  assert.equal(app.ids.get('seance-select').value, 'seance-02');
  assert.deepEqual(app.focusLog, []);
});
```

- [ ] **Step 3: Run the three RED tests (2 minutes)**

Run:

```bash
node --test --test-name-pattern='primary click|keyboard activation|known session query' tests/test_app_runtime.js
```

Expected: FAIL because the current runtime does not intercept index links and does not toggle index/document regions.

- [ ] **Step 4: Delegate modified-primary index clicks (4 minutes)**

After `choisirSeance` is defined, add one listener to `#liste-seances`:

```javascript
if(listeSeances){
  listeSeances.addEventListener('click',function(ev){
    if(ev.defaultPrevented||ev.metaKey||ev.ctrlKey||ev.shiftKey||ev.altKey||
       (typeof ev.button==='number'&&ev.button!==0))return;
    var lien=ev.target&&ev.target.closest?ev.target.closest('a[data-seance]'):null,
        cle=lien&&lien.getAttribute('data-seance'),
        trouve=null;
    if(!cle)return;
    seances.forEach(function(seance){if(seance.cle===cle){trouve=seance;}});
    if(!trouve)return;
    ev.preventDefault();
    choisirSeance(trouve.cle,trouve.ancre,true);
  });
}
```

Do not add a separate production `keydown` handler: native anchors already generate the same click on Enter. The test helper models that browser behavior explicitly.

- [ ] **Step 5: Preserve native modified/middle clicks (2 minutes)**

Add:

```javascript
test('modified index click keeps native navigation behavior', () => {
  const app = runApp();
  const event = app.indexLinks()[0].dispatch('click', {
    button: 0, metaKey: true
  });
  assert.equal(event.defaultPrevented, false);
  assert.equal(new URL(app.location.href).search, '');
  assert.deepEqual(app.focusLog, []);
});
```

- [ ] **Step 6: Make direct URL resolution exclusive and H1-only (4 minutes)**

Add:

```javascript
function seanceDepuisH1(element){
  if(!element||element.tagName!=='H1')return null;
  var cle=element.getAttribute('data-seance')||'';
  if(!/^seance-\d{2}$/.test(cle))return null;
  var bloc=element.parentElement;
  if(!bloc||!bloc.classList||!bloc.classList.contains('bloc-seance')||
     bloc.getAttribute('data-seance')!==cle||
     blocsParCle[cle]!==bloc)return null;
  return seances.some(function(seance){
    return seance.cle===cle&&seance.ancre===element.id;
  })?cle:null;
}
```

In `actualiserEtat`, preserve the known-key lookup, but allow legacy hash inference only in Document and only for a valid session H1:

```javascript
var ancreCourante=u.hash?ancreDepuisHash(u.hash):null;
if(modeCourante==='doc'&&!etat.courante&&!etat.demandee&&u.hash){
  var cleDuH1=seanceDepuisH1(ancreCourante);
  for(var j=0;j<seances.length;j++){
    if(seances[j].cle===cleDuH1){
      etat.courante=seances[j].cle;
      etat.index=j;
      break;
    }
  }
}
```

Do not use `sourceSeanceKey` for this inference. Require both exact guards: `element.parentElement === bloc` and `blocsParCle[cle] === bloc`, where `bloc` is the element’s direct `.bloc-seance[data-seance]` parent.

The helper also requires `element.id` to equal the registered `seances[].ancre`; a detached or unknown H1 cannot activate a session. Extend the fake `Element.querySelectorAll('h1[data-seance]')` and make `document.getElementById` find detached descendants so both negative tests reach these guards. The unregistered-wrapper test must use a different key not present in `blocsParCle`, proving the identity check rather than only a class/attribute check. Retain cross-session hash removal only when a valid `?seance` is already resolved. In PDF, `etat.courante` remains `null` regardless of the hash.

- [ ] **Step 7: Run the GREEN slice (2 minutes)**

Run the command from Step 3 plus the modified-click test by name.

Expected: all named tests PASS; direct load and history paths keep `focusLog` empty, while explicit user opening focuses only the selected h1.

**Commit suggéré, non exécuté:** `feat: open sessions from accessible index links`

---

### Task 4: Return to the index and recover from an unknown key

**Files:**
- Modify: `tests/test_app_runtime.js`
- Modify: `site/app.js`

**Interfaces produced:** `choisirIndex`, visible `#btn-index`, return-by-select, reversible error without automatic focus.

- [ ] **Step 1: Write RED return-button and return-option tests (5 minutes)**

Add:

```javascript
test('session return button returns to the index and moves focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02#activite-02'
  });
  app.ids.get('btn-index').dispatch('click');
  const url = new URL(app.location.href);
  assert.equal(url.search, '?view=doc');
  assert.equal(url.hash, '');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.deepEqual(app.focusLog, ['index-seances']);
});

test('all sessions option returns to the index and moves focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-01'
  });
  app.ids.get('seance-select').value = '';
  app.ids.get('seance-select').dispatch('change');
  const url = new URL(app.location.href);
  assert.equal(url.search, '?view=doc');
  assert.equal(url.hash, '');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.deepEqual(app.focusLog, ['index-seances']);
});
```

- [ ] **Step 2: Write the RED unknown-session test (4 minutes)**

Replace the old unknown-session test with:

```javascript
test('unknown session shows reversible error above the index', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-99#seance-01-h1'
  });
  assert.equal(app.ids.get('seance-erreur').hidden, false);
  assert.equal(app.ids.get('seance-erreur-texte').textContent,
               'Séance introuvable : seance-99.');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.equal(new URL(app.location.href).search, '?view=doc');
  assert.equal(new URL(app.location.href).hash, '#seance-01-h1');
  assert.deepEqual(app.focusLog, []);

  app.ids.get('btn-toutes').dispatch('click');
  assert.equal(app.ids.get('seance-erreur').hidden, true);
  assert.equal(new URL(app.location.href).hash, '');
  assert.deepEqual(app.focusLog, ['index-seances']);
});
```

Keep the existing audit assertion that error text and URL replacement occur before the alert is shown.

- [ ] **Step 3: Run the three RED tests (2 minutes)**

Run:

```bash
node --test --test-name-pattern='return button|all sessions option|unknown session shows' tests/test_app_runtime.js
```

Expected: FAIL because `#btn-index` has no handler, “Toutes les séances” currently restores a full document, and the unknown path leaves all blocks visible.

- [ ] **Step 4: Add the single explicit index transition (4 minutes)**

Add before `choisirSeance`:

```javascript
function choisirIndex(focusUtilisateur){
  var u=new URL(window.location.href);
  u.searchParams.set('view','doc');
  u.searchParams.delete('seance');
  u.hash='';
  try{window.history.pushState(null,'',u.toString());}catch(e){}
  actualiserEtat({
    force:true,
    focusIndex:focusUtilisateur?'#index-seances':null
  });
}
```

- [ ] **Step 5: Focus only after an explicit return action (3 minutes)**

At the end of `actualiserEtat`, after region and scroll-spy updates, add:

```javascript
if(options.focusIndex=== '#index-seances'&&!indexSeances.hidden){
  indexSeances.focus({preventScroll:true});
  indexSeances.scrollIntoView();
}
```

Wire exact actions:

```javascript
if(btnIndex){
  btnIndex.addEventListener('click',function(){choisirIndex(true);});
}
```

Replace the `else` branch of the select change handler and the existing `btnToutes` handler body with `choisirIndex(true)`. Remove the old `selectSeance.focus` call.

- [ ] **Step 6: Keep unknown state in the index and clear the error on return (2 minutes)**

After an unknown key is replaced out of the URL, keep `etat.courante=null`. The existing `erreur.hidden=!inconnue` assignment must run before `afficherRegions`; the next `choisirIndex(true)` resolves to `inconnue=false`, hides the alert, and focuses the index.

- [ ] **Step 7: Run the GREEN slice (2 minutes)**

Run the command from Step 3.

Expected: all named tests PASS; all three return actions converge on `?view=doc` and the visible index, with focus only after user input.

**Commit suggéré, non exécuté:** `feat: return from a session to the index`

---

### Task 5: Make history, anchors, and PDF obey the same state machine

**Files:**
- Modify: `tests/test_app_runtime.js`
- Modify: `site/app.js`

**Interfaces produced:** no-focus history replay, one-cycle event guard, legacy anchor compatibility, explicit global PDF.

- [ ] **Step 1: Write RED popstate, hashchange, combined-event, and legacy-hash tests (5 minutes)**

Delete the old test `popstate restores unknown state without focus`; it expects the context to become active and leaves one TOC item current. Delete the old test `direct session hash without query derives navigation index`; the replacement legacy test below must use an absolute URL and assert an exclusive session, not navigation-index derivation over a full document. Replace the corresponding existing tests with:

```javascript
test('popstate restores index with reversible unknown-session error without focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-01'
  });
  app.resetWrites();
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-99');
  app.fire('popstate');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('seance-erreur').hidden, false);
  assert.equal(app.ids.get('seance-erreur-texte').textContent,
               'Séance introuvable : seance-99.');
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': true
  });
  assert.deepEqual(app.ariaCurrent(), []);
  assert.equal(new URL(app.location.href).search, '?view=doc');
  assert.deepEqual(app.focusLog, []);
});

test('popstate between index and session does not focus', () => {
  const app = runApp({ rects: { 'seance-02-h1': 10 } });
  app.resetWrites();
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-02#seance-02-h1');
  app.fire('popstate');
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('contenu').hidden, false);
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': false
  });
  assert.deepEqual(app.focusLog, []);
  assert.equal(app.ids.get('saut-region').getAttribute('href'), '#contenu');
});

test('hashchange within a session does not focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02#seance-02-h1',
    rects: { 'activite-02': 10 }
  });
  app.resetWrites();
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02#activite-02');
  app.fire('hashchange');
  assert.equal(new URL(app.location.href).hash, '#activite-02');
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.deepEqual(app.focusLog, []);
  assert.deepEqual(app.ariaCurrent(), ['#activite-02']);
  assert.equal(app.writeCount('aria-current'), 1);
});

test('popstate followed by hashchange runs one state cycle', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02'
  });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-01#activite-01');
  app.resetWrites();
  app.fire('popstate');
  app.fire('hashchange');
  assert.equal(app.writeCount('aria-current'), 1);
  assert.equal(app.writeCount('href'), 2);
  assert.equal(app.listenerCount('popstate'), 1);
  assert.equal(app.listenerCount('hashchange'), 1);
  assert.deepEqual(app.focusLog, []);
});

test('legacy session hash opens only its session without focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html#seance-02-h1'
  });
  assert.equal(new URL(app.location.href).search, '');
  assert.equal(new URL(app.location.href).hash, '#seance-02-h1');
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, false);
  assert.equal(app.ids.get('contenu').hidden, false);
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': false
  });
  assert.deepEqual(app.focusLog, []);
});
```

- [ ] **Step 2: Write RED PDF, PDF→index, and invalid-hash tests (5 minutes)**

Delete the old runtime tests `PDF to document preserves hash and final URL is complete document`, `popstate without query replays stored PDF preference`, `popstate without query replays stored Document preference`, and `popstate switches between PDF and Document and cleans PDF seance`; their expected full-document/autofocus behavior contradicts the index contract. Add the new tests with the default/stored and explicit-PDF assertions below:

```javascript
test('PDF to Document returns to index without focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=pdf#seance-02-h1'
  });
  app.ids.get('btn-doc').dispatch('click');
  const url = new URL(app.location.href);
  assert.equal(url.search, '?view=doc');
  assert.equal(url.hash, '');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.equal(app.ids.get('vue-pdf').hidden, true);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': true
  });
  assert.deepEqual(app.focusLog, []);
});

test('PDF never derives a session from a hash', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=pdf#seance-02-h1'
  });
  assert.equal(app.ids.get('vue-pdf').hidden, false);
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': true
  });
  assert.deepEqual(app.focusLog, []);
});

test('document index ignores activity, malformed, unknown, detached, and unregistered-wrapper hashes', () => {
  for (const hash of ['#activite-02', '#seance-02%ZZ', '#id-absent', '#contexte']) {
    const app = runApp({
      url: 'https://example.test/Cahier-De-Laboratoire/index.html' + hash
    });
    assert.equal(app.ids.get('index-seances').hidden, false, hash);
    assert.equal(app.ids.get('vue-doc').hidden, true, hash);
    assert.equal(app.ids.get('sommaire').hidden, true, hash);
    assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false', hash);
    assert.deepEqual(app.hiddenByKey(), {
      contexte: true, 'seance-01': true, 'seance-02': true
    }, hash);
    assert.deepEqual(app.focusLog, [], hash);
  }
  const detached = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html'
  });
  const forgedH1 = element('h1', 'H1 non enregistrée');
  forgedH1.id = 'seance-99-h1';
  forgedH1.setAttribute('data-seance', 'seance-99');
  detached.ids.get('contenu').appendChild(forgedH1);
  assert.equal(detached.ids.has('seance-99-h1'), false);
  detached.navigate('https://example.test/Cahier-De-Laboratoire/index.html#seance-99-h1');
  detached.fire('hashchange');
  assert.equal(detached.documentGetElementById('seance-99-h1'), forgedH1);
  assert.equal(detached.ids.get('index-seances').hidden, false);
  assert.deepEqual(detached.focusLog, []);

  const wrongWrapper = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html'
  });
  const wrapper = element('div', '', 'bloc-seance');
  wrapper.setAttribute('data-seance', 'seance-99');
  const wrongH1 = element('h1', 'H1 dans wrapper non enregistré');
  wrongH1.id = 'seance-99-h1';
  wrongH1.setAttribute('data-seance', 'seance-99');
  wrapper.appendChild(wrongH1);
  wrongWrapper.ids.get('contenu').appendChild(wrapper);
  assert.equal(wrongWrapper.ids.has('seance-99-h1'), false);
  wrongWrapper.navigate('https://example.test/Cahier-De-Laboratoire/index.html#seance-99-h1');
  wrongWrapper.fire('hashchange');
  assert.equal(wrongWrapper.documentGetElementById('seance-99-h1'), wrongH1);
  assert.equal(wrongWrapper.ids.get('index-seances').hidden, false);
  assert.deepEqual(wrongWrapper.focusLog, []);
});
```

Also add:

```javascript
test('default route ignores stored PDF preference', () => {
  const app = runApp({ storageMode: 'pdf' });
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-pdf').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, true);
});

test('explicit PDF remains global and hides index and document', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=pdf&seance=seance-02#activite-02'
  });
  const url = new URL(app.location.href);
  assert.equal(url.search, '?view=pdf');
  assert.equal(url.hash, '#activite-02');
  assert.equal(app.ids.get('vue-pdf').hidden, false);
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.equal(app.ids.get('contenu').hidden, true);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.equal(app.ids.get('saut-region').getAttribute('href'), '#vue-pdf');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': true
  });
  assert.deepEqual(app.focusLog, []);
});
```

Add a stored-preference test proving explicit `view=pdf` overrides stored `doc` while a bare default URL ignores stored `pdf`. Delete every named old stored-preference popstate test listed above and the old PDF↔Document full-document popstate test.

- [ ] **Step 3: Run the history/PDF RED slice (2 minutes)**

Run:

```bash
node --test --test-name-pattern='popstate restores index with reversible|popstate between|hashchange within|popstate followed|legacy session hash|default route ignores|explicit PDF remains|PDF to Document|PDF never derives|document index ignores' tests/test_app_runtime.js
```

Expected: the PDF→index, invalid-H2/hash, unknown-popstate, and desktop TOC branch tests FAIL on the current runtime; valid H1 legacy-hash behavior may already pass after Task 3.

- [ ] **Step 4: Keep history listeners focus-free and URL-deduplicated (3 minutes)**

Keep exactly:

```javascript
window.addEventListener('popstate',function(){actualiserEtat();});
window.addEventListener('hashchange',function(){actualiserEtat();});
```

Preserve the `etat.dernierHref` early return. Normalize an unknown query with `replaceState` before assigning the final normalized href, so the browser’s subsequent `hashchange` is a no-op.

- [ ] **Step 5: Make PDF cleanup, hash exclusion, and Document return explicit (4 minutes)**

Retain the existing rule in `appliquerModeDepuisUrl`:

```javascript
if(mode==='pdf'&&u.searchParams.has('seance')){
  u.searchParams.delete('seance');
  try{window.history.replaceState(null,'',u.toString());}catch(e){}
}
```

Guard legacy-hash inference with `modeCourante==='doc'`, then wire the Document button from PDF to the index without focus:

```javascript
bDoc.addEventListener('click',function(){
  if(modeCourante==='pdf'){choisirIndex(false);return;}
  changerMode('doc');
});
```

`choisirIndex(false)` still clears `seance` and `u.hash`; it passes `focusIndex:null`, so the PDF→index transition never calls `focus`. PDF resolution leaves `etat.courante=null`; `afficherRegions` is the only function that writes `pdf.hidden` and `doc.hidden`.

- [ ] **Step 6: Route the media listener through the owner and test it separately (5 minutes)**

Before applying production code, remove the obsolete whole-file call-count assertion from the ownership test: the only source assertions are owner placement and listener routing.

Replace the old single `toc button toggles aria-expanded on the fake sommaire element` with these two tests. The first proves initial mobile/desktop state and the owner’s index/PDF branches. The second tests the media listener without relying on a global call count:

```javascript
test('mobile breakpoint starts TOC collapsed; desktop session hides TOC on index and PDF', () => {
  const mobile = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01',
    desktopBreakpoint: false
  });
  assert.equal(mobile.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.equal(mobile.ids.get('sommaire').hidden, true);

  const desktop = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01',
    desktopBreakpoint: true
  });
  assert.equal(desktop.ids.get('btn-toc').getAttribute('aria-expanded'), 'true');
  assert.equal(desktop.ids.get('sommaire').hidden, false);

  mobile.ids.get('btn-toc').dispatch('click');
  assert.equal(mobile.ids.get('sommaire').hidden, false);
  assert.equal(mobile.ids.get('btn-toc').getAttribute('aria-expanded'), 'true');

  desktop.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=doc');
  desktop.fire('popstate');
  assert.equal(desktop.ids.get('sommaire').hidden, true);
  assert.equal(desktop.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');

  desktop.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=pdf');
  desktop.fire('popstate');
  assert.equal(desktop.ids.get('sommaire').hidden, true);
  assert.equal(desktop.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
});

test('desktop media listener routes breakpoint changes through afficherRegions', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01',
    desktopBreakpoint: true
  });
  assert.equal(app.ids.get('sommaire').hidden, false);
  app.setMedia('(min-width: 1000px)', false);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  app.setMedia('(min-width: 1000px)', true);
  assert.equal(app.ids.get('sommaire').hidden, false);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'true');
});
```

Production listener:

```javascript
function reagirAuPointRupture(){
  afficherRegions();
}
if(pointRupture&&pointRupture.addEventListener){
  pointRupture.addEventListener('change',reagirAuPointRupture);
}else if(pointRupture&&pointRupture.addListener){
  pointRupture.addListener(reagirAuPointRupture);
}
```

The media listener must not call `appliquerToc` directly; it routes through `afficherRegions`, the unique state/visibility owner. Remove the old listener body `appliquerToc(replierToc())`. The separate test drives the registered listener and observes the sidebar/ARIA result without a global source-call count. Expected before the configurable fake: both initial runs use `matches:false`, so desktop session startup fails; the separate `setMedia` test proves the registered listener. Keep the manual 320 px check; this test changes only the fake breakpoint, not production CSS or the real `matchMedia`.

- [ ] **Step 7: Run the GREEN history/PDF/breakpoint slice (2 minutes)**

Run the command from Step 3, then the complete runtime file.

Expected: all named tests and the entire runtime suite PASS; direct, history, and PDF transitions have no automatic focus.

**Commit suggéré, non exécuté:** `fix: align history and PDF with indexed session state`

---

### Task 6: Add responsive/focus styling and complete the regression suite

**Files:**
- Modify: `tests/test_app_runtime.js`
- Modify: `site/style.css`

**Interfaces produced:** full-row native links, visible keyboard focus, unbreakable session titles, mobile-safe index at 320 px.

- [ ] **Step 1: Add RED template and CSS contract tests (5 minutes)**

Add:

```javascript
test('template exposes index, skip, return, and focusable visible regions', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '..', 'site', 'template.html'), 'utf8'
  );
  assert.match(source, /id="saut-region"[^>]+href="#index-seances"/);
  assert.match(source, /<section id="index-seances"[^>]+aria-labelledby="titre-index-seances"[^>]+tabindex="-1"/);
  assert.match(source, /<h2 id="titre-index-seances">Choisir une séance<\/h2>/);
  assert.match(source, /<ul id="liste-seances" aria-labelledby="titre-index-seances"><\/ul>/);
  assert.match(source, /<button type="button" id="btn-index" class="bouton">Toutes les séances<\/button>/);
  assert.match(source, /<div class="lecture" id="vue-doc" hidden>/);
  assert.match(source, /<div class="panneau-pdf" id="vue-pdf" tabindex="-1" hidden>/);
});

test('session index has visible focus and mobile-safe rules', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '..', 'site', 'style.css'), 'utf8'
  );
  assert.match(source, /#liste-seances a:focus-visible\s*\{[^}]*outline:/);
  const desktop = source.slice(source.indexOf('@media (min-width:1000px)'));
  assert.doesNotMatch(source, /\.col-sommaire\[hidden\]\s*\{[^}]*display:block/);
  assert.doesNotMatch(desktop, /\.col-sommaire\[hidden\]\s*\{[^}]*display:block/);
  assert.match(source, /\.col-sommaire\[hidden\]\s*\{[^}]*display:none/);
  assert.match(source, /\.toc-barre\[hidden\]\s*\{[^}]*display:none/);
  assert.match(source, /#liste-seances \.seance-index-titre\s*\{[^}]*overflow-wrap:anywhere/);
  const mobile = source.slice(source.indexOf('@media (max-width:480px)'));
  assert.match(mobile, /#liste-seances a\s*\{[^}]*grid-template-columns:1fr/);
  assert.match(mobile, /#liste-seances \.seance-index-action\s*\{[^}]*justify-self:start/);
});
```

- [ ] **Step 2: Run the RED contract tests (2 minutes)**

Run:

```bash
node --test --test-name-pattern='template exposes|session index has visible' tests/test_app_runtime.js
```

Expected: both tests FAIL because the index selectors and mobile rules do not exist.

- [ ] **Step 3: Add desktop/index CSS using existing variables (4 minutes)**

Add near the session navigation rules in `site/style.css`:

```css
/* Les commandes de lecture suivent exactement la région visible. */
.col-sommaire[hidden]{display:none}
.toc-barre[hidden]{display:none}

/* Index des seances */
#index-seances{max-width:1020px;margin:0 auto;padding:2rem;background:var(--carte);
  border:1px solid var(--bord);border-radius:var(--rayon);box-shadow:var(--ombre)}
#index-seances[hidden]{display:none}
#index-seances h2{margin:0 0 1.2rem;font-size:1.65rem;line-height:1.25}
#liste-seances{list-style:none;margin:0;padding:0;border-top:1px solid var(--bord)}
#liste-seances li{min-width:0;border-bottom:1px solid var(--bord)}
#liste-seances a{display:grid;grid-template-columns:minmax(0,1fr) auto;align-items:center;
  gap:1rem;min-width:0;padding:1rem .25rem;color:var(--noir);text-decoration:none}
#liste-seances a:hover{color:var(--rouge-fonce);background:var(--rouge-clair)}
#liste-seances a:focus-visible{outline:3px solid var(--rouge);outline-offset:-3px;
  border-radius:6px}
#liste-seances .seance-index-titre{min-width:0;font-weight:750;overflow-wrap:anywhere}
#liste-seances .seance-index-action{color:var(--lien);font-weight:700;white-space:nowrap}
```

Keep `.seance-lien` focus visible and add `#btn-index:focus-visible` to the existing shared `.bouton:focus-visible` rule only if the current rule does not already cover it. Replace the existing desktop rule `.col-sommaire[hidden]{display:block}` with `.col-sommaire[hidden]{display:none}` so the HTML `hidden` property wins at every breakpoint. Keep the new `.toc-barre[hidden]{display:none}` rule because the base `.toc-barre{display:flex}` declaration would otherwise keep a hidden control in layout. Do not change the viewer’s desktop grid.

- [ ] **Step 4: Add the 320 px-safe media rule (3 minutes)**

Inside the existing `@media (max-width:480px)` block, add:

```css
  #index-seances{padding:1rem .85rem;border-radius:10px}
  #index-seances h2{font-size:1.25rem;margin-bottom:.9rem}
  #liste-seances a{grid-template-columns:1fr;gap:.35rem;padding:.9rem .2rem}
  #liste-seances .seance-index-action{justify-self:start;font-size:.85rem}
  #btn-index{width:100%;justify-content:center}
```

Do not add fixed widths, `white-space:nowrap` to titles, horizontal carousels, or overflow to `body`. The session title may wrap, and the action stays on its own line at 320 px.

- [ ] **Step 5: Update old tests whose expected product changed (4 minutes)**

Make these exact semantic replacements:

- Delete `empty seance means all sessions` and replace it with the same assertions as the default-index test plus normalized absence of `seance`.
- Delete `keyboard-focused return button removes unknown state and focuses select`; replace it with the unknown-error recovery test that ends with focus `['index-seances']`.
- Delete `all sessions preserves hash, path, and document`; replace it with `all sessions option returns to the index and moves focus`, which requires an empty hash.
- Delete `PDF to document preserves hash and final URL is complete document`; replace it with `PDF to Document returns to index without focus`, which requires `?view=doc`, empty hash, visible index, and no focus.
- Delete `popstate without query replays stored PDF preference` and `popstate without query replays stored Document preference`; bare/default/popstate-without-session states show the index regardless of storage.
- Delete `popstate restores unknown state without focus`; replace it with `popstate restores index with reversible unknown-session error without focus`, which requires the visible index, visible error, all blocks hidden, `ariaCurrent() === []`, collapsed TOC, and no focus.
- Delete `popstate switches between PDF and Document and cleans PDF seance`; replace it with history tests that assert PDF stays global, PDF→Document returns to the index, and history never focuses.
- Delete `toc button toggles aria-expanded on the fake sommaire element`; replace it with the explicit mobile/desktop breakpoint test from Task 5.
- Update `seance parameter forces document instead of stored pdf` to assert exclusive document because a known `seance` wins over stored PDF.
- Delete `direct session hash without query derives navigation index`; replace it with `legacy session hash opens only its session without focus`, which requires a registered session H1, exclusive blocks, and no query-derived `seance` parameter.
- Delete `document start disables previous and targets seance-01 next`; no previous/next control is available from the index.
- Replace `next and previous sequence visits sessions in order` with a session-visible test initialized by `runApp({url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-01'})`, opening `seance-02` from next and returning to `seance-01` from previous. Do not assert all blocks visible.
- Replace `user selection focuses visible h1 and next changes exclusive session` with a session-visible test initialized by `runApp({url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-01'})`, selecting `seance-02`, and asserting only `seance-02` is visible before focusing its h1.
-     `exclusive navigation hrefs contain target session and activity hash` must start from a known session URL; previous/next assertions are never driven from the index.
- `popstate restores known session without focus` starts from an unknown/session history route but expects an exclusive known session, not the full document.
- Every direct-load, `popstate`, `hashchange`, unknown, PDF, and PDF→index assertion includes `assert.deepEqual(app.focusLog, [])` after any user-initiated focus assertion.
- Known-session TOC/search tests continue to assert that TOC entries and blocks from other sessions remain hidden.

- [ ] **Step 6: Run the full runtime suite (3 minutes)**

Run:

```bash
node --check site/app.js
node --test tests/test_app_runtime.js
```

Expected: syntax check exits 0; every Node test PASSes with zero failures and no skipped test.

- [ ] **Step 7: Run local feature verification (3 minutes)**

Run:

```bash
node --check site/app.js
node --test tests/test_app_runtime.js
python3 -B -m unittest discover -s tests -p 'test_*.py'
```

Expected: all existing Python tests PASS. `scripts/build_site.py` and `tests/test_build_site.py` have no diff from the index writer.

---

### Task 7: CI and joint diagrams/index integration — separate owner

**Files:**
- Modify: `.github/workflows/ci.yml` only, by an integration owner after the index and diagrams writers finish.

**Interfaces produced:** the existing CI test gate also runs `node --test tests/test_app_runtime.js`; the common diagram build/audit/assembly gate runs against the integrated worktree.

- [ ] **Step 1: Add the runtime test beside the Python test gate (2 minutes)**

Add this step to `.github/workflows/ci.yml` without editing feature files:

```yaml
      - name: Run index runtime tests
        run: node --test tests/test_app_runtime.js
```

Expected: exit 0 with zero failed tests.

- [ ] **Step 2: Run the joint diagrams/index integration audit in build/export order (5 minutes, run from a clean generated-output directory)**

After both writers have finished, run the common audit from `2026-09-25-session-diagrams.md` in this exact order:

```bash
python3 -B -m unittest discover -s tests -p 'test_*.py'
node --test tests/test_app_runtime.js
rm -rf public/assets/figs
python3 scripts/build_site.py -o /tmp/integration-fragment.html --toc /tmp/integration-toc.html
python3 scripts/export_figures.py --outdir public/assets/figs --workdir /tmp/integration-diagram-wrappers
test "$(find public/assets/figs -maxdepth 1 -type f -name '*.svg' | wc -l | tr -d ' ')" = "15"
python3 -B - <<'PY'
from pathlib import Path
from scripts.assemble_site import audit_built_page

fragment = Path('/tmp/integration-fragment.html').read_text(encoding='utf-8')
report = audit_built_page(fragment)
assert report.svg_count == 15, report
assert report.session_svg_counts.get('seance-02') == 4, report
assert report.placeholder_count == 0, report
print('Joint pre-assembly audit: 15 SVG, 4 images séance 02, 0 placeholder')
PY
python3 scripts/assemble_site.py --toc /tmp/integration-toc.html --fragment /tmp/integration-fragment.html --out public/index.html
python3 -B - <<'PY'
from pathlib import Path
from scripts.assemble_site import audit_site

root = Path('public')
report = audit_site(root, (root / 'index.html').read_text(encoding='utf-8'))
assert report.svg_count == 15, report
assert report.session_svg_counts.get('seance-02') == 4, report
assert report.placeholder_count == 0, report
print('Joint final audit: 15 SVG, 4 images séance 02, 0 placeholder; index runtime PASS')
PY
```

Expected: Python tests and index runtime tests pass; after clearing only generated `public/assets/figs`, `build_site.py` generates the fragment; `export_figures.py` exports exactly 15 SVG; `audit_built_page` proves 15/4/0 before assembly; `assemble_site.py` copies/assembles; `audit_site` proves 15/4/0 afterward. This is performed by the integration owner only after both feature writers; neither feature writer checks for an exclusive worktree and neither treats the other task’s files as disposable. Restore any pre-existing generated asset if this command is run in a dirty production worktree; integration CI starts from a clean checkout.

**Commit suggéré, non exécuté:** `feat: style accessible responsive session index`

---

## Final Verification

Run all checks only after Task 6 is green.

- [ ] **Step 1: Verify runtime coverage and CI signature (4 minutes)**

```bash
node --experimental-test-coverage --test tests/test_app_runtime.js
rg -n 'node --test tests/test_app_runtime\.js' .github/workflows/ci.yml
```

Expected: all tests PASS, Node prints a coverage table for `site/app.js`, there are zero failed tests, and CI contains the exact Node runtime command. Do not introduce a coverage dependency or threshold unrelated to the repository tooling.

- [ ] **Step 2: Verify exact HTML, runtime, and CSS signatures (3 minutes)**

```bash
rg -n 'id="(saut-region|index-seances|liste-seances|btn-index|vue-pdf)"' site/template.html
rg -n 'function (modePourUrl|seanceDepuisH1|construireIndex|afficherRegions|majNavigation|majLienEvitement|choisirSeance|choisirIndex|actualiserEtat)' site/app.js
rg -n '#liste-seances a:focus-visible|#liste-seances \.seance-index-titre|#liste-seances \.seance-index-action' site/style.css
```

Expected: the exact HTML and CSS interfaces appear once. All nine runtime function declarations must be present. The ownership test is the behavioral guard against duplicate visibility writers.

- [ ] **Step 3: Audit unfinished work markers and whitespace (3 minutes)**

```bash
python3 -B - <<'PY'
from pathlib import Path

paths = [
    Path('site/template.html'),
    Path('site/app.js'),
    Path('site/style.css'),
    Path('tests/test_app_runtime.js'),
]
forbidden = ('TO' + 'DO', 'T' + 'BD', 'FIX' + 'ME', 'PLACE' + 'HOLDER')
for path in paths:
    text = path.read_text(encoding='utf-8')
    hits = [marker for marker in forbidden if marker in text]
    if hits:
        raise SystemExit(f'{path}: marqueurs inachevés {hits}')
    for number, line in enumerate(text.splitlines(), 1):
        if line != line.rstrip():
            raise SystemExit(f'{path}:{number}: espace final')
print('audit lexical et espaces: OK')
PY
```

Expected: `audit lexical et espaces: OK`.

- [ ] **Step 4: Verify whitespace and exact scope (3 minutes)**

```bash
git diff --check -- site/template.html site/app.js site/style.css tests/test_app_runtime.js .github/workflows/ci.yml
git diff --stat -- site/template.html site/app.js site/style.css tests/test_app_runtime.js .github/workflows/ci.yml
git status --short
git diff -- scripts/build_site.py
```

Expected:

- `git diff --check` exits 0 with no output.
- The feature-writer stat contains only the four feature files; the separate CI owner’s stat contains only `.github/workflows/ci.yml`.
- Joint status may also contain the diagrams writer’s authorized files. The index writer must not delete, revert, stage, or require exclusive ownership of them.
- The final `git diff` for `scripts/build_site.py` is empty from the index writer; the diagrams owner may legitimately change it under its own plan.
- No commit has been created.

- [ ] **Step 5: Perform a manual browser smoke check without changing repository files (5 minutes)**

Serve the already generated site through its normal local workflow, then verify at 320 px and desktop width:

1. `/index.html` shows `Choisir une séance` and no document/TOC/activity content.
2. Tab moves through the skip link and one native index row per session; the selected row has a visible outline.
3. Enter on “Séance 02” opens only séance 02 and moves focus to its h1.
4. “Toutes les séances” returns to the index, clears the hidden-document hash, and focuses the index.
5. A direct `?seance=seance-02` URL opens without an initial focus jump.
6. Back/forward and a same-session anchor change views without a focus jump.
7. `?view=pdf` opens the global PDF and the skip link targets `#vue-pdf`; Document returns to a hash-free index without focus.
8. `?seance=seance-99` shows the error above the index and the return control clears it.
9. At a mobile breakpoint the TOC starts collapsed; at desktop it starts expanded. A direct activity hash does not open a session.

Expected: all nine checks PASS; no horizontal scrollbar appears at 320 px; light/dark theme and existing reader controls continue to work.

## Self-Review Checklist

- [ ] Every checkbox was executed in RED → GREEN order, one behavior at a time.
- [ ] Default and `?view=doc` routes show the index even when PDF was previously stored.
- [ ] Only a known `seance`, or a legacy hash targeting a registered session H1 in Document mode, shows the document; PDF never derives session state from a hash.
- [ ] Known-session document displays one block; context, other sessions, TOC for other sessions, and activities remain hidden.
- [ ] “Ouvrir la séance” is a native full-row link with a stable relative URL and h1 hash.
- [ ] `#btn-index`, the select option, and error recovery all return to the index and focus it only after user action.
- [ ] Fake clicks bubble with stable `target` and ancestor `currentTarget`; the delegated index listener is exercised end to end.
- [ ] `afficherRegions` alone writes all region `hidden` properties; `majNavigation` writes navigation values only; the state order is explicit.
- [ ] Desktop session→index and session→PDF both assert `sommaire.hidden === true`; no startup call initializes TOC before the first state cycle.
- [ ] Previous/next/select tests start from a visible session and assert exclusive blocks, never the index.
- [ ] Runtime `runApp` URLs are absolute or use an explicit absolute base; the old derived-navigation hash test is deleted for the legacy/exclusive contract.
- [ ] Unknown-session popstate shows index + error, hides all blocks, clears `ariaCurrent`, collapses TOC, and does not focus.
- [ ] `.col-sommaire[hidden]{display:none}` and `.toc-barre[hidden]{display:none}` are present and covered by the CSS contract test; the old desktop `display:block` override is removed.
- [ ] The media-query listener calls only `afficherRegions`, and its listener path is tested separately through `setMedia` without a global call count.
- [ ] PDF→Document calls `choisirIndex(false)`, removes the hash, and never focuses or infers a session from an H1 hash.
- [ ] Document legacy inference requires `bloc = element.parentElement` and `blocsParCle[cle] === bloc`, not H2/activity, malformed, unknown, detached, or unregistered-wrapper H1 hashes.
- [ ] Direct load, `popstate`, `hashchange`, PDF, and scroll never steal focus.
- [ ] PDF remains global and explicit; index and document are absent from the PDF view.
- [ ] Skip-link text and target match the visible region in index, session, and PDF.
- [ ] Index titles wrap at 320 px, action text does not overflow, and focus is visible.
- [ ] Existing viewer, TOC, anchors, search, scroll spy, navigation, theme, and report link are preserved.
- [ ] The separate CI owner adds the exact Node runtime command and the joint diagrams/index audit runs build → export 15 → audit → assembly after both writers.
- [ ] The index writer did not modify `scripts/build_site.py`; no configuration, dependency, or generated-file change was introduced.
- [ ] Coverage, signatures, lexical audit, `git diff --check`, and status checks passed.
- [ ] Suggested commits remain suggestions; no commit was executed.
