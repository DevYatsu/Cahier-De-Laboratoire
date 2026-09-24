// Exercice 1 - auto-évaluation initiale (partie matin).
#import "/template.typ": *

== Exercice 1 : Auto-évaluation initiale

#encadre("Objectifs")[Poser une base chiffrée de mon niveau initial en sécurité. Je note chaque thème de 1 à 5 pour repérer mes forces et mes lacunes avant le semestre.]

=== Métiers pertinents

Cette auto-évaluation sert de point de départ à tout le monde. Elle concerne autant le dev que l'admin sys/réseau ou le chef de projet : chacun doit savoir où il part avant de parler sécurité.

=== Déroulement

L'énoncé demande de noter de 1 à 5 mon niveau sur chaque thème. Je recopie le tableau et je le remplis pendant la séance.

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

Une phrase suffit par question.

- Sur quel(s) thème(s) je me sens le plus à l'aise, et pourquoi ?
  Je suis le plus à l'aise sur le facteur humain (5/5). Je suis beaucoup d'histoires de hacking et ce constat revient sans arrêt : le phishing et l'ingénierie sociale restent la faille la plus simple à exploiter, bien avant la technique pure.
- Sur quel(s) thème(s) j'aimerais progresser en priorité ?
  Je veux progresser en priorité sur le confinement OS et réseaux (2/5). Je connais mal le sandboxing et la segmentation alors que le sujet m'intéresse, donc c'est là que la marge est la plus grande.
- Ai-je déjà conscience que sécuriser une entreprise n'est pas la même chose que sécuriser un développement logiciel ? Si non, pourquoi cette distinction me semble-t-elle floue ?
  Oui, la distinction est claire pour moi. Sécuriser une entreprise intègre beaucoup plus de variables humaines, donc beaucoup plus de points d'attaque et de points de défense que sécuriser un seul logiciel.
  La sécurisation d'une entreprise tient aussi compte des contraintes de gestion, comme les ressources, les budgets, les activités et la politique de l'entreprise. Pour mon projet, je peux donc analyser les menaces et appliquer la sécurité à chaque étape du cycle de vie, avec un confinement adapté aux risques et aux impacts.

=== Résultats

Mon profil est déséquilibré entre culture et technique. Je suis solide sur le facteur humain (5), et correct sur les enjeux généraux, la crypto, la conscience dev et la veille (4). Le reste plafonne à 3 : théorie, pratique, réflexes de dev sécurisé et gestion des risques. Le confinement OS et réseaux tombe à 2, mon seul vrai trou. En bref : je sais pourquoi on se fait attaquer, je sais moins comment cloisonner proprement.

=== Interprétation des résultats

Ce tableau me donne une direction pour le semestre. Mon point d'appui, c'est la sensibilisation : je pars avec le réflexe de me méfier du maillon humain. Mon chantier, c'est le confinement : sandboxing, segmentation, moindre privilège. Pour le projet de semestre, cela veut dire viser la confidentialité et l'intégrité par la technique, pas seulement par la vigilance, et mesurer le progrès en refaisant cette grille en fin de module.
