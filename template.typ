// Template partagé du cahier : mise en page globale, palette et helpers.
//
// Ce fichier est destiné à être #importé (jamais #inclus) : il ré-exporte les
// packages et les couleurs aux séances, sans que scripts/build_site.py - qui
// suit l'ordre des #include - ne tente de le rendre comme une source.

#import "@preview/hydra:0.6.3": hydra
#import "@preview/showybox:2.0.4": showybox
#import "@preview/outrageous:0.4.1" as _outrageous
#import "@preview/codly:1.3.0": codly-init
#import "@preview/glossarium:0.5.1": make-glossary
#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "@preview/lilaq:0.6.0" as lq
#import "/config.typ": config

#let _c = config.couleurs

// Palette ré-exportée : les séances nomment les couleurs sans littéraux.
#let rouge = _c.rouge
#let encre = _c.encre
#let gris = _c.gris
#let gris-clair = _c.gris-clair
#let fond-rouge = _c.fond-rouge
#let fond-gris = _c.fond-gris
#let fond-neutre = _c.fond-neutre

// Glossaire : stub minimal, prêt à recevoir des entrées via #print-glossary.
#let glossaire = ()

// ---- Règle de mise en page globale ----------------------------------------
// #show: cahier applique la charte à tout le document.
#let cahier(
  doc: config.document,
  fonts: config.texte.font,
  body,
) = {
  set document(title: doc.title, author: doc.author)
  // Sans-serif partout : pile de repli pour le local comme pour la CI Ubuntu.
  set text(font: fonts, size: config.texte.size, lang: config.texte.lang)
  set page(
    paper: config.page.paper,
    margin: config.page.margin,
    number-align: center + bottom,
  )
  show: make-glossary
  show raw: set text(font: ("DejaVu Sans Mono", "DejaVu Sans"))
  show math.equation: set text(font: fonts)
  set heading(numbering: config.titres.numbering)
  show heading: set text(font: config.titres.font)
  show heading.where(level: 1): it => block(spacing: 1.2em)[
    #v(0.4em)
    #box(width: 2.2em, height: 0.28em, fill: rouge, radius: 1pt)
    #v(0.35em)
    #text(weight: "bold", size: 17pt, fill: black, it.body)
  ]
  show heading.where(level: 2): it => block(spacing: 0.9em)[
    #text(weight: "bold", size: config.titres.niveau2-size, fill: black)[#counter(heading).display() #it.body]
    #v(-0.3em)
    #line(length: 100%, stroke: 0.8pt + rouge)
  ]
  show heading.where(level: 3): set text(
    weight: "bold",
    size: config.titres.niveau3-size,
    fill: _c.gris-titre-n3,
  )
  set par(justify: true)
  set table(
    stroke: config.tableau.stroke + _c.gris-bordure,
    inset: config.tableau.inset,
    fill: (_, y) => if y == 0 { encre } else if calc.rem(y, 2) == 0 { fond-gris } else { white },
  )
  show table.cell.where(y: 0): set text(fill: white, weight: "bold")
  show: codly-init.with()
  // En-tête courant + pied de page (ignoré en export HTML).
  set page(
    header: context [
      #grid(columns: (1fr, auto), align: (left, right))[
        #text(size: 8.5pt, weight: "bold", fill: rouge)[HE–ARC] #text(size: 8.5pt, fill: gray)[· Cahier de laboratoire]
      ][
        #text(size: 9pt, fill: gray, hydra(1))
      ]
      #v(-0.4em)
      #line(length: 100%, stroke: 0.6pt + rouge)
    ],
    footer: context [
      #line(length: 100%, stroke: 0.5pt + _c.gris-bordure)
      #v(-0.2em)
      #align(center, text(size: 9pt, fill: gray, counter(page).display()))
    ],
  )
  body
}

// ---- Encadré d'objectifs / résultats --------------------------------------
// Palettes choisie selon le titre, pour reproduire les encadrés de la séance.
#let _encadre-styles = (
  objectifs: (bordure: _c.rouge, fond: _c.fond-rouge),
  resultats: (bordure: _c.encre, fond: _c.fond-gris),
  interpretation: (bordure: _c.gris, fond: white),
)

#let _encadre-style(titre) = {
  let t = lower(titre)
  if t.contains("objectif") { _encadre-styles.objectifs }
  else if t.contains("interpr") { _encadre-styles.interpretation }
  else if t.contains("résultat") or t.contains("resultat") { _encadre-styles.resultats }
  else { (bordure: _c.rouge, fond: _c.fond-rouge) }
}

#let encadre(titre, ..corps) = {
  let style = _encadre-style(titre)
  let body = corps.pos().at(0, default: [])
  showybox(
    title: titre,
    title-style: (color: white, weight: "bold"),
    frame: (border-color: style.bordure, title-color: style.bordure, body-color: style.fond),
    body,
  )
}

// ---- Page de couverture ----------------------------------------------------
#let couverture() = {
  let meta = config.couverture
  block(spacing: 0em)[
    #box(width: 100%, height: 0.45em, fill: rouge)
    #v(2.2em)
  ]
  align(left)[
    #text(size: 10pt, weight: "bold", fill: rouge, tracking: 0.18em)[#meta.marque]
    #v(0.5em)
    #text(size: 30pt, weight: "bold", fill: encre)[#meta.titre]
    #v(0.4em)
    #text(size: 12.5pt, fill: _c.sous-titre)[#meta.sous-titre]
    #v(1.2em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      align(left)[#text(fill: rouge, weight: "bold", size: 9pt, tracking: 0.12em)[AUTEUR] \ #text(weight: "bold")[#config.document.author]],
      align(left)[#text(fill: rouge, weight: "bold", size: 9pt, tracking: 0.12em)[SEMESTRE] \ #meta.semestre],
    )
    #v(0.8em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      align(left)[#text(fill: rouge, weight: "bold", size: 9pt, tracking: 0.12em)[MODULE] \ #meta.module],
      align(left)[#text(fill: rouge, weight: "bold", size: 9pt, tracking: 0.12em)[MISE À JOUR] \ #datetime.today().display()],
    )
    #v(1.6em)
    #box(
      width: 100%,
      inset: 1em,
      stroke: (left: 4pt + rouge, rest: 0.6pt + _c.gris-bordure),
      fill: _c.fond-neutre,
      radius: 4pt,
    )[
      #align(left)[
        *Objet :* #meta.objet
      ]
    ]
  ]
}
