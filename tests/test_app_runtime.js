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
    if (selector === 'h2') return values.filter(node => node.tagName === 'H2');
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
  assert.equal(app.ids.get('seance-suiv').getAttribute('href'), '?view=doc#seance-01-h1');
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
  assert.equal(url.hash, '#activite-01');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.equal(previous.getAttribute('aria-disabled'), 'true');
  assert.equal(next.getAttribute('aria-disabled'), null);

  next.dispatch('click');
  url = new URL(app.location.href);
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#activite-02');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.equal(previous.getAttribute('aria-disabled'), null);
  assert.equal(next.getAttribute('aria-disabled'), 'true');

  previous.dispatch('click');
  url = new URL(app.location.href);
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#activite-01');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
  assert.deepEqual(app.focusLog, [
    'activite-01', 'activite-02', 'activite-01'
  ]);
  assert.deepEqual(app.scrollLog, [
    'activite-01', 'activite-02', 'activite-01'
  ]);
});

test('exclusive navigation hrefs contain target session and activity hash', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-01#activite-01'
  });
  assert.equal(
    app.ids.get('seance-prec').getAttribute('href'),
    '?view=doc&seance=seance-01#activite-01'
  );
  assert.equal(
    app.ids.get('seance-suiv').getAttribute('href'),
    '?view=doc&seance=seance-02#activite-02'
  );
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
  assert.equal(app.ids.get('seance-prec').getAttribute('href'), '?view=doc#activite-01');
  assert.equal(app.ids.get('seance-suiv').getAttribute('href'), '?view=doc#activite-02');
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
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01',
    rects: { 'activite-02': 10 }
  });
  app.resetWrites();
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02#activite-02');
  app.fire('popstate');
  assert.deepEqual(app.hiddenByKey(), {
    contexte: true, 'seance-01': true, 'seance-02': false
  });
  assert.deepEqual(app.focusLog, []);
  assert.deepEqual(app.ariaCurrent(), ['#activite-02']);
  assert.equal(app.writeCount('aria-current'), 1);
});

test('popstate restores unknown state without focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01'
  });
  app.resetWrites();
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-99');
  app.fire('popstate');
  assert.equal(app.ids.get('seance-erreur').hidden, false);
  assert.equal(new URL(app.location.href).searchParams.has('seance'), false);
  assert.deepEqual(app.focusLog, []);
  assert.deepEqual(app.ariaCurrent(), ['#contexte-intro']);
  assert.equal(app.writeCount('aria-current'), 1);
});

test('hashchange restores hash state without focus', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02',
    rects: { 'activite-01': 10 }
  });
  app.resetWrites();
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-01');
  app.fire('hashchange');
  assert.equal(new URL(app.location.href).hash, '#activite-01');
  assert.deepEqual(app.focusLog, []);
  assert.deepEqual(app.ariaCurrent(), ['#activite-01']);
  assert.equal(app.writeCount('aria-current'), 1);
});

test('popstate followed by hashchange runs one state cycle', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-02',
    rects: { 'activite-01': 10 }
  });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?seance=seance-01#activite-01');
  app.resetWrites();
  app.fire('popstate');
  app.fire('hashchange');
  assert.equal(app.writeCount('aria-current'), 1);
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
  assert.deepEqual(app.ariaCurrent(), ['#activite-01']);

  app.resetWrites();
  app.ids.get('recherche').value = '02';
  app.ids.get('recherche').dispatch('input');
  app.fire('scroll');
  assert.deepEqual(app.ariaCurrent(), []);
  assert.equal(app.writeCount('aria-current'), 0);
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

test('popstate without query replays stored PDF preference', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc',
    storageMode: 'pdf'
  });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html');
  app.fire('popstate');
  assert.equal(app.ids.get('vue-pdf').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);
});

test('popstate without query replays stored Document preference', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=pdf',
    storageMode: 'doc'
  });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html');
  app.fire('popstate');
  assert.equal(app.ids.get('vue-pdf').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, false);
});

test('popstate switches between PDF and Document and cleans PDF seance', () => {
  const app = runApp({
    url: 'https://example.test/Cahier-De-Laboratoire/index.html?view=doc&seance=seance-01#activite-01'
  });
  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=pdf&seance=seance-02#activite-02');
  app.fire('popstate');
  let url = new URL(app.location.href);
  assert.equal(url.searchParams.get('view'), 'pdf');
  assert.equal(url.searchParams.has('seance'), false);
  assert.equal(url.hash, '#activite-02');
  assert.equal(app.ids.get('vue-pdf').hidden, false);
  assert.equal(app.ids.get('vue-doc').hidden, true);

  app.navigate('https://example.test/Cahier-De-Laboratoire/index.html?view=doc#activite-01');
  app.fire('popstate');
  url = new URL(app.location.href);
  assert.equal(url.searchParams.get('view'), 'doc');
  assert.equal(app.ids.get('vue-pdf').hidden, true);
  assert.equal(app.ids.get('vue-doc').hidden, false);
  assert.deepEqual(app.hiddenByKey(), {
    contexte: false, 'seance-01': false, 'seance-02': false
  });
});
