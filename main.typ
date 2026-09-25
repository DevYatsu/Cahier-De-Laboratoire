// Cahier de laboratoire - document principal.
// La charte, la palette et les helpers viennent de template.typ.
#import "/template.typ": *

#show: cahier

#couverture()
#pagebreak(weak: true)

// ---------- Sommaire ----------
// Le titre du sommaire doit rester hors de l'outline et hors du compteur :
// sinon il apparaît comme première entrée et décale toute la numérotation.
#heading(level: 1, outlined: false, numbering: none)[Sommaire]

// Le sommaire retient les séances et les travaux (niveaux 1 et 2).
// La profondeur 2 exclut toutes les sous-rubriques d'activité, quel que soit
// leur intitulé, sans les retirer du corps du document.
#show outline.entry: it => _outrageous.show-entry(it, .._outrageous.presets.typst)
#outline(title: none, indent: auto, depth: 2)
#v(1em)

// Pour ajouter une séance : créer seances/seance-NN/index.typ en commençant
// le fichier par #pagebreak(), puis ajouter une ligne #include ci-dessous.
// Les items d'une séance sont numérotés par leur nom de fichier (NN-slug.typ)
// et inclus dans l'ordre croissant : le nom de fichier est la seule source
// de vérité pour l'ordre.
#include "contexte.typ"
#include "seances/seance-01/index.typ"
#include "seances/seance-02/index.typ"
