# Cahier de laboratoire

[![Build Typst + Deploy Website](https://github.com/DevYatsu/Cahier-De-Laboratoire/actions/workflows/ci.yml/badge.svg)](https://github.com/DevYatsu/Cahier-De-Laboratoire/actions/workflows/ci.yml)

Document individuel de suivi du module (semestre d'automne) : progression et maîtrise des compétences — problématiques rencontrées, travaux effectués et résultats, recherches documentaires complémentaires. Outil d'auto-évaluation, il démontre le savoir-agir en situation réelle ou quasi-réelle. Explicité en début de formation, débuté dès la 1ère semaine, maintenu tout le module. Fait partie de l'évaluation.

## Fonctionnement du cours

Classe inversée : l'étudiant étudie en autonomie certains sujets (ressources proposées par l'enseignant) et produit dans ce cahier un résultat théorique, pratique et recul. Les séances servent aux discussions, exercices et laboratoires avec l'enseignant. Le travail autonome se fait durant les plages de cours normales (dont certaines l'après-midi, parfois supervisées par un assistant). Peu de longues présentations ; priorité aux retours d'expérience et à l'apprentissage individuel.

## Structure d'un travail

Seules les sections en **gras** sont à rédiger proprement :

- **objectifs**
- **identification des métiers pertinents**
- déroulement en vrac (journal, résultats intermédiaires, références, etc.)
- **résultats**
- **interprétation des résultats** — pertinence vis-à-vis des métiers, normes, standards et certifications, cycle d'amélioration continue de la cybersécurité, apprentissage effectué

En préparation finale d'examen : structuration, références et renvois internes ajoutés, recul renforcé.

## Ce dépôt

- `main.typ` — source du cahier.
- `.github/workflows/ci.yml` — compile `main.typ` en PDF et publie le site (GitHub Pages). Chaque push sur `master` rebuild le PDF et le site.
- Site : activer via Settings → Pages → Deploy from GitHub Actions, puis ouvrir l'URL Pages (lecteur PDF seul).
