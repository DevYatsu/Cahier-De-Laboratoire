// Exercice 1 - auto-évaluation initiale (partie matin).
#import "/template.typ": *

== Exercice 1 : Auto-évaluation initiale

#encadre("Objectifs")[
  - Poser une base chiffrée de mon niveau initial en sécurité.
  - Noter chaque thème de 1 à 5.
  - Repérer mes forces et mes lacunes avant le semestre.
]

=== Métiers pertinents

- *Tous les métiers :* point de départ commun avant de parler sécurité.
- *Exemples :* développeur, admin systèmes/réseau, chef de projet.

=== Déroulement

- Noter de 1 à 5 mon niveau sur chaque thème.
- Recopier le tableau, puis le remplir pendant la séance.

#table(
  columns: (1fr, auto),
  align: (left, center),
  [*Thème*], [*1 à 5*],
  [Compréhension générale des enjeux de la sécurité (pourquoi c'est important, quels types de menaces existent, comment les traiter)], [4],
  [Compréhension des thèmes déjà vus - niveau théorique], [3],
  [Mise en pratique de ces thèmes - niveau appliqué], [3],
  [Conscience de la sécurité quand je conçois / développe / maintiens un projet (y compris contributions open source éventuelles)], [4],
  [Réflexes de développement sécurisé concret], [3],
  [Gestion des risques (avoir déjà dû, même informellement, déterminer les menaces puis évaluer les risques / impacts d'un choix, par exemple technique)], [3],
  [Outils cryptographiques (compréhension et usage régulier)], [4],
  [Confinement OS et réseaux (sandboxing, segmentation réseau, etc.)], [2],
  [Conscience des risques liés au facteur humain (ingénierie sociale, phishing)], [5],
  [Suivi de sources d'information sécurité (blogs, mailing-lists, CVE, etc.) de logiciels spécifiques, de plateformes spécifiques, ou générales], [4],
  [Envie d'appliquer ce que je vais apprendre en 3275.1 et 3275.2 (semestre d'automne) dans mon projet de semestre], [4],
)

==== Questions de synthèse

- *Thème le plus à l'aise :* facteur humain (5/5).
  - Je suis beaucoup d'histoires de hacking.
  - Constat récurrent : phishing et ingénierie sociale restent la faille la plus simple, bien avant la technique pure.
- *Thème à progresser en priorité :* confinement OS et réseaux (2/5).
  - Je connais mal le sandboxing et la segmentation, alors que le sujet m'intéresse.
  - C'est là que la marge de progrès est la plus grande.
- *Entreprise vs développement logiciel :* la distinction est claire pour moi.
  - L'entreprise intègre plus de variables humaines, donc plus de points d'attaque et de défense.
  - Elle tient aussi compte des contraintes de gestion : ressources, budgets, activités, politique interne.
  - Pour mon projet : analyser les menaces et appliquer la sécurité à chaque étape du cycle de vie, avec un confinement adapté aux risques et impacts.

=== Résultats

Profil déséquilibré entre culture et technique :
- *5 :* facteur humain.
- *4 :* enjeux généraux, cryptographie, conscience dev, veille, envie d'appliquer.
- *3 :* théorie, pratique, réflexes de dev sécurisé, gestion des risques.
- *2 :* confinement OS et réseaux, mon seul vrai trou.
- *En bref :* je sais pourquoi on se fait attaquer, je sais moins comment cloisonner proprement.

=== Interprétation des résultats

- *Point d'appui :* la sensibilisation, avec le réflexe de me méfier du maillon humain.
- *Chantier :* le confinement (sandboxing, segmentation, moindre privilège).
- *Projet de semestre :* viser la confidentialité et l'intégrité par la technique, pas seulement par la vigilance.
- *Mesure du progrès :* refaire cette grille en fin de module.
