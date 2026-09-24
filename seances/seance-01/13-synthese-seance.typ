// Synthèse de la séance - encadrés de clôture.
#import "/template.typ": *

== Synthèse de la séance

=== Résultats

Tableau d'auto-évaluation rempli avec point faible en confinement OS/réseaux (exercice 1), critères principaux CIA et secondaires rappelés et schématisés (exercice 2), triade CIA notée et comparée sur quatre cas avec graphique (exercice 3), secteurs public/privé et échelles moi/nous/tous recensés (exercice 4), positionnement DevSecOps via CI/CD GitLab et roadmap (activité 1), six familles de biais cognitifs mappées avec mitigations individuelles et collectives (activité 4), fonctionnement d'ISO 27001 décortiqué avec schéma Direction → Risques → SoA → Mesures (travail personnel). Activité 3 : OSINT et veille collective autorisée, recensement de serveurs WordPress, simulation d’attaque générique et ciblée, puis recul sur les protections.

=== Interprétation des résultats

Cette première séance me donne trois repères pour le semestre. La triade C/I/A n'est pas abstraite : chaque cas (banque 4/4/4, AlertSwiss 1/4/4, streaming, e-commerce) impose une priorité de conception propre, et ISO 27001 oblige à tracer ce choix dans la SoA. La sécurité est un système sociotechnique : les biais cognitifs et la culture d'équipe font échouer les mesures techniques, d'où les réflexes hypothèses écrites, relecture croisée et post-mortems sans blâme. Côté pratique, mon automatisation CI/CD couvre surtout des contrôles statiques et des vérifications fournies par les langages ; il me manque encore le confinement (2/5), le DAST et l'analyse de dépendances. Prochaine étape : utiliser cette grille CIA + SoA + facteur humain pour évaluer le projet de semestre ; l'activité 3 confirme que la veille OSINT autorisée complète la détection, à condition de valider les faux positifs et de tester les protections.

Les trois repères tiennent en une chaîne : cadrer avec CIA et SoA, intégrer l'humain, puis pratiquer en CI/CD.
#align(center)[
  #diagram(
    spacing: (6mm, 8mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*CIA + SoA*], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Facteur humain*], fill: white),
    edge("->"),
    node((2, 0), align(center)[*Pratique CI/CD*], fill: fond-rouge),
  )
]
