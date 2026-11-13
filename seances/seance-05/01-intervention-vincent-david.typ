// Intervention Vincent David - sécurité cloud, IA et observabilité.
#import "/template.typ": *

== Intervention spéciale : Vincent David

#encadre("Objectifs")[
  - Situer le périmètre de l'intervenant : de la gouvernance au déploiement d'un
    cloud sécurisé.
  - Retenir l'obligation légale de déclaration des incidents pour les
    infrastructures critiques.
  - Adopter une méthode d'usage de l'IA en cinq étapes : avant, pendant et après
    le prompt.
  - Comprendre pourquoi l'observabilité conditionne la détection, et pour qui
    elle travaille.
]

=== Métiers pertinents

- *Architecte cloud sécurisé :* conçoit l'infrastructure et ses frontières de
  confiance dès la conception.
- *Ingénieur DevSecOps :* intègre la sécurité dans la chaîne de livraison
  (CI/CD) et le déploiement.
- *Responsable gouvernance / RSSI :* fixe les règles, arbitre les risques et
  porte l'obligation de déclaration.
- *Service informatique :* exploite l'infrastructure et consomme les données
  d'observabilité.
- *Analyste SOC :* détecte et qualifie les incidents à partir des journaux,
  métriques et flux.

=== Déroulement

L'intervention couvre trois outils (à compléter : nom et rôle de chacun).

==== Périmètre de l'intervenant

Vincent David travaille sur tout le cycle de vie d'un système cloud :
gouvernance, architecture de cloud sécurisé, conception, livraison (CI/CD) et
déploiement.
La sécurité n'y est pas une étape finale mais un fil continu, de la règle de
gouvernance jusqu'au déploiement.

==== Obligation de déclaration

Les exploitants d'infrastructures critiques ont l'obligation légale de déclarer
leurs cyberattaques.
En Suisse, la loi sur la sécurité de l'information révisée l'impose depuis le
1#super[er] avril 2025, avec un délai de 24 heures auprès de l'OFCS.
L'incident n'est donc plus une affaire interne : il engage l'entreprise
vis-à-vis de l'autorité.

==== Usage de l'IA : avant, pendant, après le prompt

+ *Chercher d'abord :* se documenter seul avant de solliciter l'IA.
+ *Donner le contexte :* préciser le besoin, les contraintes et le périmètre
  dans le prompt.
+ *Vérifier :* recouper la réponse avec une source fiable.
+ *Noter :* tracer ce qui a été obtenu et retenu.
+ *Expliquer sans l'IA :* être capable de restituer le résultat seul, preuve
  qu'il est compris.

==== Observabilité

L'observabilité est nécessaire pour détecter les problèmes efficacement. Elle se
structure en trois questions :

#table(
  columns: (1fr, 2fr),
  [*Question*], [*Réponse*],
  [Pourquoi observer ?], [Suivre les flux de données et réseau, les
    entrées/sorties (I/O) et la latence.],
  [Quoi observer ?], [L'infrastructure, les API et endpoints, l'OS et le
    runtime.],
  [Pour qui ?], [Le service informatique et le SOC.],
)

==== Vocabulaire

Les termes de cette intervention sont regroupés dans la section Vocabulaire, en
fin de cahier.

=== Résultats

*La sécurité couvre tout le cycle de vie.* Le périmètre de l'intervenant va de
la gouvernance au déploiement : chaque étape (conception, CI/CD, déploiement)
porte sa part de sécurité.

*Déclarer un incident est une obligation, pas un choix.* Pour une infrastructure
critique, l'incident sort du cadre interne et doit être signalé à l'OFCS dans un
délai fixé.

*L'IA s'utilise avec méthode.* Les cinq étapes encadrent le prompt : on prépare
avant, on contextualise pendant, on vérifie, trace et s'approprie après.

*Sans observabilité, pas de détection.* Flux, I/O et latence sont les signaux ;
infrastructure, API et runtime sont les cibles ; le service informatique et le
SOC sont les destinataires.

=== Interprétation des résultats

L'observabilité est la condition de la fonction Détecter : on ne repère pas ce
que l'on ne mesure pas. Elle prolonge l'intervention de Pascal Linder (séance
03), où la compromission est restée invisible en interne pendant trois semaines.

L'obligation de déclaration répond à une question laissée ouverte en séance 03 :
ce qui déclenche l'alerte de l'autorité. Elle rend aussi l'observabilité
indispensable, car on ne peut déclarer dans les délais qu'un incident détecté et
caractérisé.

La méthode IA rejoint la logique de la veille (activité 10) : capter vite, puis
valider avant d'exploiter. L'étape « expliquer sans l'IA » est la plus exigeante
; c'est elle qui distingue un résultat compris d'un résultat recopié.

=== Références

- #link("https://hearc365-my.sharepoint.com/:w:/g/personal/adam-ahmed_belaziz_he-arc_ch/IQBSya_WS1sASJz2BSVkygytAXtAetNzZEVTfu5i0RO4CVY?e=TO8b0d")[Activité
  : conception d'une architecture adaptée au déploiement de Juice Shop]
