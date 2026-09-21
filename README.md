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

Ces rubriques reviennent à l'identique dans chaque travail. Elles sont donc masquées dans le sommaire, côté PDF (`rubriques-repetees` dans `main.typ`) comme côté site (`TOC_HIDDEN_LABELS` dans `scripts/build_site.py`), tout en restant numérotées et visibles dans le corps du document. Les deux listes doivent rester synchronisées.

En préparation finale d'examen : structuration, références et renvois internes ajoutés, recul renforcé.

## Ce dépôt

- `main.typ` - source du cahier.
- `contexte.typ` - cadrage du semestre (objectifs, modules 3275.1/3275.2).
- `seances/seance-NN/index.typ` - point d'entrée d'une séance (commence par `#pagebreak()`, inclus dans `main.typ`). Les travaux de la séance sont des fichiers `NN-slug.typ` dans le même dossier, inclus par `index.typ` dans l'ordre croissant de `NN`. Le nom de fichier est la seule source de vérité pour l'ordre ; chaque fichier réimporte `template.typ`.
- `template.typ`, `config.typ` - charte graphique (couleurs, polices, styles de titres et d'encadrés) et palette.
- `scripts/build_site.py` - génère la version web à partir des sources Typst.
- `.github/workflows/ci.yml` - compile `main.typ` en PDF et publie le site (GitHub Pages). Chaque push sur `master` rebuild le PDF et le site.
- `rapport-activite-template.xls` - rapport d'activité : trace les activités effectuées et le temps pris pour chacune.
- Site : https://devyatsu.github.io/Cahier-De-Laboratoire/
