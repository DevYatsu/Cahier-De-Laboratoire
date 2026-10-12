'use strict';

// Tests of the DOM-free logic exported by site/app.js (search, snippet,
// legacy URL redirects). The browser wiring is exercised by the built site.
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const app = require(path.join(__dirname, '..', 'site', 'app.js'));

const index = [
  {u: 'seance-01.html#a', t: '2.12 Travail personnel : ISO 27001', c: 'Séance 01', x: 'Périmètre du SMSI et déclaration d’applicabilité.'},
  {u: 'seance-01.html#b', t: '2.3 Exercice 3 : Évaluer la triade CIA', c: 'Séance 01', x: 'Confidentialité, intégrité, disponibilité. ISO 27001 mentionnée.'},
  {u: 'seance-02.html#c', t: '3.2 Exercice 6 : Les menaces', c: 'Séance 02', x: 'Menace, vulnérabilité, risque.'},
];

test('normaliser removes case, accents and apostrophes without changing length', () => {
  assert.equal(app.normaliser('Évaluer l’Intégrité'), 'evaluer l integrite');
  assert.equal(app.normaliser('Évaluer l’Intégrité').length, 'Évaluer l’Intégrité'.length);
});

test('search requires every term and ranks title hits first', () => {
  const results = app.rechercher(index, 'iso 27001');
  assert.deepEqual(results.map(r => r.u), ['seance-01.html#a', 'seance-01.html#b']);
  assert.deepEqual(app.rechercher(index, 'iso menace'), []);
});

test('search is accent-insensitive in both directions', () => {
  assert.equal(app.rechercher(index, 'integrite')[0].u, 'seance-01.html#b');
  assert.equal(app.rechercher(index, 'VULNÉRABILITÉ')[0].u, 'seance-02.html#c');
});

test('empty query returns nothing', () => {
  assert.deepEqual(app.rechercher(index, '   '), []);
});

test('snippet marks matches and preserves original accents', () => {
  const segments = app.extrait('Confidentialité, intégrité, disponibilité.', ['integrite']);
  const marked = segments.filter(s => s.m).map(s => s.t);
  assert.deepEqual(marked, ['intégrité']);
  assert.equal(segments.map(s => s.t).join(''), 'Confidentialité, intégrité, disponibilité.');
});

test('snippet adds ellipses when the text is cut', () => {
  const long = 'a '.repeat(200) + 'cible ' + 'b '.repeat(200);
  const segments = app.extrait(long, ['cible'], 60);
  assert.equal(segments[0].t, '… ');
  assert.equal(segments[segments.length - 1].t, ' …');
  assert.ok(segments.some(s => s.m && s.t === 'cible'));
});

test('legacy single-page URLs map to the new pages', () => {
  const anchors = {'exercice-1-auto-evaluation-initiale': 'seance-01.html'};
  assert.equal(app.cibleHeritee('?view=pdf', '', anchors), 'cahier.pdf');
  assert.equal(app.cibleHeritee('?view=doc&seance=seance-02', '#x', anchors), 'seance-02.html#x');
  assert.equal(app.cibleHeritee('', '#exercice-1-auto-evaluation-initiale', anchors),
               'seance-01.html#exercice-1-auto-evaluation-initiale');
});

test('legacy redirect ignores unknown, malformed or hostile input', () => {
  assert.equal(app.cibleHeritee('?seance=../../etc', '', {}), null);
  assert.equal(app.cibleHeritee('', '#inconnue', {}), null);
  assert.equal(app.cibleHeritee('', '#%E0%A4%A', {}), null);
  assert.equal(app.cibleHeritee('', '#toString', {}), null);
  assert.equal(app.cibleHeritee('', '', {}), null);
});
