// Activité 11 - schéma général conception et opération de la sécurité.
#import "/template.typ": *

== Activité 11 : Schéma général conception et opération de la sécurité

=== Résultats

Schéma au niveau de l'entreprise, donc très global : il cadre le pilotage, pas l'implémentation.

#align(center)[
  #diagram(
    spacing: (5mm, 7mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Gouverner*], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Planifier*], fill: white),
    edge("->"),
    node((2, 0), align(center)[*Déployer*], fill: white),
    edge("->"),
    node((3, 0), align(center)[*Piloter*], fill: white),
    edge((3, 0), (0, 1), "->"),
    node((0, 1), align(center)[*Revoir*], fill: fond-rouge),
    edge((0, 1), (1, 0), "->"),
  )
]

- *Gouverner :* la direction oriente, arbitre les risques et alloue les budgets.
- *Planifier :* périmètre, analyse de risques, PSSI, programme et priorités.
- *Déployer :* organisation, rôles, ressources et conduite du changement.
- *Piloter :* indicateurs, audits, conformité et suivi des décisions.
- *Revoir :* revue de direction, enseignements, nouvelle ambition.

=== Interprétation des résultats

- *La sécurité se pilote comme un programme d'entreprise, pas comme un chantier technique :* chaque bloc engage la direction avant les outils.
- *Planifier sans piloter reste une intention ; piloter sans revoir fige le système :* la boucle Revoir → Gouverner porte l'amélioration continue.
- *L'implémentation (SIEM, patch, IRP) n'est qu'un moyen au service du plan :* elle se décide en Déployer, se mesure en Piloter.
