// Activité 9 - que faire dans Concevoir, Valider et Opérer (cas : une entreprise) ?
#import "/template.typ": *

== Activité 9 : Que faire dans Concevoir, Valider et Opérer (cas : une entreprise) ?

#encadre("Objectifs")[
  - Donner des pistes, pour une entreprise et non un projet spécifique, sur les activités de Concevoir, Valider et Opérer.
  - Ajouter des liens spécifiques d'amélioration continue.
]

=== Métiers pertinents

- *RSSI/CISO :* tient le fil entre les trois étapes, arbitre ce qui entre dans le cycle.
- *Auditeur sécurité :* intervient sur la validation, seul regard extérieur non biaisé.
- *SOC Analyst, GRC Analyst :* exploitation et indicateurs qui ferment la boucle.

=== Résultats

Activités étape par étape, de la conception à l'exploitation :

==== Concevoir

- *Cadrer :* périmètre, valeurs métier, classification des actifs.
  - Chaîne : actifs → menaces et vulnérabilités → risques → mesures.
- *Analyser les risques :*
  - EBIOS RM au niveau stratégique ;
  - STRIDE-LM au niveau technique ;
  - puis hiérarchiser et traiter (éviter, réduire, transférer, accepter).
- *Choisir le référentiel :* ISO 27001/27002, NIST CSF, CIS Controls, ou la MCSR de l'OFCS.
  - Ce choix détermine les contrôles, donc les preuves exigées en Valider.
- *Formaliser :* stratégie alignée sur les objectifs métiers → PSSI → procédures (SOP : acteurs, décisions, escalade).
  - Objectifs SMART.
  - Organisation claire : qui décide, qui applique, qui contrôle.

==== Valider

- *Tests d'intrusion par un externe :* l'équipe qui a conçu ne cherchera pas ce qui l'inquiète.
- *Contrôle des preuves, pas des intentions :* exemple du cours, la revue des habilitations.
  - Exigence → contrôle → indicateur → résultat → preuve.
  - Puis analyse des 2 % restés non conformes.
- *Tests de continuité et de reprise :* un PCA se drill, il ne se rédige pas.
- *Revue des KPI :* MTTD, MTTR, correctifs appliqués dans le délai ; revue de direction.

==== Opérer

- *Supervision :* journalisation centralisée, SIEM, EDR.
  - Un SIEM sans tri des alertes ne sert à rien.
- *Vulnérabilités en continu :* priorisées par exploitabilité réelle, pas par le seul score CVSS.
  - Exemple : le variant Akira a tenu en Suisse grâce à une SonicWall non patchée.
- *Identités :* MFA, moindre privilège, revue des habilitations, révocation aux départs.
- *Réponse et environnement :* IRP (plan de réponse aux incidents), veille, sensibilisation continue.
  - Relations externes : assistance DDoS, signalement à l'OFCS et au PFPDT.

=== Interprétation des résultats

- *Une boucle, pas une feuille de route :* Améliorer renvoie à Gouverner, Gouverner à Concevoir.
- *Valider est l'étape que je garderais en priorité :* elle ne produit rien mais exige des preuves, donc elle engage la responsabilité de celui qui les exige.
- *Rappel de l'activité 4 :* les biais font le plus de dégâts dans Gouverner, qui tranche avec des données incomplètes.
  - Une organisation très bien opérée, mais dont la priorisation penche vers le spectaculaire, aura un bon niveau de maturité et une posture médiocre.
