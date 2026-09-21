// Activité 1 - évaluer ses compétences actuelles comme DevSecOps (partie après-midi).
#import "/template.typ": *

== Activité 1 : Évaluer ses compétences actuelles comme DevSecOps
#text(size: 0.9em, fill: gray)[Partie après-midi]

#encadre("Objectifs")[Mettre au clair les compétences actuelles et les lacunes, pour savoir où progresser. Prendre en compte les formations déjà suivies, les expériences passées, et les connaissances théoriques et pratiques.]

=== Métiers pertinents

DevSecOps.

=== Résultats

Mon expérience du DevSecOps s'est faite exclusivement à travers des pipelines CI/CD GitLab, sans intervention manuelle sur les étapes de vérification. À chaque intégration, des outils d'analyse fournis par les langages concernés vérifient automatiquement l'absence d'erreurs de toute nature (compilation, style, typage). Ces outils remontent également une partie des vulnérabilités de sécurité. Les rapports GitHub, consultés chaque semaine, font office de revue régulière.

Positionnée sur le roadmap DevSecOps de roadmap.sh, cette expérience correspond aux captures ci-dessous : les nœuds barrés marquent les acquis, le reste reste à explorer.

#figure(
  image("assets/devsecops-knowledge-p1.jpg", width: 85%),
  caption: [Auto-positionnement sur le roadmap DevSecOps (roadmap.sh) - partie 1 : acquis barrés.],
)

#figure(
  image("assets/devsecops-knowledge-p2.jpg", width: 85%),
  caption: [Auto-positionnement sur le roadmap DevSecOps (roadmap.sh) - partie 2 : acquis barrés.],
)

=== Interprétation des résultats

La partie 1 montre un socle général acquis : langages et scripting, triade CIA, cryptographie de base, réseau, secure coding, monitoring et identité, conteneurs. La partie 2 inverse le constat : trois blocs restent presque entièrement non acquis. Incident Response (cycle IR, forensics, containment, root cause analysis), Secure Architecture (defense in depth, zoning réseau, IDS/IPS, anti-DDoS, SBOM, durcissement du pipeline, gestion du risque dépendances) et Enterprise Operations (automatisation SOAR, EDR, stratégie de réponse). Seules exceptions côté architecture : Zero Trust, Secure API Design et Supply Chain Security. La crypto de base est acquise, sauf le design et le failover d'une PKI.

Ce découpage recoupe mon auto-évaluation : culture générale solide, lacune sur le cloisonnement et l'opérationnel. Mon expérience CI/CD automatise la détection, mais elle ne couvre ni la réponse à incident ni l'architecture à grande échelle.

Prochaine étape : prioriser ces trois blocs, en commençant par Secure Architecture et Incident Response, puis compléter par du DAST, de l'analyse de dépendances et une revue de conception en amont.
