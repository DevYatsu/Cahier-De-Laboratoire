// Activité 4 — aspect humain, risques et biais cognitifs (partie après-midi).
#import "/template.typ": *

== Activité 4 : aspect humain, risques et biais cognitifs

#encadre("Objectifs")[Comprendre les biais cognitifs qui affectent la sécurité : comment les repérer, les limiter, et pourquoi ils changent selon la personne et la culture.]

=== Métiers pertinents

RSSI, auditeur, chef de projet, dev : tout le monde est concerné. La sensibilisation n'est pas un bonus : c'est une mesure de réduction du risque.

=== Résultats

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

=== Que faire pour limiter ces risques de prise de décision ?

"À compléter."

=== Interprétation des résultats

Le facteur humain explique pourquoi les mesures techniques échouent : un admin sous surcharge ignore une alerte, un utilisateur confiant clique sur un lien. Les risques varient selon la personne et la culture : la sécurité est un système sociotechnique, pas juste des pare-feu.

Prochaine étape : intégrer ces observations dans l'évaluation du projet de semestre (charge cognitive, culture d'équipe, diversité des points de vue).
