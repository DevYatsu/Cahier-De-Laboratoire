// Activité 9 - que faire dans Concevoir, Valider et Opérer (cas : une entreprise) ?
#import "/template.typ": *

== Activité 9 : Que faire dans Concevoir, Valider et Opérer (cas : une entreprise) ?

#encadre("Objectifs")[Donner quelques pistes, dans le cas d'une entreprise et non pas d'un projet spécifique, sur les activités à exécuter dans Concevoir, Valider et Opérer, et quelques liens spécifiques d'amélioration continue.]

=== Métiers pertinents

Le RSSI/CISO tient le fil entre les trois étapes et arbitre ce qui entre dans le cycle. L'auditeur sécurité intervient sur la validation, seul regard extérieur non biaisé. Le SOC Analyst et le GRC Analyst assurent l'exploitation et les indicateurs qui ferment la boucle.

=== Résultats

Les activités se lisent étape par étape, de la conception à l'exploitation.

==== Concevoir

- *Cadrer :* périmètre, valeurs métier, classification des actifs. Actifs → menaces et vulnérabilités → risques → mesures.
- *Analyser les risques :* EBIOS RM au niveau stratégique, STRIDE-LM au niveau technique, puis hiérarchiser et traiter (éviter, réduire, transférer, accepter).
- *Choisir le référentiel :* ISO 27001/27002, NIST CSF, CIS Controls, ou la MCSR de l'OFCS. Ce choix détermine les contrôles, donc les preuves qu'on exigera en Valider.
- *Formaliser :* stratégie alignée sur les objectifs métiers, puis PSSI, puis les procédures (SOP : acteurs, décisions, escalade). Poser des objectifs SMART, et une organisation où l'on sait qui décide, qui applique et qui contrôle.

==== Valider

- *Tests d'intrusion*, faits par un externe : l'équipe qui a conçu ne cherchera pas ce qui l'inquiète.
- Contrôle des preuves et non des intentions. Le cours le montre avec la revue des habilitations : exigence → contrôle → indicateur → résultat → preuve, puis l'analyse des 2 % restés non conformes.
- *Tests de continuité et de reprise :* un PCA se drill, il ne se rédige pas.
- *Revue des KPI* (MTTD, MTTR, correctifs appliqués dans le délai) et revue de direction.

==== Opérer

- *Supervision :* journalisation centralisée, SIEM, EDR. Un SIEM sans tri des alertes ne sert à rien.
- *Vulnérabilités en continu*, priorisées par exploitabilité réelle et non par le seul score CVSS (le variant Akira a tenu en Suisse grâce à une SonicWall non patchée).
- *Identités :* MFA, moindre privilège, revue des habilitations, révocation aux départs.
- *IRP*, veille, sensibilisation continue, relations externes (assistance DDoS, signalement à l'OFCS et au PFPDT).

=== Interprétation des résultats

Le schéma se lit comme une feuille de route alors que c'est une boucle : Améliorer renvoie à Gouverner, Gouverner à Concevoir. Valider est l'étape que je garderais en priorité, parce qu'elle ne produit rien mais demande des preuves, donc elle engage la responsabilité de celui qui les exige. Enfin le rappel de l'activité 4 : c'est dans la phase Gouverner, qui tranche avec des données incomplètes, que les biais font le plus de dégâts : une organisation très bien opérée dont la priorisation penche vers le spectaculaire aura un bon niveau de maturité et une posture médiocre.