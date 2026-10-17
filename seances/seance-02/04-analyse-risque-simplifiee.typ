// Exercice 11 - exemple d'analyse de risque simplifiée.
#import "/template.typ": *

== Exercice 11 : Exemple d’analyse de risque simplifiée

#encadre("Objectifs")[
  - Identifier une menace : type, catégorie, impact.
  - Proposer des mesures de réduction adaptées.
]

=== Contexte

Il s'agit d'un cas réel simplifié : la réception unique de données propriétaires auprès d'un fournisseur de données. L'étudiant les exploite sur son ordinateur portable, dans une base MySQL. Le code n'a aucune contrainte particulière, et la structure des données aucune exigence de confidentialité.

=== Contraintes

- Aucun accès de tiers aux données n’est autorisé avant, pendant ou après le projet.
- La destruction des données est garantie après une date fixe.
- Les procédures sont documentées et toute violation est signalée immédiatement.

Toute violation peut entraîner une pénalité allant jusqu'à 50 000 CHF.

#table(
  columns: (1.3fr, 1.65fr, 1.1fr, 0.95fr, 1.7fr),
  align: (left, left, left, left, left),
  [*Menaces*], [*Type*], [#box[*Catégorie*]], [*Impact*], [*Mesure*],
  [Accès DB par tiers], [Externe / interne / humain], [Cat. C], [50 k CHF], [Segmentation, verrouillage, formation],
  [], [], [], [], [],
  [], [], [], [], [],
  [], [], [], [], [],
  [], [], [], [], [],
)
