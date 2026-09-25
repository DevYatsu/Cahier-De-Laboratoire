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
  setAttribute(name, value) {
    const text = String(value);
    this.attributes.set(name, text);
    if (name === 'class') text.split(/\s+/).forEach(item => this.classList.add(item));
    if (name === 'aria-current' && text === 'location') this.audit.push('aria-current');
    if (name === 'href') this.audit.push('href');
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
  click() { return this.dispatch('click'); }
  focus() { globalAudit.focusLog.push(this.id); }
  scrollIntoView() { globalAudit.scrollLog.push(this.id); }
  getBoundingClientRect() {
    if (this.id === 'site-header') return { top: 0, height: 64 };
    return { top: globalAudit.rects[this.id] || 1000, height: 100 };
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
      if (selector === 'a[data-seance]' && current.tagName === 'A' &&
          /^seance-\d{2}$/.test(current.getAttribute('data-seance') || '')) return current;
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
    if (selector === 'h2') return values.filter(node => node.tagName === 'H2');
    if (selector === '.ancre') return values.filter(node => node.classList.contains('ancre'));
    if (selector === 'h1[data-seance]') return values.filter(node =>
      node.tagName === 'H1' && /^seance-\d{2}$/.test(node.getAttribute('data-seance') || ''));
    return [];
  }
  querySelector(selector) { return this.querySelectorAll(selector)[0] || null; }
}

const globalAudit = { focusLog: [], scrollLog: [], rects: {} };

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
  globalAudit.rects = Object.assign({
    contexte: 10,
    'contexte-intro': 50,
    'seance-01-h1': 100,
    'activite-01': 180,
    'seance-02-h1': 300,
    'activite-02': 380
  }, options.rects || {});

  const ids = new Map();
  const body = element('body');
  function register(node) {
    if (node.id) ids.set(node.id, node);
    return node;
  }
  function control(id, tag = 'div') {
    const node = element(tag);
    node.id = id;
    return register(node);
  }

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

  const index = control('index-seances', 'section');
  index.setAttribute('aria-labelledby', 'titre-index-seances');
  index.setAttribute('tabindex', '-1');
  const indexTitle = control('titre-index-seances', 'h2');
  indexTitle.textContent = 'Choisir une séance';
  const list = control('liste-seances', 'ul');
  list.setAttribute('aria-labelledby', 'titre-index-seances');
  index.appendChild(indexTitle);
  index.appendChild(list);

  const skip = control('saut-region', 'a');
  skip.href = '#index-seances';
  const tocBarre = control('toc-barre', 'div');
  const btnToc = control('btn-toc', 'button');
  tocBarre.appendChild(btnToc);
  btnToc.setAttribute('aria-expanded', 'false');
  const error = control('seance-erreur', 'div');
  const errorText = control('seance-erreur-texte', 'p');
  const btnToutes = control('btn-toutes', 'button');
  error.appendChild(errorText);
  error.appendChild(btnToutes);
  const doc = control('vue-doc', 'div');
  doc.classList.add('lecture');
  doc.appendChild(sidebar);
  doc.appendChild(article);
  const nav = control('nav-seances', 'nav');
  const btnIndex = control('btn-index', 'button');
  btnIndex.classList.add('bouton');
  btnIndex.textContent = 'Toutes les séances';
  const lienPrec = control('seance-prec', 'a');
  const lienSuiv = control('seance-suiv', 'a');
  const select = control('seance-select', 'select');
  for (const id of ['btn-doc', 'btn-pdf', 'btn-theme']) control(id, 'button');
  const pdf = control('vue-pdf', 'div');
  pdf.classList.add('panneau-pdf');
  const allOption = element('option', 'Toutes les séances');
  allOption.setAttribute('value', '');
  select.appendChild(allOption);
  nav.appendChild(btnIndex);
  nav.appendChild(lienPrec);
  nav.appendChild(select);
  nav.appendChild(lienSuiv);
  lienPrec.appendChild(element('span'));
  lienSuiv.appendChild(element('span'));

  const header = element('header', '', 'site');
  header.id = 'site-header';
  register(header);
  body.appendChild(header);
  body.appendChild(error);
  body.appendChild(index);
  body.appendChild(tocBarre);
  body.appendChild(doc);
  body.appendChild(nav);
  body.appendChild(pdf);
  body.scrollHeight = 1200;

  const initial = new URL(options.url || 'https://example.test/Cahier-De-Laboratoire/index.html');
  const location = { href: initial.toString(), hash: initial.hash };
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
      error.audit.push(entry);
    },
    pushState(_state, _title, value) {
      updateLocation(value);
      const entry = 'push:' + location.href;
      historyAudit.push(entry);
      error.audit.push(entry);
    }
  };
  const windowListeners = new Map();
  const mediaListeners = new Map();
  const frames = [];
  const desktopBreakpoint = options.desktopBreakpoint !== false;
  function fakeMedia(query, matches) {
    const listeners = [];
    const media = {
      matches,
      addEventListener(type, listener) { if (type === 'change') listeners.push(listener); },
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
      return fakeMedia(query, query === '(min-width: 1000px)' ? desktopBreakpoint : false);
    }
  };
  function documentGetElementById(id) {
    return ids.get(id) || body.descendants().find(node => node.id === id) || null;
  }
  const document = {
    body,
    documentElement: element('html'),
    createElement: tag => element(tag),
    getElementById: documentGetElementById,
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
      if (selector === 'h1[data-seance]' || selector === '#contenu h1[data-seance]') return article.querySelectorAll('h1[data-seance]');
      if (selector === '.doc .ancre') return article.descendants().filter(node => node.classList.contains('ancre'));
      return [];
    }
  };
  const storage = new Map();
  if (options.storageMode) storage.set('cahier-vue', options.storageMode);
  const context = {
    document, window, navigator: {}, localStorage: {
      getItem: key => storage.has(key) ? storage.get(key) : null,
      setItem: (key, value) => storage.set(key, String(value))
    }, URL, matchMedia: window.matchMedia
  };
  const source = fs.readFileSync(path.join(__dirname, '..', 'site', 'app.js'), 'utf8');
  vm.runInNewContext(source, context, { filename: 'site/app.js' });
  function indexItems() { return list.children; }
  function indexLinks() { return list.children.map(item => item.children[0]); }
  return {
    ids, blocks, tocByKey, location, historyAudit, documentGetElementById, indexItems, indexLinks,
    setMedia(query, matches) {
      const entry = mediaListeners.get(query);
      if (!entry) return;
      entry.media.matches = matches;
      for (const listener of entry.listeners) listener({ type: 'change', matches });
    },
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
    optionValues() { return select.children.map(option => option.getAttribute('value')); },
    resetWrites() {
      error.audit.length = 0;
      for (const link of tocLinks.concat([lienPrec, lienSuiv])) link.audit.length = 0;
    },
    writeCount(name) {
      return tocLinks.concat([lienPrec, lienSuiv])
        .reduce((sum, link) => sum + link.audit.filter(item => item === name).length, 0);
    },
    listenerCount(type) { return (windowListeners.get(type) || []).length; },
    navigate(url) { updateLocation(url); },
    fire(type) {
      for (const listener of windowListeners.get(type) || []) listener({ type });
      if (type === 'scroll') for (const frame of frames.splice(0, frames.length)) frame();
    },
    audit: error.audit
  };
}

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
  let receivedCurrentTarget = null;
  list.addEventListener('click', event => {
    received = event;
    receivedCurrentTarget = event.currentTarget;
  });
  link.dispatch('click', { button: 0 });
  assert.equal(received.target, link);
  assert.equal(receivedCurrentTarget, list);
});

test('default route shows the semantic index and hides document chrome', () => {
  const app = runApp();
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.equal(app.ids.get('contenu').hidden, true);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('toc-barre').hidden, true);
  assert.equal(app.ids.get('nav-seances').hidden, true);
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': true });
  assert.equal(app.ids.get('saut-region').getAttribute('href'), '#index-seances');
  assert.deepEqual(app.focusLog, []);
});

test('index contains one native session link per h1', () => {
  const app = runApp();
  assert.deepEqual(app.indexItems().map(item => item.getAttribute('data-seance')), ['seance-01', 'seance-02']);
  assert.deepEqual(app.indexLinks().map(link => link.getAttribute('href')), [
    '?view=doc&seance=seance-01#seance-01-h1',
    '?view=doc&seance=seance-02#seance-02-h1'
  ]);
  assert.deepEqual(app.indexItems()[0].children[0].children.map(node => node.textContent), [
    'Séance 01', 'Ouvrir la séance'
  ]);
});

test('primary click opens exactly one session and focuses its h1', () => {
  const app = runApp();
  const event = app.indexLinks()[1].dispatch('click', { button: 0 });
  assert.equal(event.defaultPrevented, true);
  assert.equal(new URL(app.location.href).search, '?view=doc&seance=seance-02');
  assert.equal(new URL(app.location.href).hash, '#seance-02-h1');
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('contenu').hidden, false);
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': false });
  assert.deepEqual(app.focusLog, ['seance-02-h1']);
  assert.deepEqual(app.scrollLog, ['seance-02-h1']);
});

test('keyboard activation opens exactly one session', () => {
  const app = runApp();
  app.indexLinks()[0].dispatch('click', { button: 0 });
  assert.equal(new URL(app.location.href).search, '?view=doc&seance=seance-01');
  assert.equal(new URL(app.location.href).hash, '#seance-01-h1');
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': false, 'seance-02': true });
  assert.deepEqual(app.focusLog, ['seance-01-h1']);
});

test('modified index click keeps native navigation behavior', () => {
  const app = runApp();
  const event = app.indexLinks()[0].dispatch('click', { button: 0, metaKey: true });
  assert.equal(event.defaultPrevented, false);
  assert.equal(new URL(app.location.href).search, '');
  assert.deepEqual(app.focusLog, []);
});

test('known session query shows only that session without focus', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-02#seance-02-h1' });
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, false);
  assert.equal(app.ids.get('contenu').hidden, false);
  assert.equal(app.ids.get('sommaire').hidden, false);
  assert.equal(app.ids.get('toc-barre').hidden, false);
  assert.equal(app.ids.get('nav-seances').hidden, false);
  assert.equal(app.ids.get('saut-region').getAttribute('href'), '#contenu');
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': false });
  assert.equal(app.ids.get('seance-select').value, 'seance-02');
  assert.deepEqual(app.focusLog, []);
});

test('empty seance means index and is normalized', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=' });
  assert.equal(new URL(app.location.href).searchParams.has('seance'), false);
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': true });
});

test('session return button returns to the index and moves focus', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02#activite-02' });
  app.ids.get('btn-index').dispatch('click');
  const url = new URL(app.location.href);
  assert.equal(url.search, '?view=doc');
  assert.equal(url.hash, '');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.deepEqual(app.focusLog, ['index-seances']);
});

test('all sessions option returns to the index and moves focus', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-01' });
  app.ids.get('seance-select').value = '';
  app.ids.get('seance-select').dispatch('change');
  assert.equal(new URL(app.location.href).search, '?view=doc');
  assert.equal(new URL(app.location.href).hash, '');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.deepEqual(app.focusLog, ['index-seances']);
});

test('unknown session shows reversible error above the index', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-99#seance-01-h1' });
  assert.equal(app.ids.get('seance-erreur').hidden, false);
  assert.equal(app.ids.get('seance-erreur-texte').textContent, 'Séance introuvable : seance-99.');
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

test('popstate restores index with reversible unknown-session error without focus', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-01' });
  app.resetWrites();
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-99');
  app.fire('popstate');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('seance-erreur').hidden, false);
  assert.equal(app.ids.get('seance-erreur-texte').textContent, 'Séance introuvable : seance-99.');
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': true });
  assert.deepEqual(app.ariaCurrent(), []);
  assert.deepEqual(app.focusLog, []);
});

test('popstate between index and session does not focus', () => {
  const app = runApp({ rects: { 'seance-02-h1': 10 } });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-02#seance-02-h1');
  app.fire('popstate');
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('contenu').hidden, false);
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': false });
  assert.deepEqual(app.focusLog, []);
  assert.equal(app.ids.get('saut-region').getAttribute('href'), '#contenu');
});

test('hashchange within a session does not focus', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02#seance-02-h1', rects: { 'activite-02': 10 } });
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
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02' });
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
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html#seance-02-h1' });
  assert.equal(new URL(app.location.href).search, '');
  assert.equal(new URL(app.location.href).hash, '#seance-02-h1');
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, false);
  assert.equal(app.ids.get('contenu').hidden, false);
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': false });
  assert.deepEqual(app.focusLog, []);
});

test('document index ignores activity, malformed, unknown, detached, and unregistered-wrapper hashes', () => {
  for (const hash of ['#activite-02', '#seance-02%ZZ', '#id-absent', '#contexte']) {
    const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html' + hash });
    assert.equal(app.ids.get('index-seances').hidden, false, hash);
    assert.equal(app.ids.get('vue-doc').hidden, true, hash);
    assert.equal(app.ids.get('sommaire').hidden, true, hash);
    assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false', hash);
    assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': true }, hash);
    assert.deepEqual(app.focusLog, [], hash);
  }
  const detached = runApp();
  const forgedH1 = element('h1', 'H1 non enregistrée');
  forgedH1.id = 'seance-99-h1';
  forgedH1.setAttribute('data-seance', 'seance-99');
  detached.ids.get('contenu').appendChild(forgedH1);
  assert.equal(detached.ids.has('seance-99-h1'), false);
  detached.navigate('https://example.test/Cahier-De-Laboratoire/index.html#seance-99-h1');
  detached.fire('hashchange');
  assert.equal(detached.documentGetElementById('seance-99-h1'), forgedH1);
  assert.equal(detached.ids.get('index-seances').hidden, false);
  const wrapper = element('div', '', 'bloc-seance');
  wrapper.setAttribute('data-seance', 'seance-99');
  const wrongH1 = element('h1', 'H1 dans wrapper non enregistré');
  wrongH1.id = 'seance-98-h1';
  wrongH1.setAttribute('data-seance', 'seance-98');
  wrapper.appendChild(wrongH1);
  detached.ids.get('contenu').appendChild(wrapper);
  detached.navigate('https://example.test/Cahier-De-Laboratoire/index.html#seance-98-h1');
  detached.fire('hashchange');
  assert.equal(detached.ids.get('index-seances').hidden, false);
});

test('default route ignores stored PDF preference', () => {
  const app = runApp({ storageMode: 'pdf' });
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-pdf').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, true);
});

test('explicit PDF remains global and hides index and document', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=pdf&seance=seance-02#activite-02' });
  assert.equal(new URL(app.location.href).search, '?view=pdf');
  assert.equal(new URL(app.location.href).hash, '#activite-02');
  assert.equal(app.ids.get('vue-pdf').hidden, false);
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.equal(app.ids.get('contenu').hidden, true);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.equal(app.ids.get('saut-region').getAttribute('href'), '#vue-pdf');
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': true });
  assert.deepEqual(app.focusLog, []);
});

test('PDF to Document returns to index without focus', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=pdf#seance-02-h1' });
  app.ids.get('btn-doc').dispatch('click');
  assert.equal(new URL(app.location.href).search, '?view=doc');
  assert.equal(new URL(app.location.href).hash, '');
  assert.equal(app.ids.get('index-seances').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
  assert.equal(app.ids.get('vue-pdf').hidden, true);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': true });
  assert.deepEqual(app.focusLog, []);
});

test('PDF never derives a session from a hash', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=pdf#seance-02-h1' });
  assert.equal(app.ids.get('vue-pdf').hidden, false);
  assert.equal(app.ids.get('index-seances').hidden, true);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-barre') && app.ids.get('btn-barre').hidden, undefined);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': true });
  assert.deepEqual(app.focusLog, []);
});

test('mobile breakpoint starts TOC collapsed; desktop session hides TOC on index and PDF', () => {
  const mobile = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01', desktopBreakpoint: false });
  assert.equal(mobile.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  assert.equal(mobile.ids.get('sommaire').hidden, true);
  const desktop = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01', desktopBreakpoint: true });
  assert.equal(desktop.ids.get('btn-toc').getAttribute('aria-expanded'), 'true');
  assert.equal(desktop.ids.get('sommaire').hidden, false);
  mobile.ids.get('btn-toc').dispatch('click');
  assert.equal(mobile.ids.get('sommaire').hidden, false);
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
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01', desktopBreakpoint: true });
  assert.equal(app.ids.get('sommaire').hidden, false);
  app.setMedia('(min-width: 1000px)', false);
  assert.equal(app.ids.get('sommaire').hidden, true);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'false');
  app.setMedia('(min-width: 1000px)', true);
  assert.equal(app.ids.get('sommaire').hidden, false);
  assert.equal(app.ids.get('btn-toc').getAttribute('aria-expanded'), 'true');
});

test('session navigation stays exclusive and preserves the viewer controls', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-01' });
  app.ids.get('seance-suiv').dispatch('click');
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': true, 'seance-02': false });
  assert.deepEqual(app.focusLog, ['activite-02']);
  app.ids.get('seance-prec').dispatch('click');
  assert.deepEqual(app.hiddenByKey(), { contexte: true, 'seance-01': false, 'seance-02': true });
  assert.equal(app.ids.get('seance-select').value, 'seance-01');
});

test('toc search only exposes the current session', () => {
  const app = runApp({ url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01', search: 'cafe', rects: { 'activite-01': 10 } });
  assert.equal(app.tocByKey.get('contexte').hidden, true);
  assert.equal(app.tocByKey.get('seance-01').hidden, false);
  assert.equal(app.tocByKey.get('seance-02').hidden, true);
  assert.equal(app.ids.get('recherche-compte').textContent, '2 résultats');
});

test('template exposes index, skip, return, and focusable visible regions', () => {
  const source = fs.readFileSync(path.join(__dirname, '..', 'site', 'template.html'), 'utf8');
  assert.match(source, /id="saut-region"[^>]+href="#index-seances"/);
  assert.match(source, /<section id="index-seances"[^>]+aria-labelledby="titre-index-seances"[^>]+tabindex="-1"/);
  assert.match(source, /<h2 id="titre-index-seances">Choisir une séance<\/h2>/);
  assert.match(source, /<ul id="liste-seances" aria-labelledby="titre-index-seances"><\/ul>/);
  assert.match(source, /<button type="button" id="btn-index" class="bouton">Toutes les séances<\/button>/);
  assert.match(source, /<div class="lecture" id="vue-doc" hidden>/);
  assert.match(source, /<div class="panneau-pdf" id="vue-pdf" tabindex="-1" hidden>/);
});

test('session index has visible focus and mobile-safe rules', () => {
  const source = fs.readFileSync(path.join(__dirname, '..', 'site', 'style.css'), 'utf8');
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

test('region visibility is settled before navigation and scroll-spy updates', () => {
  const source = fs.readFileSync(path.join(__dirname, '..', 'site', 'app.js'), 'utf8');
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
  const legacy = source.slice(source.indexOf('function seanceDepuisH1'), source.indexOf('function afficherMode'));
  assert.match(legacy, /var bloc=element\.parentElement/);
  assert.match(legacy, /blocsParCle\[cle\]!==bloc/);
  const mediaRegistration = source.slice(source.indexOf('function reagirAuPointRupture'), source.indexOf('var reduction'));
  assert.match(mediaRegistration, /function reagirAuPointRupture\(\)\{\s*afficherRegions\(\);\s*\}/);
  assert.doesNotMatch(mediaRegistration, /appliquerToc\(replierToc\(\)\);/);
  const modeStart = source.indexOf('function afficherMode');
  const modeBodyEnd = source.indexOf('\n  }', modeStart) + 4;
  const mode = source.slice(modeStart, modeBodyEnd);
  assert.match(region, /(?:indexSeances|doc|navSeances|pdf|contenu|tocBarre)\.hidden\s*=/);
  assert.match(region, /majLienEvitement\(\);/);
  assert.doesNotMatch(mode, /(?:indexSeances|doc|navSeances|pdf|contenu|tocBarre|sommaire)\.hidden\s*=/);
  const writeModeStart = source.indexOf('function ecrireMode');
  const writeModeEnd = source.indexOf('\n  }', writeModeStart) + 4;
  const writeMode = source.slice(writeModeStart, writeModeEnd);
  assert.doesNotMatch(writeMode, /(?:indexSeances|doc|navSeances|pdf|contenu|tocBarre|sommaire)\.hidden\s*=/);
  const stateStart = source.indexOf('function actualiserEtat');
  const chooseStart = source.indexOf('function choisirSeance');
  const order = source.slice(stateStart, chooseStart);
  const regionCall = order.indexOf('afficherRegions();');
  const filterCall = order.indexOf('appliquerFiltre();');
  const navigationCall = order.indexOf('majNavigation();');
  const scrollCall = order.indexOf('mettreAJour();');
  assert.ok(regionCall >= 0 && regionCall < filterCall && filterCall < navigationCall && navigationCall < scrollCall);
});
