// Activité 1 — évaluer ses compétences actuelles comme DevSecOps (partie après-midi).
#import "/template.typ": *

== Évaluer ses compétences actuelles comme DevSecOps
#text(size: 0.9em, fill: gray)[Partie après-midi · activité 1]

#encadre("Objectifs")[Mettre au clair les compétences actuelles et les lacunes, pour savoir où progresser. Prendre en compte les formations déjà suivies, les expériences passées, et les connaissances théoriques et pratiques.]

=== Métiers pertinents

DevSecOps.

=== Résultats

Mon expérience du DevSecOps s'est faite exclusivement à travers des pipelines CI/CD GitLab, sans intervention manuelle sur les étapes de vérification. À chaque intégration, des outils d'analyse fournis par les langages concernés vérifient automatiquement l'absence d'erreurs de toute nature (compilation, style, typage). Ces outils remontent également une partie des vulnérabilités de sécurité. Les rapports GitHub, consultés chaque semaine, font office de revue régulière.

Positionnée sur le roadmap DevSecOps de roadmap.sh, cette expérience correspond aux captures ci-dessous : les nœuds cochés marquent les acquis, le reste reste à explorer.

#figure(
  image("assets/devsecops-knowledge-p1.jpg", width: 85%),
  caption: [Auto-positionnement sur le roadmap DevSecOps (roadmap.sh) — partie 1 : acquis cochés.],
)

#figure(
  image("assets/devsecops-knowledge-p2.jpg", width: 85%),
  caption: [Auto-positionnement sur le roadmap DevSecOps (roadmap.sh) — partie 2 : acquis cochés.],
)

=== Interprétation des résultats

Mon point fort est l'automatisation : détection systématique et reproductible des erreurs, sans dépendre d'une vérification manuelle. Ma lacune est la couverture : ces outils ne traitent que ce que le langage et les analyseurs statiques savent voir, et la sécurité n'est remontée que partiellement. Il me manque la partie dynamique et intentionnelle de la sécurité.

Prochaine étape : compléter par des tests dynamiques (DAST), de l'analyse de dépendances et une revue de conception menée en amont, plutôt que de me limiter à la détection automatique après écriture du code.
