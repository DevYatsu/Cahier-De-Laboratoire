// Exercice 3 — évaluer la triade CIA sur des cas concrets (partie matin).
#import "/template.typ": *

== Évaluer la triade CIA sur des cas concrets
#text(size: 0.9em, fill: gray)[Partie matin · énoncé 3]

#encadre("Objectifs")[À compléter.]

=== Métiers pertinents

À compléter.

=== Déroulement

On note de 1 à 4 (maximum) la confidentialité, l'intégrité et la disponibilité pour chaque cas. Je recopie le tableau et je le remplis.

#table(
  columns: (1fr, auto, auto, auto),
  [*Cas*], [*C*], [*I*], [*A*],
  [Site d'e-commerce], [3], [3], [3],
  [Banque en ligne suisse], [4], [4], [4],
  [Diffusion message AlertSwiss], [1], [4], [4],
  [Service de streaming vidéo], [2], [2], [4],
)

Le graphique rend les écarts visibles d'un coup d'œil : la banque exige tout au maximum, AlertSwiss sacrifie la confidentialité au profit de l'intégrité et de la disponibilité.
#figure(
  caption: [Notes C-I-A par cas (1 à 4). Rouge : C, noir : I, gris : A.],
)[
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
]

Pourquoi ces notes, en bref :
- *E-commerce (3/3/3) :* une commande modifiée ou une minute d'indisponibilité coûte directement de l'argent, donc I et A élevés ; C à 3 car données clients et paiement, sans atteindre le niveau d'une banque.
- *Banque en ligne (4/4/4) :* le secret bancaire et l'exactitude des soldes priment (C et I au maximum), et l'accès au service doit être continu (A au maximum).
- *AlertSwiss (1/4/4) :* messages publics (C à 1), mais une fausse alerte peut provoquer une panique (I à 4) et le message doit passer en pleine crise (A à 4).
- *Streaming (2/2/4) :* catalogue public et image corrompue peu coûteuse (C et I à 2), par contre un service qui rame fait fuir les abonnés (A à 4).

=== Résultats

À compléter.

=== Interprétation des résultats

À compléter.
