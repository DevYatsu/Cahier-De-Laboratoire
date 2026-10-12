# Cahier de laboratoire

[![Build Typst + Deploy Website](https://github.com/DevYatsu/Cahier-De-Laboratoire/actions/workflows/ci.yml/badge.svg)](https://github.com/DevYatsu/Cahier-De-Laboratoire/actions/workflows/ci.yml)

Document individuel de suivi du module (semestre d'automne) : progression et maîtrise des compétences - problématiques rencontrées, travaux effectués et résultats, recherches documentaires complémentaires. Outil d'auto-évaluation, il démontre le savoir-agir en situation réelle ou quasi-réelle. Explicité en début de formation, débuté dès la 1ère semaine, maintenu tout le module. Fait partie de l'évaluation.

## Fonctionnement du cours

Classe inversée : l'étudiant étudie en autonomie certains sujets (ressources proposées par l'enseignant) et produit dans ce cahier un résultat théorique, pratique et recul. Les séances servent aux discussions, exercices et laboratoires avec l'enseignant. Le travail autonome se fait durant les plages de cours normales (dont certaines l'après-midi, parfois supervisées par un assistant). Peu de longues présentations ; priorité aux retours d'expérience et à l'apprentissage individuel.

## Structure d'un travail

Chaque travail suit le même squelette de titres. Seules les sections en **gras** sont à rédiger proprement :

- **Objectifs** - encadré, juste après le titre.
- **Métiers pertinents** - identification des métiers visés par l'activité.
- Déroulement - journal, résultats intermédiaires, références. Section facultative, présente seulement quand il y a de la matière brute à consigner.
- **Résultats**
- **Interprétation des résultats** - pertinence vis-à-vis des métiers, normes, standards et certifications, cycle d'amélioration continue de la cybersécurité, apprentissage effectué.

Une section sans contenu porte le texte `À compléter.` (sans guillemets).

Ces rubriques reviennent à l'identique dans chaque travail. Elles sont donc masquées dans le sommaire, côté PDF (`depth: 2` de l'outline dans `main.typ`) comme côté site (la navigation ne liste que séances et entrées), tout en restant numérotées et visibles dans le corps du document. Le site s'en sert pour la **grille de suivi** : une rubrique absente ou contenant `À compléter.` y apparaît automatiquement.

En préparation finale d'examen : structuration, références et renvois internes ajoutés, recul renforcé.

## Ce dépôt

- `main.typ` - source du cahier.
- `contexte.typ` - cadrage du semestre (objectifs, modules 3275.1/3275.2).
- `seances/seance-NN/index.typ` - point d'entrée d'une séance (commence par `#pagebreak()`, inclus dans `main.typ`). Les travaux de la séance sont des fichiers `NN-slug.typ` dans le même dossier, inclus par `index.typ` dans l'ordre croissant de `NN`. Le nom de fichier est la seule source de vérité pour l'ordre ; chaque fichier réimporte `template.typ`.
- `template.typ`, `config.typ` - charte graphique (couleurs, polices, styles de titres et d'encadrés) et palette.
- `scripts/build_site.py` - convertit les sources Typst en fragments HTML (titres numérotés comme le PDF, tableaux, encadrés, figures).
- `scripts/site_model.py` - regroupe ces fragments en séances et entrées, et calcule l'état des rubriques de chaque entrée.
- `scripts/site_pages.py` - produit les pages du site à partir de `site/layout.html`.
- `scripts/assemble_site.py` - point d'entrée du site (`python3 -m scripts.assemble_site --out public`) et audits des figures.
- `site/` - gabarit commun, feuille de style, `app.js` (recherche plein texte, thème, navigation) et page du rapport d'activité.
- `.github/workflows/ci.yml` - compile `main.typ` en PDF et publie le site (GitHub Pages). Chaque push sur `master` rebuild le PDF et le site.
- `rapport-activite-template.xls` - rapport d'activité : trace les activités effectuées et le temps pris pour chacune.
- Site : https://devyatsu.github.io/Cahier-De-Laboratoire/

## Site web

Une page par séance (`seance-NN.html`), plus :

- **Accueil** - couverture, journal chronologique des séances, guide de lecture, contexte.
- **Grille de suivi** (`suivi.html`) - état de chaque entrée, rubrique par rubrique.
- **Rapport d'activité** (`rapport.html`) - heures reprises du tableur.
- **Recherche** - `Ctrl K` (ou `/`) cherche dans tout le cahier.

Chaque entrée affiche son folio (numérotation du PDF), son type, l'état de ses rubriques et la date de son dernier commit. Les anciens liens du site mono-page (`?seance=seance-02`, `#ancre`) sont redirigés vers la bonne page.

Aperçu local :

```sh
python3 -m scripts.assemble_site --out public
python3 scripts/export_figures.py --outdir public/assets/figs
python3 -m http.server -d public
```
