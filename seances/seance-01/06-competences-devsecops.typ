// Activité 1 — évaluer ses compétences actuelles comme DevSecOps (partie après-midi).
#import "/template.typ": *

== Activité 1 : évaluer ses compétences actuelles comme DevSecOps

#encadre("Objectifs")[Mettre au clair les compétences actuelles et les lacunes, pour savoir où progresser. Prendre en compte les formations déjà suivies, les expériences passées, et les connaissances théoriques et pratiques.]

=== Métiers pertinents

DevSecOps. Voir le complément de slides dans la sous-partie « Complément : slides DevSecOps ».

=== Résultats

Mon expérience du DevSecOps s'est faite exclusivement à travers des pipelines CI/CD GitLab, sans intervention manuelle sur les étapes de vérification. À chaque intégration, des outils d'analyse fournis par les langages concernés vérifient automatiquement l'absence d'erreurs de toute nature (compilation, style, typage). Ces outils remontent également une partie des vulnérabilités de sécurité. Les rapports GitHub, consultés chaque semaine, font office de revue régulière.

=== Interprétation des résultats

Mon point fort est l'automatisation : détection systématique et reproductible des erreurs, sans dépendre d'une vérification manuelle. Ma lacune est la couverture : ces outils ne traitent que ce que le langage et les analyseurs statiques savent voir, et la sécurité n'est remontée que partiellement. Il me manque la partie dynamique et intentionnelle de la sécurité.

Prochaine étape : compléter par des tests dynamiques (DAST), de l'analyse de dépendances et une revue de conception menée en amont, plutôt que de me limiter à la détection automatique après écriture du code.
