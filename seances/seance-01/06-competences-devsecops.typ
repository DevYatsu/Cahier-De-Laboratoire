// Activité 1 - évaluer ses compétences actuelles comme DevSecOps (partie après-midi).
#import "/template.typ": *

== Activité 1 : Évaluer ses compétences actuelles comme DevSecOps

#encadre("Objectifs")[
  - Mettre au clair mes compétences actuelles et mes lacunes, pour savoir où progresser.
  - Prendre en compte formations suivies, expériences passées, connaissances théoriques et pratiques.
]

=== Métiers pertinents

DevSecOps.

=== Résultats

Mon expérience passe exclusivement par des pipelines CI/CD GitLab, sans intervention manuelle sur les vérifications. À chaque intégration, les outils d'analyse des langages vérifient compilation, style et typage, et remontent aussi une partie des vulnérabilités de sécurité. Je consulte en complément les rapports GitHub chaque semaine.

Je me suis positionné sur la roadmap DevSecOps de roadmap.sh (captures ci-dessous) : les nœuds barrés sont acquis, le reste est à explorer.

#figure(
  image("assets/devsecops-knowledge-p1.jpg", width: 85%),
  caption: [Auto-positionnement sur le roadmap DevSecOps (roadmap.sh) - partie 1 : acquis barrés.],
)

#figure(
  image("assets/devsecops-knowledge-p2.jpg", width: 85%),
  caption: [Auto-positionnement sur le roadmap DevSecOps (roadmap.sh) - partie 2 : acquis barrés.],
)

=== Interprétation des résultats

- *Partie 1, socle acquis :* langages et scripting, triade CIA, cryptographie de base, réseau, secure coding, monitoring et identité, conteneurs.
  - Exception crypto : design et failover d'une PKI non acquis.
- *Partie 2, trois blocs presque entièrement non acquis :*
  - *Incident Response :* cycle IR, forensics, containment, root cause analysis.
  - *Secure Architecture :* defense in depth, zoning réseau, IDS/IPS, anti-DDoS, SBOM, durcissement du pipeline, risque des dépendances.
    - Exceptions acquises : Zero Trust, Secure API Design, Supply Chain Security.
  - *Enterprise Operations :* automatisation SOAR, EDR, stratégie de réponse.

Ce bilan recoupe mon auto-évaluation : une culture générale solide, une lacune sur le cloisonnement et l'opérationnel. Mon expérience CI/CD automatise la détection, mais ne couvre ni la réponse à incident ni l'architecture à grande échelle. La feuille de route en découle : socle acquis, deux blocs à construire, exploitation à viser.

#align(center)[
  #diagram(
    spacing: (6mm, 8mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Socle acquis*], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Incident Response*], fill: white),
    edge("->"),
    node((2, 0), align(center)[*Secure Architecture*], fill: white),
    edge("->"),
    node((3, 0), align(center)[*Enterprise Ops*], fill: fond-rouge),
  )
]

Prochaine étape : prioriser Secure Architecture et Incident Response, puis compléter par du DAST, de l'analyse de dépendances et une revue de conception en amont.
