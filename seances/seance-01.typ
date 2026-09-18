// Imports requis car un fichier inclus n'hérite pas de ceux de main.typ.
// Chaque nouvelle séance commence par #pagebreak() ci-dessous.
#import "@preview/showybox:2.0.4": showybox
#pagebreak()
= Séance du 18 septembre 2026 : découverte et auto-évaluation

#showybox(
  title: "Objectifs",
  frame: (border-color: blue.darken(20%), title-color: blue.darken(30%)),
)[Première séance : j'évalue mon niveau de départ en sécurité (exercice 1) et on revoit ensemble les critères principaux et secondaires (exercice 2).]

== Métiers pertinents
À compléter : quels métiers cette séance éclaire pour moi, et pourquoi ça compte pour la suite.

== Exercice 1 : auto-évaluation initiale
L'énoncé demande de noter de 1 à 5 mon niveau sur chaque thème. Je recopie le tableau et je le remplis pendant la séance.

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

=== Questions de synthèse
Une phrase suffit par question.

- Sur quel(s) thème(s) je me sens le plus à l'aise, et pourquoi ?
  "À compléter."
- Sur quel(s) thème(s) j'aimerais progresser en priorité ?
  "À compléter."
- Ai-je déjà conscience que sécuriser une entreprise n'est pas la même chose que sécuriser un développement logiciel ? Si non, pourquoi cette distinction me semble-t-elle floue ?
  "À compléter."

== Exercice 2 : critères principaux et secondaires
On a rappelé les critères en cours. Je les note en vrac, sans chercher à tout reformuler.

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

== Exercice 3 : évaluer la triade CIA sur des cas concrets
On note de 1 à 4 (maximum) la confidentialité, l'intégrité et la disponibilité pour chaque cas. Je recopie le tableau et je le remplis.

#table(
  columns: (1fr, auto, auto, auto),
  [*Cas*], [*C*], [*I*], [*A*],
  [Site d'e-commerce], [], [], [],
  [Banque en ligne suisse], [], [], [],
  [Diffusion message AlertSwiss], [], [], [],
  [Service de streaming vidéo], [], [], [],
)

#showybox(
  title: "Résultats",
  frame: (border-color: green.darken(20%), title-color: green.darken(30%)),
)[Tableau d'auto-évaluation rempli (exercice 1), critères principaux et secondaires rappelés en séance (exercice 2), triade CIA évaluée sur quatre cas concrets (exercice 3).]

#showybox(
  title: "Interprétation des résultats",
  frame: (border-color: orange.darken(20%), title-color: orange.darken(30%)),
)[À compléter : ce que je retiens de cette première séance pour la suite du semestre.]
