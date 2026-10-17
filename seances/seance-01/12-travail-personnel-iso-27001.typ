// Travail personnel - ISO 27001.
#import "/template.typ": *

== Travail personnel : ISO 27001

#encadre("Objectifs")[
  - Prendre un seul standard, ISO 27001, et comprendre comment il fonctionne vraiment.
  - À qui il s'applique, ce qu'il impose concrètement, comment prouver qu'on le respecte.
  - En quoi il se distingue d'un guide technique.
  - Explication détaillée dans le #link("https://docs.google.com/document/d/1fH8UCfGyz7B1bx2RM74GsLj1NJDceglvkOgh9siI0cQ/edit?usp=sharing")[document de groupe (Google Docs)], lien aussi reporté dans le tableau du cours.
]

=== Métiers pertinents

Ce standard ne parle pas qu'aux techniciens :
- *RSSI, responsable sécurité :* portent le SMSI (système de management de la sécurité de l'information), rendent compte à la direction.
- *Risk manager, analyste risques :* l'analyse de risque est leur point de départ.
- *Auditeur interne, auditeur de certification :* vérifient la conformité sur preuves.
- *Admin systèmes et réseau, développeurs, DPO :* appliquent les mesures de l'annexe A, chacun sur sa partie.
- *Direction :* sans son engagement écrit, la certification ne passe pas.

=== Résultats

*Portée générale, périmètre choisi.* La norme s'adresse à toute organisation (entreprise, administration, ONG, petite ou grande), et rien ne la limite à l'informatique. Chaque organisation choisit son périmètre de SMSI : toute l'entreprise, un site, un département, un produit. Tout le reste ne s'applique qu'à l'intérieur de ce périmètre déclaré.

*Quatre familles de mesures.* L'annexe A (version 2022) liste 93 mesures, réparties ainsi :
- *Organisation :* politiques, rôles, classification de l'information, gestion des incidents.
- *Personnes :* recrutement, sensibilisation, processus de départ.
- *Physique :* accès aux locaux, protection du matériel.
- *Technique :* contrôle d'accès logique, cryptographie, sécurité réseau, développement sécurisé, correctifs.

La sécurité ne se joue donc pas que dans les pare-feu.

*Gestion du risque top-down.* La direction pose les enjeux, on identifie ensuite actifs et risques sur C, I, A, et on choisit les mesures seulement après. Rien n'est obligatoire par défaut, d'où la Déclaration d'applicabilité (SoA) : on justifie, mesure par mesure, ce qu'on applique, ce qu'on écarte, et pourquoi. L'ordre est imposé : pas de mesures avant les risques, pas de risques hors périmètre, et la SoA comme trace écrite du choix.

#align(center)[
  #diagram(
    spacing: (10mm, 8mm),
    node-inset: 7pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Direction*\ Enjeux], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Risques*\ Actifs + C/I/A], fill: white),
    edge("->"),
    node((2, 0), align(center)[*SoA*\ Applique / écarte], fill: white),
    edge("->"),
    node((3, 0), align(center)[*Mesures*\ Annexe A + PDCA], fill: fond-rouge, stroke: encre),
  )
]

*Obligations de management plus que détails techniques.* Les clauses 4 à 10 décrivent le système : périmètre, rôles, planification, non-conformités, revue de direction. La norme dit quel processus mettre en place, pas quel outil acheter ni quel chiffrement utiliser.

*Pensée pour la certification.* Un tiers (Bureau Veritas, BSI, SQS) audite l'organisation et délivre un certificat de trois ans, avec un audit de suivi chaque année. Entre-temps, les audits internes et la roue PDCA (Plan, Do, Check, Act) entretiennent le système. Le certificat a un double usage : preuve de confiance pour les clients, boucle d'amélioration en interne.

*Un coût réel.* Il n'existe pas de chiffre unique, tout dépend du périmètre. Il faut payer l'audit externe et souvent un accompagnement, mais le coût principal est le temps interne : documentation, analyse de risques, formation. S'y ajoutent parfois des mises à niveau techniques non prévues.

*Prévention et réaction.* La norme couvre les deux versants : la prévention (analyse de risques, politiques, durcissement, sensibilisation), puis la détection et la réaction (journaux, surveillance, détection d'anomalies, réponse aux incidents testée et suivie).

*Pas de niveau numéroté.* Contrairement à CMMI, il n'y a pas de note de 1 à 5. La maturité se voit dans la durée : indicateurs suivis, revues régulières, actions correctives (clause 10) qui aboutissent.

Références : #link("https://docs.google.com/document/d/1fH8UCfGyz7B1bx2RM74GsLj1NJDceglvkOgh9siI0cQ/edit?usp=sharing")[document de groupe], #link("https://fr.wikipedia.org/w/index.php?title=ISO/CEI_27001")[ISO/CEI 27001, Wikipedia FR], #link("https://www.iso.org/standard/27001")[page officielle ISO].

=== Interprétation des résultats

La norme est lourde sur le papier, mais je comprends son succès : elle adapte l'effort aux vrais risques, tout en obligeant à écrire ce choix dans la SoA. On ne peut pas dire "on fait de la sécurité" sans le montrer.

Elle colle au rôle de RSSI et d'auditeur. Pour un admin ou un dev, elle fournit un cadre, pas une recette ; les consignes précises se trouvent dans ISO 27002, qui détaille les mesures. Elle applique le PDCA à la sécurité : planifier avec les risques, déployer, contrôler (audits, logs), corriger (clause 10). Ce n'est donc pas un contrôle ponctuel avant un audit client.

Conformité n'est pas sécurité réelle : le certificat prouve qu'un système existe et qu'il est suivi, pas l'absence d'incident. Enfin, vu le coût en temps et en documentation, la direction doit le vouloir, sinon cela reste un classeur vide.
