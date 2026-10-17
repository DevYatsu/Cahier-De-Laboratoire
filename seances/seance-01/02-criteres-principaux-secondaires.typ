// Exercice 2 - critères principaux et secondaires (partie matin).
#import "/template.typ": *

== Exercice 2 : Critères principaux et secondaires

#encadre("Objectifs")[
  - Distinguer les trois critères principaux CIA.
  - Identifier les critères secondaires qui les rendent applicables : identification et traçabilité, authentification, sensibilisation, résilience.
]

=== Métiers pertinents

- *Tous les métiers :* chaque rôle arbitre entre ces critères à son niveau.
- *Exemples :* développeur, administrateur, RSSI.

=== Déroulement

Critères rappelés en cours, notés en vrac.

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

Les trois critères principaux (confidentialité, intégrité, disponibilité) forment le triangle du schéma. Quatre critères secondaires l'entourent et le rendent applicable : l'identification (avec traçabilité et accès), l'authentification, la sensibilisation et la résilience.

=== Interprétation des résultats

Les critères secondaires sont plus concrets que la triade seule. Côté développeur, authentification et traçabilité apparaissent dans chaque login et chaque journal. Côté admin, la résilience se joue dans les sauvegardes et la reprise après incident. Pour le projet de semestre, je justifierai chaque mesure par le critère qu'elle protège.
