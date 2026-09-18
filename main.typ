// Cahier de laboratoire — document principal
#import "@preview/hydra:0.6.3": hydra
#import "@preview/showybox:2.0.4": showybox
#import "@preview/outrageous:0.4.1" as _outrageous
#import "@preview/codly:1.3.0": *
#import "@preview/unify:0.7.1": qty, numrange
#import "@preview/glossarium:0.5.1": make-glossary, print-glossary, gls, glspl
#import "@preview/tblr:0.5.0": tblr
#import "@preview/booktabs:0.0.4": *
#import "@preview/cetz:0.4.0"
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/lilaq:0.6.0" as lilaq
#import "@preview/physica:0.9.8" as physica
#import "@preview/fontawesome:0.6.2" as fa

// Glossaire (stub minimal : ajouter des entrées dans glossaire puis #print-glossary)
#let glossaire = ()
#show: make-glossary

#set document(title: "Cahier de laboratoire", author: "Yanis Amani")
#set page(paper: "a4", margin: 2cm, number-align: center + bottom)
// Sans-serif partout : pile de repli pour le local comme pour la CI Ubuntu.
#set text(
  font: ("DejaVu Sans", "Arial", "Helvetica"),
  size: 11pt,
  lang: "fr",
)
#show heading: set text(
  font: ("DejaVu Sans", "Arial", "Helvetica"),
)
#show raw: set text(font: ("DejaVu Sans Mono", "DejaVu Sans"))
#show math.equation: set text(font: ("DejaVu Sans", "Arial"))
#set heading(numbering: "1.")
#show heading.where(level: 1): it => block(spacing: 1.2em)[
  #v(0.4em)
  #box(width: 2.2em, height: 0.28em, fill: rgb("#E30613"), radius: 1pt)
  #v(0.35em)
  #text(weight: "bold", size: 17pt, fill: black, it.body)
]
#show heading.where(level: 2): it => block(spacing: 0.9em)[
  #text(weight: "bold", size: 13pt, fill: black)[#counter(heading).display() #it.body]
  #v(-0.3em)
  #line(length: 100%, stroke: 0.8pt + rgb("#E30613"))
]
#show heading.where(level: 3): set text(weight: "bold", size: 11.5pt, fill: rgb("#2b2b2b"))
#set par(justify: true)
#set table(stroke: 0.6pt + rgb("#d4d4d4"), inset: 0.6em, fill: (_, y) => if y == 0 { rgb("#111111") } else if calc.rem(y, 2) == 0 { rgb("#f6f6f6") } else { white })
#show table.cell.where(y: 0): set text(fill: white, weight: "bold")

#show: codly-init.with()

// En-tête courant + pied de page (ignoré en export HTML)
#let hearc = rgb("#E30613")
#let encre = rgb("#111111")
#set page(
  header: context [
    #grid(columns: (1fr, auto), align: (left, right))[
      #text(size: 8.5pt, weight: "bold", fill: hearc)[HE–ARC] #text(size: 8.5pt, fill: gray)[· Cahier de laboratoire]
    ][
      #text(size: 9pt, fill: gray, hydra(1))
    ]
    #v(-0.4em)
    #line(length: 100%, stroke: 0.6pt + hearc)
  ],
  footer: context [
    #line(length: 100%, stroke: 0.5pt + rgb("#d4d4d4"))
    #v(-0.2em)
    #align(center, text(size: 9pt, fill: gray, counter(page).display()))
  ],
)

// ---------- Page de couverture (flux normal, compatible HTML) ----------
#block(spacing: 0em)[
  #box(width: 100%, height: 0.45em, fill: hearc)
  #v(2.2em)
]
#align(left)[
  #text(size: 10pt, weight: "bold", fill: hearc, tracking: 0.18em)[HE–ARC · INGÉNIERIE]
  #v(0.5em)
  #text(size: 30pt, weight: "bold", fill: encre)[Cahier de laboratoire]
  #v(0.4em)
  #text(size: 12.5pt, fill: rgb("#444444"))[Suivi individuel — Conception et opération de la sécurité]
  #v(1.2em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align(left)[#text(fill: hearc, weight: "bold", size: 9pt, tracking: 0.12em)[AUTEUR] \ #text(weight: "bold")[Yanis Amani]],
    align(left)[#text(fill: hearc, weight: "bold", size: 9pt, tracking: 0.12em)[SEMESTRE] \ Automne],
  )
  #v(0.8em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align(left)[#text(fill: hearc, weight: "bold", size: 9pt, tracking: 0.12em)[MODULE] \ 3275.1 · 3275.2],
    align(left)[#text(fill: hearc, weight: "bold", size: 9pt, tracking: 0.12em)[MISE À JOUR] \ #datetime.today().display()],
  )
  #v(1.6em)
  #box(
    width: 100%,
    inset: 1em,
    stroke: (left: 4pt + hearc, rest: 0.6pt + rgb("#d4d4d4")),
    fill: rgb("#fafafa"),
    radius: 4pt,
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
#v(1em)

// Pour ajouter une séance : créer seances/seance-NN.typ en commençant
// le fichier par #pagebreak(), puis ajouter une ligne #include ci-dessous.
#include "contexte.typ"
#include "seances/seance-01.typ"
