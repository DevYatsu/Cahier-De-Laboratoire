// Cahier de laboratoire — document principal
#set document(title: "Cahier de laboratoire", author: "DevYatsu")
#set page(paper: "a4", margin: 2cm)
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 24pt, weight: "bold")[Cahier de laboratoire]
  #v(0.3em)
  #text(size: 12pt, fill: gray)[Compilé automatiquement par CI/CD — Typst → Website]
]

#outline()

= Objectif
Ce document est la source Typst du site. Chaque push sur `master` déclenche la CI qui compile ce fichier et publie le site sur GitHub Pages.

= Entrée du _18/09/2026_
#table(
  columns: (auto, 1fr),
  [*Heure*], [09:15 UTC],
  [*Manip*], [Initialisation du cahier + pipeline CI/CD],
  [*Résultat*], [Site déployé depuis Typst],
)

= Prochaine étape
Ajouter les comptes-rendus ici. La CI rebuild le PDF et le site à chaque commit.
