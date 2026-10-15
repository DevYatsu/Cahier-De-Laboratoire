// Exercice 3 - évaluer la triade CIA sur des cas concrets (partie matin).
#import "/template.typ": *

== Exercice 3 : Évaluer la triade CIA sur des cas concrets

#encadre("Objectifs")[
  - Appliquer la triade CIA à quatre cas réels.
  - Justifier chaque note de 1 à 4.
  - Comparer les profils pour voir quel critère domine selon le secteur.
]

=== Métiers pertinents

Tous les métiers sont concernés, avec un poids différent selon le cas :
- *Banque :* RSSI, analyste risques.
- *AlertSwiss, streaming :* administrateur réseau.
- *E-commerce :* développeur.

=== Déroulement

- Noter de 1 à 4 (maximum) la confidentialité (C), l'intégrité (I) et la disponibilité (A) de chaque cas.
- Recopier le tableau, puis le remplir.

#table(
  columns: (1fr, auto, auto, auto),
  [*Cas*], [*C*], [*I*], [*A*],
  [Site d'e-commerce], [3], [3], [3],
  [Banque en ligne suisse], [4], [4], [4],
  [Diffusion message AlertSwiss], [1], [4], [4],
  [Service de streaming vidéo], [2], [2], [4],
)

#figure(
  caption: [Notes C-I-A par cas (1 à 4). Rouge : C, noir : I, gris : A.],
)[
  #align(center)[
    #lq.diagram(
      width: 13cm,
      height: 5.5cm,
      xlabel: [Cas],
      ylabel: [Note / 4],
      xaxis: (ticks: ((0, [E-commerce]), (1, [Banque]), (2, [AlertSwiss]), (3, [Streaming])), subticks: none),
      yaxis: (ticks: (0, 1, 2, 3, 4), subticks: none),
      lq.bar((0, 1, 2, 3), (3, 4, 1, 2), width: 0.2, offset: -0.22, fill: rouge, label: [C]),
      lq.bar((0, 1, 2, 3), (3, 4, 4, 2), width: 0.2, offset: 0.0, fill: encre, label: [I]),
      lq.bar((0, 1, 2, 3), (3, 4, 4, 4), width: 0.2, offset: 0.22, fill: gris-clair, label: [A]),
    )
  ]
]

Justification des notes :
- *E-commerce (3/3/3) :*
  - I et A élevés : une commande modifiée ou une minute d'indisponibilité coûte directement de l'argent.
  - C à 3 : données clients et paiement, sans atteindre le niveau d'une banque.
- *Banque en ligne (4/4/4) :*
  - C et I prioritaires : données financières et exactitude des opérations.
  - A à 4 dans mon évaluation : l'accès continu est aussi attendu.
  - Les contraintes légales influencent ces objectifs, sans imposer à elles seules la note maximale.
- *AlertSwiss (1/4/4) :*
  - C à 1 : messages publics.
  - I à 4 : une fausse alerte peut provoquer une panique.
  - A à 4 : le message doit passer en pleine crise.
- *Streaming (2/2/4) :*
  - C et I à 2 : catalogue public, image corrompue peu coûteuse.
  - A à 4 : un service qui rame fait fuir les abonnés.

=== Résultats

- *Banque :* profil maximal 4/4/4.
- *E-commerce :* profil équilibré 3/3/3.
- *AlertSwiss et streaming :* même contraste, C basse (1 et 2) face à A à 4.
- *Différence entre les deux :* l'intégrité, maximale pour AlertSwiss, moyenne pour le streaming.

=== Interprétation des résultats

Chaque profil impose une priorité de conception différente :
- *Banque :* prioriser C et I, tout en maintenant A.
- *AlertSwiss :* protéger l'authenticité du message et sa diffusion en pleine crise.
- *Streaming :* dimensionner l'infrastructure pour absorber la charge du soir.
- *Lien ISO 27001 :* la note dépend du contexte, comme dans l'analyse de risques ; la SoA (déclaration d'applicabilité) trace ensuite ce choix.
