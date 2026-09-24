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
  parent.item.appendChild(children);
  rootList.appendChild(parent.item);
  rootList.appendChild(other.item);
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
