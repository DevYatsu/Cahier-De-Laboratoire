// Activité 8 - résumer les formes courantes de cybercriminalité et leurs conséquences.
#import "/template.typ": *

== Activité 8 : Résumer les formes courantes de cybercriminalité et leurs conséquences

#encadre("Objectifs")[
  - Résumer les formes courantes de cybercriminalité et leurs conséquences.
  - Identifier les criminels.
  - Expliquer pourquoi différencier attaque automatisée, aveugle et attaque ciblée.
  - Décrire ce que fait l'OFCS pour réduire ces risques.
]

=== Métiers pertinents

- *Threat Intelligence Analyst :* qualifie les menaces, distingue le bruit du ciblage.
- *SOC Analyst, Incident Responder :* reçoivent la cybercriminalité en production.
- *GRC Analyst :* voit beaucoup de ces incidents se solder par une obligation de déclaration, non par une sanction technique.

=== Résultats

D'après le catalogue de l'OFCS, l'escroquerie domine largement au 1er semestre 2026.

#table(
  columns: (1fr, 1.9fr, 1.4fr),
  [*Forme*], [*Mécanismes*], [*Conséquence*],
  [Fraude], [faux remboursements, arnaque au président, faux sites, fraude à l'investissement], [Perte financière directe],
  [Hameçonnage], [phishing, vishing, smishing, hameçonnage en temps réel], [Vol d'identifiants, qui devient une porte d'entrée],
  [Extorsion], [rançongiciel puis chantage à la publication], [Touche les trois critères à la fois],
  [Vol et fuite de données], [infostealers], [Identifiants utilisés ailleurs],
  [Disponibilité], [DDoS, defacement], [Réseaux ORB (appareils piratés servant de relais à des tiers)],
)

==== Les criminels

- *Opportuniste :* peu expérimenté.
- *Professionnel :* l'attaque est un revenu ; il industrialise et revend en service (RaaS).
- *Groupe organisé :* vise des victimes précises.
- *Acteur étatique :* espionne ou sabote avec les mêmes outils.
- *Interne :* ou ce qu'on accuse d'en être un.

==== Pourquoi les distinguer

Ces formes traduisent des rapports coût/bénéfice différents côté attaquant, pas une échelle de gravité. L'attaque aveugle ne coûte presque rien, alors que l'attaque ciblée exige de l'OSINT et de la compétence.

Côté défense, les parades diffèrent donc. Contre l'aveugle, être un peu au-dessus de la moyenne suffit (Reine rouge). Contre le ciblé, le point d'entrée n'est pas forcément le sous-système le plus surveillé. La frontière bouge d'ailleurs : selon le rapport 2026, l'IA rend les messages personnalisés et crédibles.

==== Ce que fait l'OFCS

- *Informer :* catalogue des menaces, fiches « que faire ? », rétrospectives hebdomadaires, rapport semestriel.
- *Recueillir :* portail de signalement et, depuis le 1er avril 2025, obligation dans les 24 h pour les infrastructures critiques.
- *Coordonner :* divulgation coordonnée de vulnérabilités, coopération internationale.
- *Renvoi :* antiphishing.ch, PFPDT (art. 24 nLPD), police cantonale.

=== Interprétation des résultats

L'OFCS ne réduit pas la cybercriminalité : il réduit l'asymétrie d'information. Son levier le plus efficace a été réglementaire, en rendant les appelants identifiables. Effet : les signalements d'appels au nom de fausses autorités ont baissé de plus de 75 % en juillet 2026.
