// Synthèse de la séance - encadrés de clôture.
#import "/template.typ": *

== Synthèse de la séance

=== Résultats

- *Exercice 1 :* auto-évaluation remplie, point faible en confinement OS/réseaux.
- *Exercice 2 :* critères principaux CIA et secondaires rappelés et schématisés.
- *Exercice 3 :* triade CIA notée et comparée sur quatre cas, avec graphique.
- *Exercice 4 :* secteurs public/privé et échelles moi/nous/tous recensés.
- *Activité 1 :* positionnement DevSecOps via CI/CD GitLab et roadmap.
- *Activité 3 :* OSINT et veille collective autorisée, recensement de serveurs WordPress, simulation d'attaque générique et ciblée, recul sur les protections.
- *Activité 4 :* six familles de biais cognitifs, mitigations individuelles et collectives.
- *Travail personnel :* ISO 27001 décortiqué, schéma Direction → Risques → SoA → Mesures.

=== Interprétation des résultats

Trois repères pour le semestre :
- *La triade CIA n'est pas abstraite :* chaque cas (banque 4/4/4, AlertSwiss 1/4/4, streaming, e-commerce) impose sa priorité de conception ; ISO 27001 oblige à tracer ce choix dans la SoA.
- *La sécurité est un système sociotechnique :* biais cognitifs et culture d'équipe font échouer les mesures techniques.
  - Réflexes : hypothèses écrites, relecture croisée, post-mortems sans blâme.
- *Côté pratique :* mon CI/CD couvre surtout des contrôles statiques et les vérifications des langages.
  - Il manque encore : le confinement (2/5), le DAST, l'analyse de dépendances.

Suite :
- *Prochaine étape :* évaluer le projet de semestre avec la grille CIA + SoA + facteur humain.
- *Apport de l'activité 3 :* la veille OSINT autorisée complète la détection, à condition de valider les faux positifs et de tester les protections.
- *Chaîne :* cadrer avec CIA et SoA, intégrer l'humain, puis pratiquer en CI/CD.

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
