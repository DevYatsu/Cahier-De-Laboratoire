// Wrapper: RSSI function chain (seances/seance-01/10-role-responsable-securite.typ:48-65).
#import "/template.typ": *

#set page(width: auto, height: auto, margin: 8pt)

#align(center)[
  #diagram(
    spacing: (6mm, 8mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Identifier*], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Protéger*], fill: white),
    edge("->"),
    node((2, 0), align(center)[*Détecter*], fill: white),
    edge("->"),
    node((3, 0), align(center)[*Répondre*], fill: white),
    edge("->"),
    node((4, 0), align(center)[*Récupérer*], fill: fond-rouge),
  )
]
