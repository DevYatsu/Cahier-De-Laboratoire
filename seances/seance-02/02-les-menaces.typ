#import "/template.typ": *

== Exercice 6 : Que sont les menaces ? D'où proviennent-elles ? Exemples ?

#encadre("Objectifs")[Comprendre les notions de menace, vulnérabilité et risque ; identifier les principales sources de menaces et leurs conséquences ; analyser les relations entre événement, dommage, vulnérabilité et risque.]

=== Evénement

#align(center)[
  #diagram(
    spacing: (10mm, 8mm),
    node-inset: 7pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 1.7), align(center)[*Événement*], fill: fond-rouge),
    node((-1.5, 0), align(center)[*Accident naturel*], fill: white),
    node((0, -1.7), align(center)[*Malveillance intentionnelle*], fill: white),
    node((1.5, 0), align(center)[*Erreur humaine*], fill: white),
    node((0, 0), align(center)[*Dommage*], fill: fond-rouge),
    edge((0, 1.7), (0, 0), "->"),
    edge((-1.5, 0), (0, 0), "->"),
    edge((0, -1.7), (0, 0), "->"),
    edge((1.5, 0), (0, 0), "->"),
  )
]

=== Vulnérabilité

#align(center)[
  #diagram(
    spacing: (10mm, 7mm),
    node-inset: 7pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Vulnérabilité*], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Faiblesse exploitable par une menace*], fill: white),
  )
]

=== Risque

#align(center)[
  #diagram(
    spacing: (12mm, 8mm),
    node-inset: 7pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 2), align(center)[*Risque*], fill: fond-rouge),
    edge((0, 2), (0, 1), "->"),
    node((0, 1), align(center)[#text(size: 9pt)[*Probabilité de survenue* \ (ou vraisemblance) d'une menace]], fill: white),
    edge((0, 1), (0, 0), "->"),
    node((0, 0), align(center)[*Dommage (impact)*], fill: fond-rouge),
  )
]