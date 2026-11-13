// Activité 12 - MCSR appliquée à DataHealth (binôme Adam Belaziz, Yanis Amani).
#import "/template.typ": *

== Activité 12 : MCSR appliquée à DataHealth

#encadre("Objectifs")[
  - Appliquer la norme minimale pour améliorer la résilience informatique (MCSR)
    à un cas réel : DataHealth, plateforme SaaS de télésurveillance médicale
    pour 8 000 patients.
  - Identifier les processus, les objets à protéger et leur besoin de protection
    (phases 1 à 3).
  - Auditer les exigences, mesurer l'écart et prioriser les mesures techniques
    et organisationnelles (MTO).
  - Rédiger une PSSI simplifiée qui découle de l'audit.
]

=== Métiers pertinents

- *Responsable de la sécurité :* conduit l'audit MCSR et porte la PSSI devant la
  direction.
- *Conseiller à la protection des données :* mène l'analyse d'impact et les
  annonces au PFPDT.
- *Auditeur :* évalue chaque exigence et exige une preuve exploitable.
- *DevOps / SRE et Data / ML :* mettent en œuvre les MTO sur la plateforme et le
  data lake.
- *Direction :* approuve la PSSI et accepte par écrit les écarts admissibles.

=== Déroulement

Nous partons du contexte de DataHealth, puis nous dressons le cadre
réglementaire impératif : nLPD, secret professionnel (art. 321 CP), RGPD, et à
confirmer MedDO et LRH. Nous suivons ensuite les phases de la MCSR. La phase 1
décrit cinq processus (P01 à P05). La phase 2 inventorie six objets
informatiques (O01 à O06). La phase 3 classe O02 (plateforme backend et base de
données) et O04 (data lake et moteur ML) en protection accrue. Nous auditons
enfin 28 exigences, avec un statut et une preuve pour chacune, puis nous en
tirons les mesures prioritaires et la PSSI.

=== Résultats

Le document complet est partagé : #link("https://hearc365-my.sharepoint.com/:w:/g/personal/adam-ahmed_belaziz_he-arc_ch/IQA1CEN4R-HvQabBeP4RsUi8ARjIhaptyAaScB6uufDh9BQ?e=E1qo1E")[Activité
12 : MCSR appliquée à DataHealth]

- *Audit :* 26 exigences applicables sur 28, dont 0 satisfaite, 2 partiellement
  satisfaites et 24 non vérifiées.
- *Écarts démontrés :* données brutes identifiantes dans le data lake, contenu
  médical dans les SMS d'alerte.
- *Mesures prioritaires :* huit MTO, dont quatre de priorité 1 (responsable
  sécurité, pseudonymisation à l'ingestion, SMS sans donnée de santé, analyse
  d'impact).
- *Phase 4 :* concepts de sécurité supplémentaires pour O02 et O04.
- *PSSI :* version v0.1, en douze sections.

=== Interprétation des résultats

Le résultat dominant n'est pas un manque de mesures, mais un manque de preuves :
24 exigences sur 26 restent non vérifiées. La MCSR évalue ce que l'entreprise
démontre, pas ce qu'elle affirme. Les valeurs sont donc provisoires et doivent
être recalculées après l'interview avec l'assistant. Les deux écarts démontrés
touchent les données de santé, là où la nLPD et le secret médical rendent
l'écart non admissible. Cela justifie leur priorité 1 devant les mesures
d'organisation.
