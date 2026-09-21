// Wrapper: C-I-A notes chart (seances/seance-01/03-triade-cia-cas-concrets.typ:27-43).
#import "/template.typ": *

#set page(width: auto, height: auto, margin: 8pt)

#align(center)[
  #lq.diagram(
    width: 13cm,
    height: 5.5cm,
    xlabel: [Cas],
    ylabel: [Note / 4],
    xaxis: (ticks: ((0, [E-commerce]), (1, [Banque]), (2, [AlertSwiss]), (3, [Streaming])), subticks: none),
    yaxis: (ticks: (0, 1, 2, 3, 4), subticks: none),
    lq.bar((0, 1, 2, 3), (3, 4, 1, 2), width: 0.2, offset: -0.22, fill: rouge, label: [C]),
    lq.bar((0, 1, 2, 3), (3, 4, 4, 2), width: 0.2, offset: 0.0, fill: encre, label: [I]),
    lq.bar((0, 1, 2, 3), (3, 4, 4, 4), width: 0.2, offset: 0.22, fill: gris-clair, label: [A]),
  )
]
