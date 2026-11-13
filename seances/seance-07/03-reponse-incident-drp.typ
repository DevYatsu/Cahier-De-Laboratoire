// Réponse à incident et DRP - devoir en binôme sur le stack « drp ».
#import "/template.typ": *

== Réponse à incident et DRP

#encadre("Objectifs")[
  - Rédiger le playbook d'une alerte du stack, exécutable sous stress par
    quelqu'un qui ne l'a pas écrit.
  - Établir le DRP du stack : inventaire et impact, RPO et RTO justifiés,
    stratégie de sauvegarde.
  - Exécuter une vraie restauration après un sinistre, la chronométrer et la
    vérifier jusqu'au service qui répond.
  - Nommer ce que le plan ne couvre pas.
]

=== Métiers pertinents

- *Analyste SOC :* reçoit l'alerte, trie et confirme l'incident avec les
  requêtes du playbook.
- *Responsable de la réponse à incident (CSIRT) :* écrit les playbooks,
  coordonne le confinement et l'escalade.
- *Ingénieur système / SRE :* conçoit les sauvegardes, exerce les restaurations
  et mesure le RTO réel.
- *RSSI :* fixe les objectifs (RPO, RTO, MTD) avec la direction et porte les
  annonces aux autorités.
- *Architecte sécurité :* cloisonne le stack pour qu'une sauvegarde reste hors
  de portée d'un attaquant.

=== Déroulement

- Point de départ : les consignes du cours
  et notre schéma d'architecture.
- Décision : construire le stack
  du schéma sur le modèle de `stack-04`, puis tester le DRP dessus.
- MinIO, prévu pour la copie WORM, n'est plus téléchargeable (images retirées).
  Remplacé par RustFS après un test :
  en mode compliance, la suppression est refusée même au compte racine.
- Obstacles : macOS refuse le port 443 sur `127.0.0.1` sans droits root (port
  8443) ; noms de conteneurs en conflit avec
  `stack-04` (préfixe `drp-`) ; composant S3 d'Alloy expérimental ; Authelia
  redirigeait sans le port.
- Contrôles de l'architecture : lecture de Loki refusée sans certificat ou avec
  celui d'Alloy, écriture refusée avec celui
  de Grafana ; depuis le réseau de Juice Shop, seul Traefik est visible ; le
  socket-proxy refuse un `POST`.
- Test du playbook : 20 logins faux, alerte dans Alertmanager à +26 s, e-mail à
  l'astreinte à +52 s.
- Test du DRP : témoins dans chaque volume, sauvegarde chiffrée (`age`) copiée
  dans le WORM, `podman compose down -v` et
  suppression des secrets, restauration depuis le WORM : *RTO mesuré 70 s*, 14
  vérifications sur 14.
- Piège découvert en plus de celui du cours : `podman volume import` fusionne,
  il ne remplace pas ; il faut vider le volume.

=== Usage de l'IA

- *Outil et modèle :* Claude Code (CLI), modèle Claude Opus 5.5
  (`claude-opus-5-5`).
- *Prompts :* « les consignes sont dans les dernieres pages du powerpoint … il
  faut que tu fasses tout ce qui est demander
  dans les consignes » ; « reprends comment la stack-04 est structurer et fais
  un docker compose mais avec notre nouvelle
  stack definis dans l'activite » ; « pourquoi rustfs ? ».
- *Produit par l'IA :* le stack (Compose et configurations), les scripts de
  sauvegarde, de restauration et de vérification,
  l'exécution du test et le devoir.
- *Rejeté :* MinIO (images introuvables) ; exposer 443 sur toutes les interfaces
  (surface d'attaque).
- *Corrigé :* un bug de l'IA dans son propre script (témoin Grafana non créé,
  repéré grâce au « OK » manquant) ;
  la restauration, complétée par le vidage des volumes avant l'import.
- *Mon jugement :* les mesures viennent des journaux d'exécution
  (`stack/journaux/`), donc vérifiables ; les choix
  d'organisation (RPO, RTO, MTD, rôles du playbook) sont à défendre sans l'IA,
  je les ai relus pour pouvoir les expliquer.

=== Résultats

Devoir rendu en PDF (`pratique/DRP/devoir/devoir-drp.pdf`) : playbook PB-01,
DRP, restauration testée, limites.

=== Interprétation des résultats

Une sauvegarde ne vaut que si on la restaure : la nôtre n'est validée que par
les témoins retrouvés après un vrai sinistre,
pas par la réussite de l'export. Le test a mesuré le meilleur cas (même poste,
images en cache) ; le point faible reste
la copie WORM, hébergée sur la même machine, alors que le 3-2-1 exige une copie
réellement hors site.
