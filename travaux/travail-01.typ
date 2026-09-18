// Imports requis car un fichier inclus n'hérite pas de ceux de main.typ.
// Chaque nouveau fichier travail commence par #pagebreak() ci-dessous.
#import "@preview/showybox:2.0.4": showybox
#pagebreak()
= Travail 1 — Chapitre 1 : découverte et auto-évaluation (18/09/2026)

#showybox(
  title: "Objectifs",
  frame: (border-color: blue.darken(20%), title-color: blue.darken(30%)),
)["Chapitre 1 : réaliser une auto-évaluation initiale de mes compétences en sécurité (exercice 1) et rappeler les critères de sécurité principaux et secondaires (exercice 2)."]

== Métiers pertinents
"À rédiger proprement : métiers concernés et en quoi ce travail les éclaire."

== Déroulement (journal)
=== 18/09/2026 — Exercice 1 : auto-évaluation initiale
Tableau recopié de l'énoncé, à remplir avec des notes de 1 à 5.

#table(
  columns: (1fr, auto),
  [*Thème*], [*1 à 5*],
  [Compréhension générale des enjeux de la sécurité (pourquoi c'est important, quels types de menaces existent, comment les traiter)], [],
  [Compréhension des thèmes déjà vus — niveau théorique], [],
  [Mise en pratique de ces thèmes — niveau appliqué], [],
  [Conscience de la sécurité quand je conçois / développe / maintiens un projet (y compris contributions open source éventuelles)], [],
  [Réflexes de développement sécurisé concret], [],
  [Gestion des risques (avoir déjà dû, même informellement, déterminer les menaces puis évaluer les risques / impacts d'un choix, par exemple technique)], [],
  [Outils cryptographiques (compréhension et usage régulier)], [],
  [Confinement OS et réseaux (sandboxing, segmentation réseau, etc.)], [],
  [Conscience des risques liés au facteur humain (ingénierie sociale, phishing)], [],
  [Suivi de sources d'information sécurité (blogs, mailing-lists, CVE, etc.) de logiciels spécifiques, de plateformes spécifiques, ou générales], [],
  [Envie d'appliquer ce que je vais apprendre en 3275.1 et 3275.2 (semestre d'automne) dans mon projet de semestre], [],
)

=== 18/09/2026 — Exercice 1 (suite) : questions de synthèse
À répondre rapidement (une phrase suffit par question).

- *Sur quel(s) thème(s) je me sens le plus à l'aise, et pourquoi ?*
  "À compléter."
- *Sur quel(s) thème(s) j'aimerais progresser en priorité ?*
  "À compléter."
- *Ai-je déjà conscience que sécuriser une entreprise n'est pas la même chose que sécuriser un développement logiciel ? Si non, pourquoi cette distinction me semble-t-elle floue ?*
  "À compléter."

=== 18/09/2026 — Exercice 2 : critères principaux et secondaires
Notes en vrac (rappel des critères).

*Critères principaux :*
- Confidentialité
- Intégrité
- Disponibilité

*Critères secondaires :*
- Identification :
  - Responsable / traçabilité → non-répudiation / imputabilité
  - Accès
- Authentification
- Sensibilisation
- Résilience

#showybox(
  title: "Résultats",
  frame: (border-color: green.darken(20%), title-color: green.darken(30%)),
)["À rédiger proprement : résultats obtenus."]

#showybox(
  title: "Interprétation des résultats",
  frame: (border-color: orange.darken(20%), title-color: orange.darken(30%)),
)["À rédiger proprement : pertinence par rapport aux métiers, aux normes / standards / certifications, au cycle d'amélioration continue de la cybersécurité, et à l'apprentissage effectué."]
