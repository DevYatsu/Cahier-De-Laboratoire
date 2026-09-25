#import "/template.typ": *

== Exercice 9 : Sensibilisation aux zones d'ombres liées à l'inventaire des menaces

#encadre("Objectifs")[Identifier les stratégies de traitement du risque ; distinguer réduire/atténuer, transférer, éviter et accepter le risque ; comprendre comment les mesures agissent sur la probabilité et l'impact du risque.]


=== Traiter

#align(center)[
  #diagram(
    spacing: (4mm, 6mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((-5, 0), align(center)[*Traiter le risque*], fill: fond-rouge),
    node((-2, 3), align(center)[*Réduire / atténuer* \ #text(size: 9pt)[le risque]], fill: white),
    node((-2, 1), align(center)[*Transférer* \ #text(size: 9pt)[le risque]], fill: white),
    node((-2, -1), align(center)[*Accepter* \ #text(size: 9pt)[le risque]], fill: white),
    node((-2, -3), align(center)[*Éviter* \ #text(size: 9pt)[le risque]], fill: white),
    edge((-5, 0), (-2, 3), "->"),
    edge((-5, 0), (-2, 1), "->"),
    edge((-5, 0), (-2, -1), "->"),
    edge((-5, 0), (-2, -3), "->"),
    node((1, 3), align(center)[*Mesures*], fill: fond-gris),
    edge((-2, 3), (1, 3), "->"),
    node((3.8, 3.6), align(center)[*Probabilité*], fill: white),
    node((3.8, 2.4), align(center)[*Impact*], fill: white),
    edge((1, 3), (3.8, 3.6), "->"),
    edge((1, 3), (3.8, 2.4), "->"),
    node((1, 1), align(center)[#text(size: 9pt)[Assurance \ Sous-traitance \ Externalisation \ Contrat]], fill: fond-gris),
    edge((-2, 1), (1, 1), "->"),
    node((1, -3), align(center)[*Renoncer à l'activité*], fill: fond-gris),
    edge((-2, -3), (1, -3), "->"),
  )
]
