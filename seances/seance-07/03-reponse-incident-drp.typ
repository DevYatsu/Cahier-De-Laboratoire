// Réponse à incident et DRP - devoir en binôme (Yanis Amani, Adam Belaziz) sur le stack « drp ».
#import "/template.typ": *

== Réponse à incident et DRP

#encadre("Objectifs")[
  - Écrire le playbook d'une alerte de notre stack, utilisable sous stress par
    quelqu'un qui ne l'a pas rédigé.
  - Établir le plan de reprise après sinistre (DRP) : inventaire, impact, RPO
    et RTO justifiés, stratégie de sauvegarde.
  - Prouver le DRP par une vraie restauration, chronométrée et vérifiée
    jusqu'au service qui répond.
  - Nommer ce que le plan ne couvre pas.
]

=== Métiers pertinents

- *Analyste SOC :* reçoit l'alerte et la qualifie avec les requêtes du
  playbook.
- *Responsable de la réponse à incident (CSIRT) :* rédige les playbooks et
  coordonne confinement et escalade.
- *Ingénieur système / SRE :* conçoit les sauvegardes, exerce les restaurations
  et mesure le RTO réel.
- *RSSI :* fixe RPO, RTO et MTD avec la direction et porte les annonces légales
  (PFPDT, OFCS).

=== Déroulement

- Consigne : en binôme, un PDF de 4 pages maximum, avec quatre parties : un
  playbook, le DRP, la restauration testée et les limites.
- Question de départ : que veut dire « restauration » ? Réponse retenue : partir
  d'un stack détruit (volumes supprimés) et revenir à un service qui marche, en
  suivant une liste de commandes.
- Pas de stack existant pour tester : nous avons construit celui de notre
  schéma d'architecture (Traefik, Authelia, Alloy, Loki, Prometheus,
  Alertmanager, Grafana, Juice Shop) sur le modèle de `stack-04`.
- WORM : MinIO n'est plus téléchargeable, remplacé par RustFS. En mode
  compliance, la suppression est refusée même au compte racine.
- Obstacles : port 443 refusé par macOS (8443), noms de conteneurs en conflit
  avec `stack-04` (préfixe `drp-`), redirection Authelia sans le port.
- Playbook PB-01 (brute-force sur le login) : gravité G1 à G3, rôles,
  escalade, requêtes LogQL prêtes à copier, confinement, preuves,
  communication.
- Test du playbook : 20 logins faux, alerte à +26 s, e-mail à l'astreinte à
  +52 s.
- DRP-01 : inventaire de 8 éléments, MTD 24 h (annonce OFCS), RTO 1 h, RPO 1 min
  pour les logs et 24 h pour les volumes, règle 3-2-1, chiffrement `age`,
  SHA-256.
- Test du DRP : un témoin par volume, sauvegarde copiée dans le WORM, puis
  `podman compose down -v` et suppression des secrets. Restauration depuis le
  WORM : *RTO mesuré 70 s*, 14 vérifications sur 14.
- Piège trouvé : `podman volume import` fusionne au lieu de remplacer. Il faut
  vider le volume avant l'import.
- Mise en page : une fiche autonome par page (PB-01, DRP-01 A, DRP-01 B,
  LIM-01), imprimable seule pendant un incident.

=== Usage de l'IA

- *Outil :* Claude Code (CLI), modèle Claude Opus 5.5 (`claude-opus-5-5`).
- *Prompts principaux :* « reprends comment la stack-04 est structurer et fais
  un docker compose mais avec notre nouvelle stack definis dans l'activite » ;
  « pourquoi rustfs ? » ; « make it so that each page works independently » ;
  « le pdf ne doit pas depasser 4 pages » ; « dis moi si jai bien tout
  implementer dans ce qui est demande dans les consignes ».
- *Usages :*
  - implémenter le stack dans un Compose et corriger les problèmes au fur et à
    mesure, sur macOS et Linux ;
  - comparer MinIO et RustFS pour le stockage WORM ;
  - mettre en forme le devoir en Typst, à partir de nos propres idées ;
  - relire le devoir contre les consignes.
- *Corrigé :* un bug de l'IA dans son script (témoin Grafana non créé, repéré
  par un « OK » manquant) ; la restauration, complétée par le vidage des
  volumes.
- *Mon jugement :* les mesures viennent des journaux d'exécution
  (`stack/journaux/`), donc vérifiables. Les choix (RPO, RTO, MTD, rôles), je
  les ai relus pour pouvoir les défendre sans l'IA.

=== Résultats

Devoir rendu en PDF (`pratique/DRP/devoir/devoir-drp.pdf`) : playbook PB-01,
DRP-01 A et B, restauration testée (RTO 70 s), limites LIM-01.

=== Interprétation des résultats

Une sauvegarde ne vaut que si on la restaure : la nôtre est validée par les
témoins retrouvés après un vrai sinistre, pas par la réussite de l'export. Le
test mesure le meilleur cas (même poste, images en cache). Le point faible reste
la copie WORM, sur la même machine, alors que la règle 3-2-1 exige une copie
réellement hors site.
