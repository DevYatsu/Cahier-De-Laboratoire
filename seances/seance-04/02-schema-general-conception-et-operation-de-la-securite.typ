// Activité 11 - schéma général conception et opération de la sécurité.
#import "/template.typ": *

== Activité 11 : Schéma général conception et opération de la sécurité

=== Résultats

Schéma au niveau de l'entreprise, donc très global : il cadre le pilotage, pas l'implémentation.

#table(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  align: center + horizon,
  [*Gouverner*], [→], [*Planifier*], [→], [*Déployer*], [→], [*Piloter*], [→], [*Revoir*],
)

Boucle d'amélioration continue : *Revoir* → *Planifier*.

- *Gouverner :* la direction oriente, arbitre les risques et alloue les budgets.
- *Planifier :* périmètre, analyse de risques, PSSI, programme et priorités.
- *Déployer :* organisation, rôles, ressources et conduite du changement.
- *Piloter :* indicateurs, audits, conformité et suivi des décisions.
- *Revoir :* revue de direction, enseignements, nouvelle ambition.

=== Interprétation des résultats

- *La sécurité se pilote comme un programme d'entreprise, pas comme un chantier technique :* chaque bloc engage la direction avant les outils.
- *Planifier sans piloter reste une intention ; piloter sans revoir fige le système :* la boucle Revoir → Gouverner porte l'amélioration continue.
- *L'implémentation (SIEM, patch, IRP) n'est qu'un moyen au service du plan :* elle se décide en Déployer, se mesure en Piloter.
