// Activité 11 - schéma général conception et opération de la sécurité.
#import "/template.typ": *

== Activité 11 : Schéma général conception et opération de la sécurité

#encadre("Objectifs")[
  - Représenter la sécurité au niveau de l'entreprise, comme un cycle de
    pilotage et non comme une liste d'outils.
  - Relier conception (gouverner, planifier) et opération (déployer, piloter,
    revoir) dans une seule boucle.
  - Brancher la veille de l'activité 10 sur ce cycle, comme entrée de la
    planification.
]

=== Métiers pertinents

- *Direction générale :* fixe l'ambition, arbitre les risques résiduels et
  alloue le budget.
- *RSSI :* traduit l'ambition en PSSI et en programme, puis rend compte à la
  direction.
- *Risk manager / conformité :* conduit l'analyse de risques et suit les
  exigences légales.
- *Chefs de projet et managers métier :* déploient les mesures et portent le
  changement dans les équipes.
- *Auditeur interne :* contrôle l'efficacité des mesures et alimente la revue de
  direction.

=== Déroulement

Je pars du cycle d'amélioration continue (PDCA, Plan-Do-Check-Act) d'ISO 27001,
puis je l'adapte au niveau de la direction. J'ajoute une étape *Gouverner* en
tête, car le cycle suppose une orientation et un budget déjà décidés. Je garde
ensuite un seul niveau de détail : chaque bloc nomme une responsabilité, sans
descendre vers les outils techniques. Enfin, je ferme la boucle par *Revoir* →
*Planifier*, pour que les enseignements modifient le plan suivant.

=== Résultats

Schéma au niveau de l'entreprise, donc très global : il cadre le pilotage, pas
l'implémentation.

#table(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  align: center + horizon,
  [*Gouverner*],
  [→],
  [*Planifier*],
  [→],
  [*Déployer*],
  [→],
  [*Piloter*],
  [→],
  [*Revoir*],
)

Boucle d'amélioration continue : *Revoir* → *Planifier*.

- *Gouverner :* la direction oriente, arbitre les risques et alloue les budgets.
- *Planifier :* périmètre, analyse de risques, PSSI, programme et priorités.
- *Déployer :* organisation, rôles, ressources et conduite du changement.
- *Piloter :* indicateurs, audits, conformité et suivi des décisions.
- *Revoir :* revue de direction, enseignements, nouvelle ambition.

=== Interprétation des résultats

La sécurité se pilote comme un programme d'entreprise, pas comme un chantier
technique : chaque bloc engage la direction avant les outils. Planifier sans
piloter reste une intention, et piloter sans revoir fige le système ; la boucle
de retour porte donc l'amélioration continue. L'implémentation (SIEM, patch,
IRP) n'est qu'un moyen au service du plan : elle se décide en Déployer et se
mesure en Piloter.
