// Travail personnel - ISO 27001.
#import "/template.typ": *

== Travail personnel : ISO 27001
#text(size: 0.9em, fill: gray)[Travail personnel]

#encadre("Objectifs")[Prendre un seul standard, ISO 27001, et comprendre comment il fonctionne vraiment : à qui il s'applique, ce qu'il impose concrètement, comment on prouve qu'on le respecte, et en quoi il se distingue d'un guide technique. Explication détaillée dans le #link("https://docs.google.com/document/d/1fH8UCfGyz7B1bx2RM74GsLj1NJDceglvkOgh9siI0cQ/edit?usp=sharing")[document de groupe (Google Docs)], lien aussi reporté dans le tableau du cours.]

=== Métiers pertinents
Ce standard ne parle pas qu'aux techniciens. Quatre métiers sont directement concernés : RSSI et responsable sécurité, qui portent le SMSI et rendent compte à la direction ; risk manager et analyste risques, pour qui l'analyse de risque est le point de départ ; auditeur interne et auditeur de certification, qui vérifient la conformité sur preuves ; administrateurs systèmes et réseau, développeurs et DPO, qui appliquent les mesures de l'annexe A chacun sur leur partie. Sans l'engagement écrit de la direction, la certification ne passe pas.

=== Résultats
Portée générale, périmètre choisi. La 27001 s'adresse à toute organisation, entreprise privée, administration, ONG, petite ou grande. Rien ne la limite à l'informatique. Par contre, chaque organisation choisit son périmètre de SMSI : toute la boite, ou seulement un site, un département, un produit. Tout le reste ne s'applique qu'à l'intérieur de ce périmètre déclaré.

Quatre familles de mesures. L'annexe A version 2022 liste 93 mesures en quatre thèmes. Coté organisation : politiques, rôles, classification de l'information, gestion des incidents. Coté personnes : recrutement, sensibilisation, processus de départ. Coté physique : accès aux locaux, protection du matériel. Coté technique : contrôle d'accès logique, cryptographie, sécurité réseau, développement sécurisé, correctifs. Cette découpe rappelle que la sécurité ne se joue pas que dans les pare-feu.

Gestion du risque qui part du haut. La démarche est top-down. La direction pose les enjeux, puis on identifie actifs et risques sur confidentialité, intégrité et disponibilité. On ne choisit les mesures qu'après. Rien n'est obligatoire par défaut. D'où la Déclaration d'applicabilité (SoA) : un tableau où on justifie, mesure par mesure, ce qu'on applique, ce qu'on écarte, et pourquoi.

Le flux résume l'ordre imposé : pas de mesures avant les risques, pas de risques hors périmètre, et la SoA comme trace écrite du choix.
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

Obligations de management plus que détails techniques. Les clauses 4 à 10 décrivent le système lui-même : définir le périmètre, attribuer les rôles, planifier, traiter les non-conformités, revoir en revue de direction. La norme dit quel processus mettre en place, pas quel outil acheter ni quel chiffrement utiliser.

Pensée pour la certification. La 27001 est faite pour être auditée par un tiers comme Bureau Veritas, BSI ou SQS. Certificat de trois ans, avec audit de suivi chaque année. En interne, elle impose ses propres audits et suit la roue PDCA, Plan Do Check Act. Double usage : preuve de confiance pour les clients, boucle d'amélioration en interne.

Un coût réel. Pas de chiffre unique, tout dépend du périmètre. Il faut payer l'audit externe, souvent un accompagnement, et surtout libérer du temps en interne pour la documentation, l'analyse de risques et la formation. Parfois s'ajoutent des mises à niveau techniques non prévues.

Prévention et réaction. Elle couvre les deux. Coté prévention : analyse de risques, politiques, durcissement, sensibilisation. Coté détection et réaction : journaux, surveillance, détection d'anomalies, procédure de réponse aux incidents testée et suivie.

Pas de niveau numéroté. Contrairement à CMMI, pas de note de 1 à 5. La maturité se voit dans la durée : indicateurs suivis, revues régulières, actions correctives de la clause 10 qui aboutissent vraiment.

Références : #link("https://docs.google.com/document/d/1fH8UCfGyz7B1bx2RM74GsLj1NJDceglvkOgh9siI0cQ/edit?usp=sharing")[document de groupe], #link("https://fr.wikipedia.org/w/index.php?title=ISO/CEI_27001")[ISO/CEI 27001, Wikipedia FR], #link("https://www.iso.org/standard/27001")[page officielle ISO].

=== Interprétation des résultats
Sur le papier, la 27001 semble lourde et administrative. En pratique, je comprends son succès : elle laisse adapter l'effort aux vrais risques, mais oblige à écrire ce choix dans la SoA. On ne peut pas dire "on fait de la sécurité" sans le montrer.

Elle colle au rôle de RSSI et d'auditeur. Pour un admin ou un dev, elle donne un cadre, pas une recette. S'il faut des consignes précises, il faut aller voir ISO 27002 pour le détail des mesures.

Elle couvre tout le tour de roue : on planifie avec les risques, on déploie, on contrôle avec audits et logs, on corrige avec la clause 10. C'est du PDCA appliqué à la sécurité, pas un contrôle ponctuel avant un audit client.

Ce travail m'a aidé à séparer conformité et sécurité réelle. Le certificat prouve qu'un système existe et qu'il est suivi. Il ne prouve pas l'absence d'incident. Vu le coût en temps et en documentation, on ne lance pas une 27001 pour voir : il faut que la direction le veuille, sinon cela reste un classeur vide.
