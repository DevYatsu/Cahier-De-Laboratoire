# Summary Filter Runtime Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the generated web app initialize its interactive summary filter and prevent future startup exceptions from silently disabling that feature.

**Architecture:** Keep the existing single-file browser runtime and its DOM-based filter semantics. Add a dependency-free Node runtime smoke test that executes the real `site/app.js` against a minimal DOM fixture, then fix the undefined theme-state reference that aborts initialization before the search listeners are installed.

**Tech Stack:** Vanilla JavaScript, Node.js built-ins (`node:test`, `node:assert/strict`, `node:vm`, `node:fs`, `node:path`), Python `unittest` for the existing build test.

**Spec:** `docs/superpowers/plans/2026-09-25-activity-summary-subparts.md`

## Global Constraints

- Touch only `site/app.js` and create `tests/test_app_runtime.js`.
- Add no package or runtime dependencies.
- Preserve the existing accent-insensitive substring search, ancestor/descendant visibility, result count, Enter navigation, and Escape reset behavior.
- Do not edit generated files under `public/`; CI regenerates them from `site/app.js`.
- Do not alter or overwrite the existing unrelated working-tree changes.
- Leave changes uncommitted for user review.

---

### Task 1: Runtime regression and minimal startup fix

**Files:**
- Create: `tests/test_app_runtime.js`
- Modify: `site/app.js:36-42`
- Reference: `site/app.js:155-226`
- Reference: `site/template.html:46-58`

**Interfaces:**
- Consumes: browser DOM IDs `vue-doc`, `vue-pdf`, `btn-doc`, `btn-pdf`, `btn-theme`, `btn-toc`, `sommaire`, `recherche`, and `recherche-compte`, plus nested `.col-sommaire nav.toc li` entries.
- Produces: a Node test that fails if the app IIFE throws before registering the summary search `input` and `keydown` listeners.

- [ ] **Step 1: Add the failing runtime test**

Create `tests/test_app_runtime.js` with a minimal DOM fixture and execute the real source in a VM. The decisive assertions are that startup succeeds, filtering a nested match keeps its ancestor and matching descendant visible, the count is updated, and Escape restores all entries.

```javascript
'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

class Element {
  constructor(tagName) {
    this.tagName = tagName.toUpperCase();
    this.children = [];
    this.parentElement = null;
    this.dataset = {};
    this.style = {};
    this.listeners = new Map();
    this.attributes = new Map();
    this.hidden = false;
    this.value = '';
    this.textContent = '';
  }

  appendChild(child) {
    child.parentElement = this;
    this.children.push(child);
    return child;
  }

  addEventListener(type, listener) {
    const listeners = this.listeners.get(type) || [];
    listeners.push(listener);
    this.listeners.set(type, listeners);
  }

  dispatch(type, event = {}) {
    for (const listener of this.listeners.get(type) || []) listener(event);
  }

  setAttribute(name, value) {
    this.attributes.set(name, String(value));
  }

  getAttribute(name) {
    return this.attributes.has(name) ? this.attributes.get(name) : null;
  }

  removeAttribute(name) {
    this.attributes.delete(name);
  }

  querySelectorAll(selector) {
    if (selector !== 'li') return [];
    const matches = [];
    const visit = parent => {
      for (const child of parent.children) {
        if (child.tagName === 'LI') matches.push(child);
        visit(child);
      }
    };
    visit(this);
    return matches;
  }

  closest() { return null; }
  click() { this.clicked = true; }
  remove() {}
  cloneNode() { return new Element(this.tagName); }
  focus() {}
}

function element(tagName, text = '') {
  const node = new Element(tagName);
  node.textContent = text;
  return node;
}

function summaryEntry(label) {
  const item = element('li');
  const anchor = element('a', label);
  anchor.setAttribute('href', '#' + label.toLowerCase().replace(/\s+/g, '-'));
  item.appendChild(anchor);
  return { item, anchor };
}

function runApp() {
  const ids = new Map();
  for (const id of [
    'vue-doc', 'vue-pdf', 'btn-doc', 'btn-pdf', 'btn-theme', 'btn-toc',
    'sommaire', 'recherche', 'recherche-compte', 'nav-seances',
    'seance-prec', 'seance-suiv', 'seance-select',
  ]) ids.set(id, element(id === 'recherche' ? 'input' : 'div'));

  const sidebar = element('aside');
  const toc = element('nav');
  const rootList = element('ul');
  const parent = summaryEntry('Séance Café');
  const children = element('ul');
  const matching = summaryEntry('Activité Café');
  const other = summaryEntry('Activité Thé');
  children.appendChild(matching.item);
  children.appendChild(other.item);
  parent.item.appendChild(children);
  rootList.appendChild(parent.item);
  toc.appendChild(rootList);
  sidebar.appendChild(toc);

  const storage = new Map();
  const document = {
    body: element('body'),
    documentElement: element('html'),
    createElement: tagName => element(tagName),
    getElementById: id => ids.get(id) || null,
    querySelector: selector => {
      if (selector === '.col-sommaire') return sidebar;
      if (selector === '.col-sommaire nav.toc') return toc;
      return null;
    },
    querySelectorAll: selector => {
      if (selector === '.col-sommaire nav.toc li') return toc.querySelectorAll('li');
      return [];
    },
  };
  const window = {
    location: { href: 'https://example.test/', hash: '' },
    innerHeight: 0,
    scrollY: 0,
    history: { replaceState() {} },
    addEventListener() {},
    requestAnimationFrame() { return 1; },
    setTimeout() { return 1; },
    matchMedia() {
      return { matches: false, addEventListener() {}, addListener() {} };
    },
  };
  const context = {
    document,
    window,
    navigator: {},
    localStorage: {
      getItem: key => storage.has(key) ? storage.get(key) : null,
      setItem: (key, value) => storage.set(key, String(value)),
    },
    URL,
    matchMedia: window.matchMedia,
  };
  const source = fs.readFileSync(path.join(__dirname, '..', 'site', 'app.js'), 'utf8');
  vm.runInNewContext(source, context, { filename: 'site/app.js' });
  return { ids, entries: [parent.item, matching.item, other.item] };
}

test('summary filtering initializes and preserves matching ancestors', () => {
  const { ids, entries } = runApp();
  const search = ids.get('recherche');
  const count = ids.get('recherche-compte');

  search.value = 'cafe';
  search.dispatch('input');

  assert.equal(entries[0].hidden, false, 'matching ancestor stays visible');
  assert.equal(entries[1].hidden, false, 'matching entry stays visible');
  assert.equal(entries[2].hidden, true, 'nonmatching entry is hidden');
  assert.equal(count.textContent, '2 résultats');

  search.dispatch('keydown', { key: 'Escape', preventDefault() {} });
  assert.deepEqual(entries.map(item => item.hidden), [false, false, false]);
  assert.equal(count.textContent, '');
});
```

- [ ] **Step 2: Run the test and verify the pre-fix failure**

Run:

```bash
node --test tests/test_app_runtime.js
```

Expected: FAIL while evaluating `site/app.js` with `ReferenceError: d is not defined`; the failure proves startup aborts before the summary filter is registered.

- [ ] **Step 3: Apply the minimal implementation fix**

In `site/app.js:40-41`, use the existing `dark` boolean for both theme-button attributes:

```javascript
  if(bTheme){
    bTheme.setAttribute('aria-pressed',dark?'true':'false');
    bTheme.setAttribute('aria-label',dark?'Activer le thème clair':'Activer le thème sombre');
  }
```

Do not refactor the IIFE or change filtering logic.

- [ ] **Step 4: Run targeted verification**

Run:

```bash
node --check site/app.js
node --test tests/test_app_runtime.js
python3 -m unittest discover -s tests -p 'test_build_site.py' -v
git diff --check -- site/app.js tests/test_app_runtime.js
```

Expected: syntax check passes; the Node runtime test passes; the existing build test passes; `git diff --check` reports no whitespace errors.

- [ ] **Step 5: Review scope**

Run:

```bash
git status --short -- site/app.js tests/test_app_runtime.js
git diff -- site/app.js tests/test_app_runtime.js
```

Expected: only the theme-reference correction and the new runtime regression test are present. No generated `public/` file or unrelated user modification is changed.
