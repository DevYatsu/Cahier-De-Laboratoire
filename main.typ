// Cahier de laboratoire — document principal.
// La charte, la palette et les helpers viennent de template.typ.
#import "/template.typ": *

#show: cahier

#couverture()
#pagebreak(weak: true)

// ---------- Sommaire ----------
// Le titre du sommaire doit rester hors de l'outline et hors du compteur :
// sinon il apparaît comme première entrée et décale toute la numérotation.
#heading(level: 1, outlined: false, numbering: none)[Sommaire]
#show outline.entry: _outrageous.show-entry.with(.._outrageous.presets.typst)
// Profondeur fixée : #outline() sans argument liste aussi les niveaux 4+.
#outline(title: none, indent: auto, depth: 3)
#v(1em)

// Pour ajouter une séance : créer seances/seance-NN/index.typ en commençant
// le fichier par #pagebreak(), puis ajouter une ligne #include ci-dessous.
// Les items d'une séance sont numérotés par leur nom de fichier (NN-slug.typ)
// et inclus dans l'ordre croissant : le nom de fichier est la seule source
// de vérité pour l'ordre.
#include "contexte.typ"
#include "seances/seance-01/index.typ"
