// Wrapper: ISO 27001 chain (seances/seance-01/12-travail-personnel-iso-27001.typ:20-35).
#import "/template.typ": *

#set page(width: auto, height: auto, margin: 8pt)

#align(center)[
  #diagram(
    spacing: (10mm, 8mm),
    node-inset: 7pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Direction*\ Enjeux], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Risques*\ Actifs + C/I/A], fill: white),
    edge("->"),
    node((2, 0), align(center)[*SoA*\ Applique / écarte], fill: white),
    edge("->"),
    node((3, 0), align(center)[*Mesures*\ Annexe A + PDCA], fill: fond-rouge, stroke: encre),
  )
]
