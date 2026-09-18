// Configuration du cahier : palette, mise en page et métadonnées.
// Typst natif (et non TOML) pour garder les longueurs (2cm) et les couleurs
// (rgb) sous leur vrai type, utilisables tels quels par template.typ.

#let config = (
  // Palette de couleurs, centralisée pour toute la charte.
  couleurs: (
    rouge: rgb("#E30613"),
    encre: rgb("#111111"),
    gris: rgb("#6b6b6b"),
    gris-clair: rgb("#999999"),
    gris-bordure: rgb("#d4d4d4"),
    fond-rouge: rgb("#fef2f2"),
    fond-gris: rgb("#f5f5f5"),
    fond-neutre: rgb("#fafafa"),
    gris-titre-n3: rgb("#2b2b2b"),
    sous-titre: rgb("#444444"),
  ),

  // Mise en page globale.
  page: (
    paper: "a4",
    margin: 2cm,
  ),
  texte: (
    font: ("DejaVu Sans", "Arial", "Helvetica"),
    size: 11pt,
    lang: "fr",
  ),
  titres: (
    font: ("DejaVu Sans", "Arial", "Helvetica"),
    numbering: "1.",
    niveau2-size: 13pt,
    niveau3-size: 11.5pt,
  ),
  tableau: (
    stroke: 0.6pt,
    inset: 0.6em,
  ),

  // Métadonnées du document et de la page de couverture.
  document: (
    title: "Cahier de laboratoire",
    author: "Yanis Amani",
  ),
  couverture: (
    marque: "HE-ARC · INGÉNIERIE",
    titre: "Cahier de laboratoire",
    sous-titre: "Suivi individuel — Conception et opération de la sécurité",
    semestre: "Automne",
    module: "3275.1 · 3275.2",
    objet: "progression et maîtrise des compétences — problématiques rencontrées, travaux effectués et résultats, recherches documentaires complémentaires.",
  ),
)
