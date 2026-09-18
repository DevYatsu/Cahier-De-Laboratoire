// Cahier de laboratoire — document principal.
// La charte, la palette et les helpers viennent de template.typ.
#import "/template.typ": *

#show: cahier

#couverture()
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
