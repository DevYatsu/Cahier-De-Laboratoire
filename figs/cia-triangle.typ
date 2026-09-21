// Wrapper: CIA triangle (seances/seance-01/02-criteres-principaux-secondaires.typ:31-48).
#import "/template.typ": *

#set page(width: auto, height: auto, margin: 8pt)

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
