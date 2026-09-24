// Activité 6 - rôle de responsable de la sécurité d'une entreprise.
#import "/template.typ": *

== Activité 6 : Rôle de responsable de la sécurité d'une entreprise

#encadre("Objectifs")[Endosser le rôle de RSSI et montrer que les deux piliers (triade CIA et fonctions Identifier, Protéger, Détecter, Répondre, Récupérer) forment un cadre de pilotage utile face aux cybermenaces. Je relie chaque pilier à une décision RSSI concrète et je cite les standards qui les portent.]

=== Métiers pertinents

Le RSSI porte ce cadre et rend compte à la direction. Le risk manager chiffre les risques sur la grille CIA. Le SOC et la blue team opèrent la détection et la réponse. L'admin et le dev appliquent la protection. L'auditeur vérifie la récupération avec les tests de restauration. Le DPO rejoint le RSSI sur la confidentialité et la notification.

=== Déroulement

Je pars de l'affirmation de l'énoncé et je la teste comme si je devais la défendre devant ma direction : les piliers CIA et Identifier / Protéger / Détecter-Répondre / Récupérer donnent un cadre assez concret pour décider. Je procède en trois temps : je fixe les priorités avec CIA, j'organise l'action avec les fonctions, puis je tranche trois décisions de RSSI.

==== 1. La triade CIA fixe le quoi protéger

La triade CIA répond à la question du quoi. La confidentialité limite qui voit. L'intégrité garantit que personne ne modifie sans droit. La disponibilité garantit l'accès quand il faut. Je reprends les quatre cas de l'exercice 3, car leurs notes imposent déjà des arbitrages de RSSI.

#table(
  columns: (1.2fr, 0.8fr, 2fr),
  [*Cas (note C/I/A)*], [*Priorité RSSI*], [*Mesure que j'arbitre en premier*],
  [Banque en ligne (4/4/4)], [Tout au maximum], [HSM et 2FA FIDO2, signatures sur chaque ordre, PRA actif-actif.],
  [E-commerce (3/3/3)], [Équilibre], [Chiffrement des paiements, contrôle des commandes, capacité pour les pics.],
  [AlertSwiss (1/4/4)], [I et A], [Signature des messages et canal de diffusion redondant, même en pleine crise.],
  [Streaming (2/2/4)], [A], [CDN et autoscaling, catalogue public donc C faible.],
)

Ce tableau montre le premier apport du cadre : deux services avec la même disponibilité à 4 exigent des budgets différents. AlertSwiss investit dans l'authenticité. Le streaming investit dans la capacité. Sans la grille CIA, je répartis mal le budget.

==== 2. Les fonctions organisent le comment agir

Les fonctions répondent à la question du comment. Elles viennent du NIST Cybersecurity Framework (CSF) : Identifier, Protéger, Détecter, Répondre, Récupérer. La version 2.0 ajoute une sixième fonction, Gouverner, qui couvre la stratégie et la supervision par la direction. Je garde les cinq de l'énoncé pour la démonstration et je note Gouverner comme chapeau.

#table(
  columns: (1fr, 1.6fr, 1.8fr),
  [*Fonction*], [*Action du RSSI*], [*Exemple repris de mes activités*],
  [Identifier], [Inventorier actifs, risques et fournisseurs.], [Cartographie des actifs et analyse top-down d'ISO 27001 (travail personnel).],
  [Protéger], [Durcir, cloisonner, former.], [Backup 3-2-1, moindre privilège, 2FA contre phishing et ransomware (activité 2).],
  [Détecter], [Surveiller et alerter.], [Journaux, alertes hiérarchisées, filtrage contre la surcharge (activité 4).],
  [Répondre], [Isoler, enquêter, notifier.], [Playbook : isoler la machine, forensique, notification PFPDT et OFCS (activité 2).],
  [Récupérer], [Restaurer et apprendre.], [Restauration testée, post-mortem sans blâme, clause 10 d'ISO 27001.],
)

Le schéma résume l'ordre imposé : on ne protège bien que ce qu'on a identifié, on ne répond bien que si on détecte, et on ne récupère que si on a préparé. La boucle de retour vers Identifier porte l'amélioration continue.

#align(center)[
  #diagram(
    spacing: (6mm, 8mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Identifier*], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Protéger*], fill: white),
    edge("->"),
    node((2, 0), align(center)[*Détecter*], fill: white),
    edge("->"),
    node((3, 0), align(center)[*Répondre*], fill: white),
    edge("->"),
    node((4, 0), align(center)[*Récupérer*], fill: fond-rouge),
  )
]

==== 3. Trois décisions de RSSI qui prouvent le cadre

*Décision 1 : arbitrage budgétaire.* La direction me demande de choisir entre un WAF et un coffre de backups offline. La grille CIA tranche : pour la banque, l'intégrité des soldes impose les deux, mais pour le streaming à C/I faibles, la disponibilité fait passer la capacité avant le chiffrement avancé. Je justifie chaque franc par le critère qu'il protège, comme la SoA d'ISO 27001 trace chaque mesure.

*Décision 2 : incident ransomware un vendredi soir.* Le SOC m'appelle : une machine est chiffrée. J'applique la chaîne Détecter → Répondre → Récupérer. J'isole la machine. J'interdis le paiement, selon la doctrine OFCS et CISA. Je lance la forensique avant réinstallation. Je restaure depuis le backup testé. Je notifie le PFPDT si des données clients fuient. Sans playbook écrit à l'avance, je négocie sous stress, et c'est le biais de jugement de l'activité 4 qui décide à ma place.

*Décision 3 : reporting à la direction.* Je ne présente pas des CVE. Je présente des risques sur CIA et l'avancement des cinq fonctions. Exemple : confidentialité des dossiers patients couverte à 80 %, détection encore manuelle, test de restauration réussi en juin. C'est le langage de la fonction Gouverner : la direction comprend, arbitre et signe, ce qui pèse au moment de viser une certification ISO 27001.

=== Résultats

Les deux piliers se complètent sans se recouvrir. CIA dit quoi protéger et avec quelle priorité : banque 4/4/4, AlertSwiss 1/4/4, streaming tiré par la disponibilité. Les cinq fonctions disent comment agir dans l'ordre : identifier avant de protéger, détecter avant de répondre, préparer avant de récupérer. Les trois décisions montrent le cadre en action : arbitrage budgétaire tracé dans la SoA, réponse ransomware jouée au playbook, reporting traduit en risques pour la direction. Chaque pilier seul laisse un angle mort : CIA sans fonctions reste théorique, fonctions sans CIA répartissent l'effort à l'aveugle.

=== Interprétation des résultats

En tant que RSSI, je ne choisis pas entre ces piliers : je les empile. CIA porte l'analyse de risques, les fonctions portent le plan d'action, ISO 27001 porte la preuve avec le PDCA et la SoA. La défense en profondeur de l'activité 2 s'y retrouve : chaque fonction rattrape la précédente. Le facteur humain de l'activité 4 s'y retrouve aussi : procédures écrites, alertes hiérarchisées et post-mortems sans blâme rendent les fonctions tenables par des humains fatigués.

Pour le projet de semestre, j'en retiens une méthode en trois lignes : noter chaque actif en C/I/A, rattacher chaque mesure à une fonction, et tracer l'écart dans une mini-SoA. C'est ce qui transforme une liste d'outils en posture défendable devant un auditeur ou une direction.

=== Références

- #link("https://www.nist.gov/cyberframework")[NIST, Cybersecurity Framework (CSF) 2.0 : Gouverner, Identifier, Protéger, Détecter, Répondre, Récupérer]
- #link("https://www.iso.org/standard/27001")[ISO, ISO/CEI 27001 (SMSI, SoA, PDCA)]
- #link("https://www.bacs.admin.ch/fr")[OFCS (BACS) : phishing, ransomware, DDoS, fuite de données]
- #link("https://www.cisa.gov/stopransomware/ransomware-guide")[CISA, Ransomware Guide (ne pas payer, backups offline)]
- #link("https://www.cybermalveillance.gouv.fr")[Cybermalveillance.gouv.fr : réflexes et guides pour les entreprises]
