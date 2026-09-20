// Exercice 2 — critères principaux et secondaires (partie matin).
#import "/template.typ": *

== Critères principaux et secondaires
#text(size: 0.9em, fill: gray)[Partie matin · énoncé 2]

#encadre("Objectifs")[À compléter.]

=== Métiers pertinents

À compléter.

=== Déroulement

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

Le schéma résume la triade et ses compléments : les trois critères principaux forment le triangle, les critères secondaires l'entourent.
#align(center)[
  #diagram(
    spacing: (14mm, 12mm),
    node-inset: 8pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 1), [*Confidentialité*], fill: fond-rouge),
    node((-1.2, -0.6), [*Intégrité*], fill: fond-rouge),
    node((1.2, -0.6), [*Disponibilité*], fill: fond-rouge),
    node((0, -0.1), text(size: 9pt, fill: gray)[CIA], stroke: none),
    edge((0, 1), (-1.2, -0.6), "-"),
    edge((-1.2, -0.6), (1.2, -0.6), "-"),
    edge((1.2, -0.6), (0, 1), "-"),
    node((0, 2), text(size: 8.5pt, fill: gris)[Secondaires : identification, authentification, sensibilisation, résilience], stroke: none),
    edge((0, 2), (0, 1), "->", bend: 0deg),
  )
]

=== Résultats

À compléter.

=== Interprétation des résultats

À compléter.
