// Un #include ne partage pas la portée de main.typ : chaque séance réimporte
// donc le template partagé (packages, palette et helpers d'encadré).
#import "/template.typ": *

#pagebreak()
= Séance du 18 septembre 2026 : découverte et auto-évaluation

Énoncés partagés : #link("https://docs.google.com/document/d/1OXlTD6PwEBywkeKl4konbpS4LNzmaa3MotiycR-usLM/edit?usp=sharing")[Exercices partagés (Google Docs)].
Ci-dessous, les exercices personnels réalisés en séance.

#encadre("Objectifs")[Première séance : j'évalue mon niveau de départ en sécurité et on revoit ensemble les critères principaux et secondaires.]

== Métiers pertinents
Cette séance reste volontairement large. Les exercices 1 à 4 ne visent pas un métier précis, ils posent les bases qui servent ensuite à tout le monde : dev, admin sys et réseau, chef de projet, et même simple utilisateur de services en ligne. Pour moi, c'est surtout le regard dev qui est éclairé : comprendre la triade CIA et où la sécurité s'applique avant de parler de standards ou d'audit, ce que je détaille ensuite dans le travail perso sur ISO 27001.

#text(size: 0.9em, fill: gray)[Partie matin : exercices en séance (1 à 4)]

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

Le schéma résume la triade et ses compléments : les trois critères principaux forment le triangle, les critères secondaires l'entourent.
#align(center)[
  #diagram(
    spacing: (14mm, 12mm),
    node-inset: 8pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 1), [*Confidentialité*], fill: fond-rouge),
    node((-1.2, -0.6), [*Intégrité*], fill: fond-rouge),
    node((1.2, -0.6), [*Disponibilité*], fill: fond-rouge),
    node((0, -0.1), text(size: 9pt, fill: gray)[CIA], stroke: none),
    edge((0, 1), (-1.2, -0.6), "-"),
    edge((-1.2, -0.6), (1.2, -0.6), "-"),
    edge((1.2, -0.6), (0, 1), "-"),
    node((0, 2), text(size: 8.5pt, fill: gris)[Secondaires : identification, authentification, sensibilisation, résilience], stroke: none),
    edge((0, 2), (0, 1), "->", bend: 0deg),
  )
]

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

Le graphique rend les écarts visibles d'un coup d'œil : la banque exige tout au maximum, AlertSwiss sacrifie la confidentialité au profit de l'intégrité et de la disponibilité.
#figure(
  caption: [Notes C-I-A par cas (1 à 4). Rouge : C, noir : I, gris : A.],
)[
  #align(center)[
    #lq.diagram(
      width: 13cm,
      height: 5.5cm,
      xlabel: [Cas],
      ylabel: [Note / 4],
      xaxis: (ticks: ((0, [E-commerce]), (1, [Banque]), (2, [AlertSwiss]), (3, [Streaming])), subticks: none),
      yaxis: (ticks: (0, 1, 2, 3, 4), subticks: none),
      lq.bar((0, 1, 2, 3), (3, 4, 1, 2), width: 0.2, offset: -0.22, fill: rouge, label: [C]),
      lq.bar((0, 1, 2, 3), (3, 4, 4, 2), width: 0.2, offset: 0.0, fill: encre, label: [I]),
      lq.bar((0, 1, 2, 3), (3, 4, 4, 4), width: 0.2, offset: 0.22, fill: gris-clair, label: [A]),
    )
  ]
]

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

#text(size: 0.9em, fill: gray)[Partie après-midi : Activités 1 à 7]

== Activité 4 : aspect humain, risques et biais cognitifs

#encadre("Objectifs")[Comprendre les biais cognitifs qui affectent la sécurité : comment les repérer, les limiter, et pourquoi ils changent selon la personne et la culture.]

== Métiers pertinents

RSSI, auditeur, chef de projet, dev : tout le monde est concerné. La sensibilisation n'est pas un bonus : c'est une mesure de réduction du risque.

== Résultats

=== Risques et biais cognitifs liés au cerveau

Le cerveau utilise des raccouris (heuristiques) utiles au quotidien mais dangereux en sécurité. Six types :

#table(
  columns: (1.6fr, 2fr, 2fr),
  [*Type*], [*Description / impact sécurité*], [*Stratégie spécifique*],
  [#link("https://fr.wikipedia.org/wiki/Biais_cognitif")[*Sensori-moteurs*]], [Fatigue visuelle, réflexes erronés sur une interface trompeuse, erreurs de frappe sous stress.], [Design clair, pauses, automatisation des actions critiques.],
  [#link("https://fr.wikipedia.org/wiki/Attention")[*Attentionnels*]], [Surcharge, distraction, cécité au changement : une alerte ignorée dans un flux trop dense.], [Limiter les alertes simultanées, hiérarchiser, automatiser le filtrage.],
  [#link("https://fr.wikipedia.org/wiki/M%C3%A9moire")[*Mnésique*]], [Mémoire sélective, faux souvenirs, oubli des procédures.], [Registres d'incidents, procédures visibles, révision régulière.],
  [#link("https://fr.wikipedia.org/wiki/Biais_de_confirmation")[*De jugement*]], [Confirmation, ancrage, disponibilité, optimisme : on valide une hypothèse et on rejette le contraire.], [Avocat du diable, scénarios indépendants, données chiffrées.],
  [#link("https://fr.wikipedia.org/wiki/Raisonnement")[*De raisonnement*]], [Attribution fondamentale, analogies erronées, logique binaire : on blame la personne au lieu du contexte.], [Post-mortems sans blâme, analyse du contexte avant attribution.],
  [#link("https://fr.wikipedia.org/wiki/Personnalit%C3%A9")[*Liés à la personnalité*]], [Dunning-Kruger, conformisme, aversion au risque, anxiété.], [Évaluation objective, mentorat croisé, diversité des profils.],
)

=== Stratégies générales

- *Red teaming* : simuler l'attaque pour briser la confirmation.
- *Diversité cognitive* : mélanger profils et expériences pour contrer l'ancrage.
- *Hypothèses écrites* : documenter ce qu'on suppose et pourquoi, cela expose l'ancrage.
- *Processus standardisés* : cadres comme l'ISO 27001 réduisent la dépendance à la mémoire individuelle.
- *Psychological safety* : permettre de signaler une erreur sans sanction, cela limite la confirmation et l'attribution fondamentale.

Références : #link("https://fr.wikipedia.org/wiki/Biais_cognitif")[Biais cognitif], #link("https://fr.wikipedia.org/wiki/Heuristique_de_jugement")[Heuristique de jugement].

=== Risques liés à une personne ou à une culture

*Personne particulière :*
- Traits : confiance excessive (Dunning-Kruger), anxiété, faible motivation → biais amplifiés.
- État : fatigue, stress, surcharge → tous les biais s'aggravent.
- Compétences : un expert réseau peut sous-estimer la cryptographie.

*Stratégies individuelles :* évaluation objective (tests, audits), adaptation des tâches, suivi de la charge, mentorat.

*Culture :*
- Culture du silence ou du blâme : on cache les erreurs, on renforce la confirmation.
- Culture hiérarchique : on ose pas contredire un supérieur → ancrage renforcé.
- Biais d'in-group : plus de confiance envers son propre groupe, vigilance réduite face à l'extérieur.
- Perception du risque : prévention collective vs. responsabilité individuelle.

*Stratégies culturelles :* post-mortems sans blâme, formation interculturelle, leadership exemplaire (la direction montre l'exemple), adaptation locale des messages.

Références : #link("https://fr.wikipedia.org/wiki/Biais_de_groupe")[Biais de groupe], #link("https://en.wikipedia.org/wiki/Psychological_safety")[Psychological safety].

== Interprétation des résultats

Le facteur humain explique pourquoi les mesures techniques échouent : un admin sous surcharge ignore une alerte, un utilisateur confiant clique sur un lien. Les risques varient selon la personne et la culture : la sécurité est un système sociotechnique, pas juste des pare-feu.

Prochaine étape : intégrer ces observations dans l'évaluation du projet de semestre (charge cognitive, culture d'équipe, diversité des points de vue).


== Activité 1 : évaluer ses compétences actuelles comme DevSecOps

#encadre("Objectifs")[Mettre au clair les compétences actuelles et les lacunes, pour savoir où progresser. Prendre en compte les formations déjà suivies, les expériences passées, et les connaissances théoriques et pratiques.]

=== Métiers pertinents

DevSecOps.

=== Résultats

A completer

=== Interprétation des résultats

A compléter

== Travail personnel : ISO/IEC 27001

#encadre("Objectifs")[Prendre un seul standard, ISO/IEC 27001, et comprendre comment il fonctionne vraiment : à qui il s'applique, ce qu'il impose concrètement, comment on prouve qu'on le respecte, et en quoi il se distingue d'un guide technique. Explication détaillée dans le #link("https://docs.google.com/document/d/1fH8UCfGyz7B1bx2RM74GsLj1NJDceglvkOgh9siI0cQ/edit?usp=sharing")[document de groupe (Google Docs)], lien aussi reporté dans le tableau du cours.]

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

#encadre("Résultats")[Tableau d'auto-évaluation rempli (exercice 1), critères principaux et secondaires rappelés en séance (exercice 2), triade CIA évaluée sur quatre cas concrets (exercice 3), secteurs et objets d'application recensés (exercice 4).]

#encadre("Interprétation des résultats")[Cette première séance (matin : triade CIA et application concrète + après-midi : cadre ISO 27001) me donne deux repères clairs pour la suite du semestre. La triade C/I/A n'est pas abstraite : chaque secteur (banque, alerte publique, streaming, e-commerce) a un profil propre, et l'ISO 27001 oblige à écrire ses choix dans une SoA. L'après-midi confirme que la sécurité n'est pas un ensemble de pare-feu mais un processus (PDCA, clauses 4-10) que la direction doit porter. Prochaine étape : utiliser cette grille pour évaluer le projet de semestre.]
