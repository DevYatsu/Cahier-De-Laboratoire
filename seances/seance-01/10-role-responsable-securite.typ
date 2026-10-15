// Activité 6 - rôle de responsable de la sécurité d'une entreprise.
#import "/template.typ": *

== Activité 6 : Rôle de responsable de la sécurité d'une entreprise

#encadre("Objectifs")[
  - Endosser le rôle de RSSI.
  - Montrer que les deux piliers (triade CIA et fonctions Identifier, Protéger, Détecter, Répondre, Récupérer) forment un cadre de pilotage utile face aux cybermenaces.
  - Relier chaque pilier à une décision RSSI concrète et citer les standards qui les portent.
]

=== Métiers pertinents

- *RSSI :* porte le cadre, rend compte à la direction.
- *Risk manager :* chiffre les risques sur la grille CIA.
- *SOC, blue team :* détection et réponse.
- *Admin, développeur :* appliquent la protection.
- *Auditeur :* vérifie la récupération par les tests de restauration.
- *DPO :* rejoint le RSSI sur la confidentialité et la notification.

=== Déroulement

- *Affirmation testée :* les piliers CIA et Identifier / Protéger / Détecter-Répondre / Récupérer donnent un cadre assez concret pour décider.
- *Posture :* la défendre devant ma direction.
- *Trois temps :*
  - fixer les priorités avec CIA ;
  - organiser l'action avec les fonctions ;
  - trancher trois décisions de RSSI.

==== 1. La triade CIA fixe le quoi protéger

- *Confidentialité :* limite qui voit.
- *Intégrité :* personne ne modifie sans droit.
- *Disponibilité :* accès quand il faut.
- *Base :* les quatre cas de l'exercice 3, dont les notes imposent déjà des arbitrages.

#table(
  columns: (1.2fr, 0.8fr, 2fr),
  [*Cas (note C/I/A)*], [*Priorité RSSI*], [*Mesure que j'arbitre en premier*],
  [Banque en ligne (4/4/4)], [Tout au maximum], [HSM et 2FA FIDO2, signatures sur chaque ordre, PRA actif-actif.],
  [E-commerce (3/3/3)], [Équilibre], [Chiffrement des paiements, contrôle des commandes, capacité pour les pics.],
  [AlertSwiss (1/4/4)], [I et A], [Signature des messages et canal de diffusion redondant, même en pleine crise.],
  [Streaming (2/2/4)], [A], [CDN et autoscaling, catalogue public donc C faible.],
)

Premier apport du cadre, même disponibilité à 4 mais budgets différents :
- *AlertSwiss :* investit dans l'authenticité.
- *Streaming :* investit dans la capacité.
- *Sans la grille CIA :* je répartis mal le budget.

==== 2. Les fonctions organisent le comment agir

- *Source :* NIST Cybersecurity Framework (CSF) : Identifier, Protéger, Détecter, Répondre, Récupérer.
- *CSF 2.0 :* ajoute Gouverner (stratégie et supervision par la direction).
- *Choix :* garder les cinq de l'énoncé, Gouverner servant de chapeau.

#table(
  columns: (1fr, 1.6fr, 1.8fr),
  [*Fonction*], [*Action du RSSI*], [*Exemple repris de mes activités*],
  [Identifier], [Inventorier actifs, risques et fournisseurs.], [Cartographie des actifs et analyse top-down d'ISO 27001 (travail personnel).],
  [Protéger], [Durcir, cloisonner, former.], [Backup 3-2-1, moindre privilège, 2FA contre phishing et ransomware (activité 2).],
  [Détecter], [Surveiller et alerter.], [Journaux, alertes hiérarchisées, filtrage contre la surcharge (activité 4).],
  [Répondre], [Isoler, enquêter, notifier.], [Playbook : isoler la machine, forensique, notification PFPDT et OFCS (activité 2).],
  [Récupérer], [Restaurer et apprendre.], [Restauration testée, post-mortem sans blâme, clause 10 d'ISO 27001.],
)

Ordre imposé :
- on ne protège bien que ce qu'on a identifié ;
- on ne répond bien que si on détecte ;
- on ne récupère que si on a préparé ;
- la boucle de retour vers Identifier porte l'amélioration continue.

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

- *Décision 1 : arbitrage budgétaire.* Choisir entre un WAF et un coffre de backups offline.
  - Banque : l'intégrité des soldes impose les deux.
  - Streaming (C/I faibles) : la disponibilité fait passer la capacité avant le chiffrement avancé.
  - Chaque franc justifié par le critère qu'il protège, comme la SoA d'ISO 27001 trace chaque mesure.
- *Décision 2 : ransomware un vendredi soir.* Le SOC signale une machine chiffrée ; chaîne Détecter → Répondre → Récupérer.
  - Isoler la machine.
  - Interdire le paiement (doctrine OFCS et CISA).
  - Forensique avant réinstallation.
  - Restaurer depuis le backup testé.
  - Notifier le PFPDT si des données clients fuient.
  - Sans playbook écrit à l'avance, je négocie sous stress : le biais de jugement (activité 4) décide à ma place.
- *Décision 3 : reporting à la direction.* Des risques sur CIA et l'avancement des cinq fonctions, pas des CVE.
  - Exemple : confidentialité des dossiers patients couverte à 80 %, détection encore manuelle, test de restauration réussi en juin.
  - Langage de la fonction Gouverner : la direction comprend, arbitre et signe, ce qui pèse pour viser ISO 27001.

=== Résultats

- *Deux piliers complémentaires, sans recouvrement :*
  - *CIA, le quoi :* priorités (banque 4/4/4, AlertSwiss 1/4/4, streaming tiré par la disponibilité).
  - *Fonctions, le comment :* identifier avant de protéger, détecter avant de répondre, préparer avant de récupérer.
- *Trois décisions, le cadre en action :*
  - arbitrage budgétaire tracé dans la SoA ;
  - réponse ransomware jouée au playbook ;
  - reporting traduit en risques pour la direction.
- *Chaque pilier seul laisse un angle mort :*
  - CIA sans fonctions reste théorique ;
  - fonctions sans CIA répartissent l'effort à l'aveugle.

=== Interprétation des résultats

- *Je n'ai pas à choisir, j'empile :*
  - CIA porte l'analyse de risques ;
  - les fonctions portent le plan d'action ;
  - ISO 27001 porte la preuve (PDCA, SoA).
- *Défense en profondeur (activité 2) :* chaque fonction rattrape la précédente.
- *Facteur humain (activité 4) :* procédures écrites, alertes hiérarchisées, post-mortems sans blâme rendent les fonctions tenables par des humains fatigués.
- *Méthode pour le projet de semestre :*
  - noter chaque actif en C/I/A ;
  - rattacher chaque mesure à une fonction ;
  - tracer l'écart dans une mini-SoA.
- *Effet :* une liste d'outils devient une posture défendable devant un auditeur ou une direction.

=== Références

- #link("https://www.nist.gov/cyberframework")[NIST, Cybersecurity Framework (CSF) 2.0 : Gouverner, Identifier, Protéger, Détecter, Répondre, Récupérer]
- #link("https://www.iso.org/standard/27001")[ISO, ISO/CEI 27001 (SMSI, SoA, PDCA)]
- #link("https://www.bacs.admin.ch/fr")[OFCS (BACS) : phishing, ransomware, DDoS, fuite de données]
- #link("https://www.cisa.gov/stopransomware/ransomware-guide")[CISA, Ransomware Guide (ne pas payer, backups offline)]
- #link("https://www.cybermalveillance.gouv.fr")[Cybermalveillance.gouv.fr : réflexes et guides pour les entreprises]
