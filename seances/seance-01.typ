// Import conservé : un fichier #include n'hérite pas des imports de main.typ,
// chaque séance doit donc réimporter les packages qu'elle utilise.
#import "@preview/showybox:2.0.4": showybox
#pagebreak()
= Séance du 18 septembre 2026 : découverte et auto-évaluation

Énoncés partagés : #link("https://docs.google.com/document/d/1OXlTD6PwEBywkeKl4konbpS4LNzmaa3MotiycR-usLM/edit?usp=sharing")[Exercices partagés (Google Docs)].
Ci-dessous, les exercices personnels réalisés en séance.

#showybox(
  title: "Objectifs",
  title-style: (color: white, weight: "bold"),
  frame: (border-color: rgb("#E30613"), title-color: rgb("#E30613"), body-color: rgb("#fef2f2")),
)[Première séance : j'évalue mon niveau de départ en sécurité et on revoit ensemble les critères principaux et secondaires.]

== Métiers pertinents
Cette séance reste volontairement large. Les exercices 1 à 4 ne visent pas un métier précis, ils posent les bases qui servent ensuite à tout le monde : dev, admin sys et réseau, chef de projet, et même simple utilisateur de services en ligne. Pour moi, c'est surtout le regard dev qui est éclairé : comprendre la triade CIA et où la sécurité s'applique avant de parler de standards ou d'audit, ce que je détaille ensuite dans le travail perso sur ISO 27001.

== Exercice 1 : auto-évaluation initiale
L'énoncé demande de noter de 1 à 5 mon niveau sur chaque thème. Je recopie le tableau et je le remplis pendant la séance.

#table(
  columns: (1fr, auto),
  align: (left, center),
  [*Thème*], [*1 à 5*],
  [Compréhension générale des enjeux de la sécurité (pourquoi c'est important, quels types de menaces existent, comment les traiter)], [4],
  [Compréhension des thèmes déjà vus — niveau théorique], [3],
  [Mise en pratique de ces thèmes — niveau appliqué], [3],
  [Conscience de la sécurité quand je conçois / développe / maintiens un projet (y compris contributions open source éventuelles)], [4],
  [Réflexes de développement sécurisé concret], [3],
  [Gestion des risques (avoir déjà dû, même informellement, déterminer les menaces puis évaluer les risques / impacts d'un choix, par exemple technique)], [3],
  [Outils cryptographiques (compréhension et usage régulier)], [4],
  [Confinement OS et réseaux (sandboxing, segmentation réseau, etc.)], [2],
  [Conscience des risques liés au facteur humain (ingénierie sociale, phishing)], [5],
  [Suivi de sources d'information sécurité (blogs, mailing-lists, CVE, etc.) de logiciels spécifiques, de plateformes spécifiques, ou générales], [4],
  [Envie d'appliquer ce que je vais apprendre en 3275.1 et 3275.2 (semestre d'automne) dans mon projet de semestre], [4],
)

=== Questions de synthèse
Une phrase suffit par question.

- Sur quel(s) thème(s) je me sens le plus à l'aise, et pourquoi ?
  "À compléter."
- Sur quel(s) thème(s) j'aimerais progresser en priorité ?
  "À compléter."
- Ai-je déjà conscience que sécuriser une entreprise n'est pas la même chose que sécuriser un développement logiciel ? Si non, pourquoi cette distinction me semble-t-elle floue ?
  "À compléter."

== Exercice 2 : critères principaux et secondaires
On a rappelé les critères en cours. Je les note en vrac, sans chercher à tout reformuler.

*Critères principaux :*
- Confidentialité
- Intégrité
- Disponibilité

*Critères secondaires :*
- Identification :
  - Responsable / traçabilité → non-répudiation / imputabilité
  - Accès
- Authentification
- Sensibilisation
- Résilience

== Exercice 3 : évaluer la triade CIA sur des cas concrets
On note de 1 à 4 (maximum) la confidentialité, l'intégrité et la disponibilité pour chaque cas. Je recopie le tableau et je le remplis.

#table(
  columns: (1fr, auto, auto, auto),
  [*Cas*], [*C*], [*I*], [*A*],
  [Site d'e-commerce], [3], [3], [3],
  [Banque en ligne suisse], [4], [4], [4],
  [Diffusion message AlertSwiss], [1], [4], [4],
  [Service de streaming vidéo], [2], [2], [4],
)

Pourquoi ces notes, en bref :
- *E-commerce (3/3/3) :* une commande modifiée ou une minute d'indisponibilité coûte directement de l'argent, donc I et A élevés ; C à 3 car données clients et paiement, sans atteindre le niveau d'une banque.
- *Banque en ligne (4/4/4) :* le secret bancaire et l'exactitude des soldes priment (C et I au maximum), et l'accès au service doit être continu (A au maximum).
- *AlertSwiss (1/4/4) :* messages publics (C à 1), mais une fausse alerte peut provoquer une panique (I à 4) et le message doit passer en pleine crise (A à 4).
- *Streaming (2/2/4) :* catalogue public et image corrompue peu coûteuse (C et I à 2), par contre un service qui rame fait fuir les abonnés (A à 4).

== Exercice 4 : principaux secteurs, domaines et objets d'application
La question porte sur où la sécurité s'applique et sur qui elle concerne. Je distingue le secteur public, le secteur privé, puis les domaines transverses.

*Secteur public :*
- Défense et sécurité nationale : armée, renseignement, police, protection civile.
- Santé publique : hôpitaux, services d'urgence, dossiers patients.
- Administrations et collectivités : état civil, fiscalité, vote, services en ligne.
- Éducation et recherche : universités, laboratoires, données scientifiques.
- Infrastructures critiques : énergie, eau, transports, télécommunications.
- Justice : tribunaux, casiers, preuves numériques.

*Secteur privé :*
- Entreprises : PME et grands groupes, secrets industriels, SI interne, postes de travail.
- Objets protégés : contrats, comptabilité, propriété intellectuelle, continuité d'activité.

*Domaines transverses, au global :*
- Santé et pharmaceutique : dispositifs médicaux, essais cliniques, brevets, chaînes de production.
- Informatique et technologique : cloud, logiciels, matériel, opérateurs télécoms, prestataires.
- Finance et assurance : banques, paiements, données clients.
- Industrie et énergie : OT (technologies opérationnelles), SCADA, chaînes logistiques.

*Qui est concerné ?*
- Moi : mes comptes, mes appareils, mes projets de développement.
- Nous : l'entreprise ou l'équipe où je travaille, ses clients et ses fournisseurs.
- Tout le monde : chaque citoyen utilise des services dont la compromission a un impact collectif.

== Travail personnel : ISO/IEC 27001

#showybox(
  title: "Objectifs",
  title-style: (color: white, weight: "bold"),
  frame: (border-color: rgb("#E30613"), title-color: rgb("#E30613"), body-color: rgb("#fef2f2")),
)[Prendre un seul standard, ISO/IEC 27001, et comprendre comment il fonctionne vraiment : à qui il s'applique, ce qu'il impose concrètement, comment on prouve qu'on le respecte, et en quoi il se distingue d'un guide technique. Explication détaillée dans le #link("https://docs.google.com/document/d/1fH8UCfGyz7B1bx2RM74GsLj1NJDceglvkOgh9siI0cQ/edit?usp=sharing")[document de groupe (Google Docs)], lien aussi reporté dans le tableau du cours.]

=== Métiers pertinents
Ce standard ne parle pas qu'aux techniciens. Quatre métiers sont directement concernés : RSSI et responsable sécurité, qui portent le SMSI et rendent compte à la direction ; risk manager et analyste risques, pour qui l'analyse de risque est le point de départ ; auditeur interne et auditeur de certification, qui vérifient la conformité sur preuves ; administrateurs systèmes et réseau, développeurs et DPO, qui appliquent les mesures de l'annexe A chacun sur leur partie. Sans l'engagement écrit de la direction, la certification ne passe pas.

=== Résultats
Portée générale, périmètre choisi. La 27001 s'adresse à toute organisation, entreprise privée, administration, ONG, petite ou grande. Rien ne la limite à l'informatique. Par contre, chaque organisation choisit son périmètre de SMSI : toute la boite, ou seulement un site, un département, un produit. Tout le reste ne s'applique qu'à l'intérieur de ce périmètre déclaré.

Quatre familles de mesures. L'annexe A version 2022 liste 93 mesures en quatre thèmes. Coté organisation : politiques, rôles, classification de l'information, gestion des incidents. Coté personnes : recrutement, sensibilisation, processus de départ. Coté physique : accès aux locaux, protection du matériel. Coté technique : contrôle d'accès logique, cryptographie, sécurité réseau, développement sécurisé, correctifs. Cette découpe rappelle que la sécurité ne se joue pas que dans les pare-feu.

Gestion du risque qui part du haut. La démarche est top-down. La direction pose les enjeux, puis on identifie actifs et risques sur confidentialité, intégrité et disponibilité. On ne choisit les mesures qu'après. Rien n'est obligatoire par défaut. D'où la Déclaration d'applicabilité (SoA) : un tableau où on justifie, mesure par mesure, ce qu'on applique, ce qu'on écarte, et pourquoi.

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

#showybox(
  title: "Résultats",
  title-style: (color: white, weight: "bold"),
  frame: (border-color: rgb("#111111"), title-color: rgb("#111111"), body-color: rgb("#f5f5f5")),
)[Tableau d'auto-évaluation rempli (exercice 1), critères principaux et secondaires rappelés en séance (exercice 2), triade CIA évaluée sur quatre cas concrets (exercice 3), secteurs et objets d'application recensés (exercice 4).]

#showybox(
  title: "Interprétation des résultats",
  title-style: (color: white, weight: "bold"),
  frame: (border-color: rgb("#6b6b6b"), title-color: rgb("#6b6b6b"), body-color: white),
)[À compléter : ce que je retiens de cette première séance pour la suite du semestre.]
