// Exercice 2 — critères principaux et secondaires (partie matin).
#import "/template.typ": *

== Exercice 2 : Critères principaux et secondaires
#text(size: 0.9em, fill: gray)[Partie matin]

#encadre("Objectifs")[Distinguer les trois critères principaux CIA des critères secondaires qui les rendent applicables : identification et traçabilité, authentification, sensibilisation, résilience.]

=== Métiers pertinents

Tous les métiers sont concernés. Chaque rôle arbitre entre ces critères à son niveau, du développeur à l'administrateur jusqu'au RSSI.

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

J'ai retenu trois critères principaux et quatre appuis autour. La confidentialité, l'intégrité et la disponibilité forment le triangle du schéma. Autour, j'ai placé l'identification avec la traçabilité et l'accès, puis l'authentification, la sensibilisation et la résilience. Le schéma montre bien cette relation : le triangle au centre, les secondaires qui le rendent applicable.

=== Interprétation des résultats

Les critères secondaires m'ont paru plus concrets que la triade seule. En tant que développeur, je vois l'authentification et la traçabilité dans chaque fonction de login et chaque journal. Côté admin, la résilience se joue dans les sauvegardes et la reprise après incident. Je garde ce découpage pour le projet du semestre : il m'aidera à justifier chaque mesure par le critère qu'elle protège.
