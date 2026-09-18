// Import conservé : un fichier #include n'hérite pas des imports de main.typ,
// chaque séance doit donc réimporter les packages qu'elle utilise.
#import "@preview/showybox:2.0.4": showybox
#pagebreak()
= Séance du 18 septembre 2026 : découverte et auto-évaluation

#showybox(
  title: "Objectifs",
  title-style: (color: white, weight: "bold"),
  frame: (border-color: rgb("#E30613"), title-color: rgb("#E30613"), body-color: rgb("#fef2f2")),
)[Première séance : j'évalue mon niveau de départ en sécurité et on revoit ensemble les critères principaux et secondaires.]

== Métiers pertinents
À compléter : quels métiers cette séance éclaire pour moi, et pourquoi ça compte pour la suite.

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
