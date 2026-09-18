// Cahier de laboratoire — document principal
#import "@preview/ttuile:0.2.0": *
#import "@preview/hydra:0.6.3": hydra
#import "@preview/showybox:2.0.4": showybox
#import "@preview/outrageous:0.4.1": *
#import "@preview/outrageous:0.4.1" as _outrageous
#import "@preview/codly:1.3.0": *

#set document(title: "Cahier de laboratoire", author: "DevYatsu")
#set page(paper: "a4", margin: 2cm, number-align: center + bottom)
#set text(font: "DejaVu Sans", size: 11pt, lang: "fr")
#set heading(numbering: "1.")
#set par(justify: true)

#show: codly-init.with()

// En-tête courant + pied de page (ignoré en export HTML)
#set page(
  header: context align(right, text(size: 9pt, fill: gray, hydra(1))),
  footer: context align(center, text(size: 9pt, fill: gray, counter(page).display(both: true))),
)

// ---------- Page de couverture (flux normal, compatible HTML) ----------
#v(4em)
#align(center)[
  #text(size: 28pt, weight: "bold")[Cahier de laboratoire]
  #v(0.6em)
  #text(size: 13pt, fill: gray)[Document individuel de suivi — module, semestre d'automne]
  #v(2em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align(left)[*Auteur :* Yanis Amani],
    align(right)[*Semestre :* Automne],
  )
  #v(0.4em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align(left)[*Module :* "Conception et opération de la sécurité"],
    align(right)[*Date :* #datetime.today().display()],
  )
  #v(2em)
  #box(
    width: 80%,
    inset: 1em,
    stroke: 0.6pt + gray,
    radius: 6pt,
  )[
    #align(left)[
      *Objet :* progression et maîtrise des compétences — problématiques rencontrées, travaux effectués et résultats, recherches documentaires complémentaires.
    ]
  ]
]
#pagebreak(weak: true)

// ---------- Sommaire ----------
= Sommaire
#show outline.entry: _outrageous.show-entry.with(.._outrageous.presets.typst)
#outline(title: none, indent: auto)
#pagebreak()

// Pour ajouter une séance : créer seances/seance-NN.typ en commençant
// le fichier par #pagebreak(), puis ajouter une ligne #include ci-dessous.
#include "contexte.typ"
#include "seances/seance-01.typ"
