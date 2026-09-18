// Cahier de laboratoire — document principal
#import "@preview/ttuile:0.2.0": *
#import "@preview/hydra:0.6.3": hydra
#import "@preview/showybox:2.0.4": showybox
#import "@preview/outrageous:0.4.1": *
#import "@preview/outrageous:0.4.1" as _outrageous
#import "@preview/codly:1.3.0": *

#set document(title: "Cahier de laboratoire", author: "DevYatsu")
#set page(paper: "a4", margin: 2cm, number-align: center + bottom)
#set text(font: "New Computer Modern", size: 11pt, lang: "fr")
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

= Concept
Document individuel décrivant, au sein du module, la progression et la maîtrise des compétences : problématiques rencontrées, travaux effectués et leurs résultats, recherches documentaires complémentaires. Il sert d'outil d'auto-évaluation, guide et justifie une réflexion plus en profondeur, et démontre le savoir-agir en situation réelle ou quasi-réelle. Explicité au début de la formation, débuté dès la 1ère semaine de cours et maintenu durant tout le module. Il fait partie de l'évaluation.

= Fonctionnement du cours
Cours en partie en classe inversée : l'étudiant étudie en autonomie certains sujets (avec des ressources proposées par l'enseignant) et produit un résultat théorique, pratique et recul dans ce cahier. Les séances servent ensuite aux discussions, exercices et laboratoires avec l'enseignant. Le travail autonome se fait durant les plages de cours normales (dont certaines l'après-midi, parfois sous supervision d'un assistant). Peu de longues présentations ; priorité aux retours d'expérience et à l'apprentissage individuel.

= Méthode de rédaction
Pour chaque travail réalisé, seules les sections en *gras* ci-dessous sont à rédiger proprement. Les autres restent en notes de journal (vrac) :
- *objectifs*, *identification des métiers pertinents*, déroulement en vrac (journal, résultats intermédiaires, références), *résultats*, *interprétation des résultats* (pertinence : métiers, normes, standards et certifications, cycle d'amélioration continue de la cybersécurité, apprentissage effectué).
- En préparation finale d'examen : ajout de structuration, références et renvois internes, recul renforcé.

// Gabarit : dupliquer cette section par travail réalisé.
// Chaque nouveau travail commence sur une nouvelle page.
#pagebreak()
= Travail 1 — "titre"

#showybox(
  title: "Objectifs",
  frame: (border-color: blue.darken(20%), title-color: blue.darken(30%)),
)["À rédiger proprement : ce que ce travail vise à démontrer ou acquérir."]

== Métiers pertinents
"À rédiger proprement : métiers concernés et en quoi ce travail les éclaire."

== Déroulement (journal)
#table(
  columns: (auto, 1fr),
  [*Date*], [*Notes en vrac*],
  [date], [manipulations, résultats intermédiaires, références],
  [date], [suite des notes],
)

#showybox(
  title: "Résultats",
  frame: (border-color: green.darken(20%), title-color: green.darken(30%)),
)["À rédiger proprement : résultats obtenus."]

#showybox(
  title: "Interprétation des résultats",
  frame: (border-color: orange.darken(20%), title-color: orange.darken(30%)),
)["À rédiger proprement : pertinence par rapport aux métiers, aux normes / standards / certifications, au cycle d'amélioration continue de la cybersécurité, et à l'apprentissage effectué."]
