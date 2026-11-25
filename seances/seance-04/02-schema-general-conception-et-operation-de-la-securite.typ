// Activité 11 - schéma général conception et opération de la sécurité.
#import "/template.typ": *

== Activité 11 : Schéma général conception et opération de la sécurité

#encadre("Objectifs")[
  - Représenter la sécurité au niveau de l'entreprise avec les six blocs
    demandés : Gouvernance, Conception, Développement, Validation, Déploiement
    et Opération.
  - Détailler, dans chaque bloc, les principales étapes et leurs relations.
  - Placer les boucles d'amélioration continue, dans l'Opération et entre les
    blocs.
  - Brancher la veille de l'activité 10 sur ce cycle.
]

=== Métiers pertinents

- *Direction générale :* fixe l'ambition, arbitre les risques résiduels et
  alloue le budget (Gouvernance).
- *RSSI :* traduit l'ambition en PSSI et en programme, puis rend compte à la
  direction (Gouvernance, Conception).
- *Risk manager / conformité :* conduit l'analyse de risques et suit les
  exigences légales (Conception, Validation).
- *Architecte et développeurs :* conçoivent et réalisent les mesures
  (Conception, Développement).
- *Chefs de projet et managers métier :* déploient les mesures et portent le
  changement dans les équipes (Déploiement).
- *SOC, exploitants, CTI :* supervisent, répondent aux incidents et font la
  veille (Opération).
- *Auditeur interne ou externe :* contrôle l'efficacité des mesures et alimente
  la revue de direction (Validation, Opération).

=== Déroulement

Ma première version partait du cycle PDCA (Plan-Do-Check-Act) d'ISO 27001, en
cinq étapes de pilotage. Elle ne suivait pas la consigne : seule la Gouvernance
y apparaissait explicitement. Je reprends donc les six blocs imposés, puis je
déduis les étapes de chaque bloc à partir des métiers listés ci-dessus. Je
termine par les boucles de retour, qui relient les blocs entre eux.

=== Résultats

Schéma au niveau de l'entreprise : il nomme les étapes sans descendre aux
outils.

*Gouvernance* → *Conception* → *Développement* → *Validation* →
*Déploiement* → *Opération*

==== Étapes et relations dans chaque bloc

#table(
  columns: (auto, 1fr, auto),
  align: (left + horizon, left + horizon, left + horizon),
  table.header([*Bloc*], [*Étapes (→ : produit l'entrée de)*], [*Qui*]),
  [*Gouvernance*],
  [Ambition et appétence au risque → arbitrage et budget → PSSI → rôles et
    responsabilités],
  [Direction, RSSI],

  [*Conception*],
  [Périmètre et actifs → analyse de risques (EBIOS RM) → exigences de sécurité
    → architecture et choix des mesures (SoA)],
  [RSSI, risk manager, architecte],

  [*Développement*],
  [Exigences → réalisation sécurisée (secure by design) → revue de code et
    tests unitaires → durcissement des configurations],
  [Développeurs, architecte],

  [*Validation*],
  [Plan de tests → tests de sécurité et pentest → contrôle des preuves →
    décision d'homologation (go / no-go)],
  [Auditeur, risk manager],

  [*Déploiement*],
  [Plan de déploiement → mise en production → formation et conduite du
    changement → transfert à l'exploitation],
  [Chefs de projet, managers métier],

  [*Opération*],
  [Supervision et détection → réponse aux incidents → gestion des
    vulnérabilités → mesure (KPI) → revue],
  [SOC, exploitants, auditeur],
)

==== Boucles d'amélioration continue

#table(
  columns: (auto, auto, 1fr),
  align: (left + horizon, left + horizon, left + horizon),
  table.header([*De*], [*Vers*], [*Ce qui remonte*]),
  [Opération (revue)],
  [Opération (supervision)],
  [Boucle courte : réglage des règles de détection et des playbooks après
    chaque incident.],

  [Opération], [Développement], [Correctifs à produire suite à une
    vulnérabilité ou à un incident.],
  [Opération], [Conception], [Nouveau risque issu de la veille (activité 10)
    ou d'un retour d'expérience : l'analyse de risques est mise à jour.],
  [Opération], [Gouvernance], [Indicateurs et revue de direction :
    réarbitrage du budget et de l'ambition (Revoir → Planifier).],
  [Validation], [Développement], [Non-conformité détectée : correction avant
    déploiement.],
  [Validation], [Conception], [Exigence intestable ou mesure inadaptée :
    reprise de l'architecture.],
)

=== Interprétation des résultats

Les six blocs forment une chaîne, mais la sécurité tient grâce aux boucles. La
boucle Revoir → Planifier vers la Gouvernance reste lente : une fois par an, au
rythme de la revue de direction. Les boucles courtes (Opération → Opération,
Validation → Développement) corrigent au fil de l'eau, sans attendre ce cycle.
Leur coût augmente avec la distance : un défaut repéré en Validation coûte
moins cher qu'un défaut repéré en Opération (principe du shift left).

La Validation joue le rôle de point de contrôle : elle arrête le flux avant le
Déploiement et exige des preuves, pas des intentions. L'Opération, elle,
alimente toutes les autres : c'est là que la veille et les incidents entrent
dans le cycle.
