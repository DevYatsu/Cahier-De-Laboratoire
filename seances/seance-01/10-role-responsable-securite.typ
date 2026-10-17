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

L'affirmation testée est que les piliers CIA et Identifier / Protéger / Détecter-Répondre / Récupérer donnent un cadre assez concret pour décider. Je la défends devant ma direction en trois temps : fixer les priorités avec CIA, organiser l'action avec les fonctions, puis trancher trois décisions de RSSI.

==== 1. La triade CIA fixe le quoi protéger

- *Confidentialité :* limite qui voit.
- *Intégrité :* personne ne modifie sans droit.
- *Disponibilité :* accès quand il faut.

Je repars des quatre cas de l'exercice 3, dont les notes imposent déjà des arbitrages.

#table(
  columns: (1.2fr, 0.8fr, 2fr),
  [*Cas (note C/I/A)*], [*Priorité RSSI*], [*Mesure que j'arbitre en premier*],
  [Banque en ligne (4/4/4)], [Tout au maximum], [HSM et 2FA FIDO2, signatures sur chaque ordre, PRA actif-actif.],
  [E-commerce (3/3/3)], [Équilibre], [Chiffrement des paiements, contrôle des commandes, capacité pour les pics.],
  [AlertSwiss (1/4/4)], [I et A], [Signature des messages et canal de diffusion redondant, même en pleine crise.],
  [Streaming (2/2/4)], [A], [CDN et autoscaling, catalogue public donc C faible.],
)

Premier apport du cadre : à disponibilité égale (4), les budgets diffèrent. AlertSwiss investit dans l'authenticité, le streaming dans la capacité. Sans la grille CIA, je répartirais mal le budget.

==== 2. Les fonctions organisent le comment agir

Les fonctions viennent du NIST Cybersecurity Framework (CSF) : Identifier, Protéger, Détecter, Répondre, Récupérer. Le CSF 2.0 ajoute Gouverner (stratégie et supervision par la direction). Je garde les cinq de l'énoncé, Gouverner servant de chapeau.

#table(
  columns: (1fr, 1.6fr, 1.8fr),
  [*Fonction*], [*Action du RSSI*], [*Exemple repris de mes activités*],
  [Identifier], [Inventorier actifs, risques et fournisseurs.], [Cartographie des actifs et analyse top-down d'ISO 27001 (travail personnel).],
  [Protéger], [Durcir, cloisonner, former.], [Backup 3-2-1, moindre privilège, 2FA contre phishing et ransomware (activité 2).],
  [Détecter], [Surveiller et alerter.], [Journaux, alertes hiérarchisées, filtrage contre la surcharge (activité 4).],
  [Répondre], [Isoler, enquêter, notifier.], [Playbook : isoler la machine, forensique, notification PFPDT et OFCS (activité 2).],
  [Récupérer], [Restaurer et apprendre.], [Restauration testée, post-mortem sans blâme, clause 10 d'ISO 27001.],
)

L'ordre est imposé : on ne protège bien que ce qu'on a identifié, on ne répond bien que si on détecte, et on ne récupère que si on a préparé. La boucle de retour vers Identifier porte l'amélioration continue.

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

*Décision 1 : arbitrage budgétaire.* Je dois choisir entre un WAF et un coffre de backups offline. Pour la banque, l'intégrité des soldes impose les deux. Pour le streaming (C/I faibles), la disponibilité fait passer la capacité avant le chiffrement avancé. Chaque franc est justifié par le critère qu'il protège, comme la SoA d'ISO 27001 trace chaque mesure.

*Décision 2 : ransomware un vendredi soir.* Le SOC signale une machine chiffrée, ce qui déclenche la chaîne Détecter → Répondre → Récupérer :
+ Isoler la machine.
+ Interdire le paiement (doctrine OFCS et CISA).
+ Mener la forensique avant réinstallation.
+ Restaurer depuis le backup testé.
+ Notifier le PFPDT si des données clients fuient.

Sans playbook écrit à l'avance, je négocie sous stress, et le biais de jugement (activité 4) décide à ma place.

*Décision 3 : reporting à la direction.* Je rapporte des risques sur CIA et l'avancement des cinq fonctions, pas des CVE. Par exemple : confidentialité des dossiers patients couverte à 80 %, détection encore manuelle, test de restauration réussi en juin. C'est le langage de la fonction Gouverner : la direction comprend, arbitre et signe, ce qui pèse pour viser ISO 27001.

=== Résultats

Les deux piliers sont complémentaires, sans recouvrement. CIA donne le quoi, c'est-à-dire les priorités (banque 4/4/4, AlertSwiss 1/4/4, streaming tiré par la disponibilité). Les fonctions donnent le comment : identifier avant de protéger, détecter avant de répondre, préparer avant de récupérer. Les trois décisions montrent le cadre en action : un arbitrage budgétaire tracé dans la SoA, une réponse ransomware jouée au playbook, un reporting traduit en risques pour la direction. Chaque pilier seul laisse un angle mort : CIA sans fonctions reste théorique, et des fonctions sans CIA répartissent l'effort à l'aveugle.

=== Interprétation des résultats

Je n'ai pas à choisir entre les cadres, je les empile : CIA porte l'analyse de risques, les fonctions portent le plan d'action et ISO 27001 porte la preuve (PDCA, SoA). Comme pour la défense en profondeur (activité 2), chaque fonction rattrape la précédente. Le facteur humain (activité 4) reste la condition de tenue : procédures écrites, alertes hiérarchisées et post-mortems sans blâme rendent les fonctions tenables par des humains fatigués.

Pour le projet de semestre, la méthode tient en trois gestes : noter chaque actif en C/I/A, rattacher chaque mesure à une fonction, tracer l'écart dans une mini-SoA. Une liste d'outils devient ainsi une posture défendable devant un auditeur ou une direction.

=== Références

- #link("https://www.nist.gov/cyberframework")[NIST, Cybersecurity Framework (CSF) 2.0 : Gouverner, Identifier, Protéger, Détecter, Répondre, Récupérer]
- #link("https://www.iso.org/standard/27001")[ISO, ISO/CEI 27001 (SMSI, SoA, PDCA)]
- #link("https://www.bacs.admin.ch/fr")[OFCS (BACS) : phishing, ransomware, DDoS, fuite de données]
- #link("https://www.cisa.gov/stopransomware/ransomware-guide")[CISA, Ransomware Guide (ne pas payer, backups offline)]
- #link("https://www.cybermalveillance.gouv.fr")[Cybermalveillance.gouv.fr : réflexes et guides pour les entreprises]
