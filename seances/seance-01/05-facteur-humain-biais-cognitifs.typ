// Activité 4 - aspect humain, risques et biais cognitifs (partie après-midi).
#import "/template.typ": *

== Activité 4 : Aspect humain, risques et biais cognitifs
#text(size: 0.9em, fill: gray)[Partie après-midi · activité 4]

#encadre("Objectifs")[Comprendre les biais cognitifs qui affectent la sécurité : comment les repérer, les limiter, et pourquoi ils changent selon la personne et la culture.]

=== Métiers pertinents

RSSI, auditeur, chef de projet, dev : tout le monde est concerné. La sensibilisation n'est pas un bonus : c'est une mesure de réduction du risque.

=== Déroulement

==== Risques et biais cognitifs liés au cerveau

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

==== Stratégies générales

- *Red teaming* : simuler l'attaque pour briser la confirmation.
- *Diversité cognitive* : mélanger profils et expériences pour contrer l'ancrage.
- *Hypothèses écrites* : documenter ce qu'on suppose et pourquoi, cela expose l'ancrage.
- *Processus standardisés* : cadres comme l'ISO 27001 réduisent la dépendance à la mémoire individuelle.
- *Psychological safety* : permettre de signaler une erreur sans sanction, cela limite la confirmation et l'attribution fondamentale.

Références : #link("https://fr.wikipedia.org/wiki/Biais_cognitif")[Biais cognitif], #link("https://fr.wikipedia.org/wiki/Heuristique_de_jugement")[Heuristique de jugement].

==== Risques liés à une personne ou à une culture

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

==== Activité 4 : Que faire pour limiter ces risques de prise de décision ?

- *Écrire les hypothèses avant de décider* : noter ce qu'on suppose et pourquoi, puis relire à deux. L'ancrage devient visible.
- *Faire relire par un profil différent* : un dev relit l'analyse d'un admin, ou l'inverse. Le red teaming joue le même rôle contre la confirmation.
- *Appliquer une procédure écrite* : checklists et cadres type ISO 27001 pour les actions critiques, au lieu de compter sur la mémoire.
- *Signaler sans être sanctionné* : post-mortem sans blâme et erreurs remontées vite. Le silence coûte plus cher que l'aveu. (exact)
- *Surveiller la charge* : pauses, rotation des tâches de vigilance, alertes hiérarchisées. Un opérateur fatigué clique et ignore.

=== Résultats

Le tableau mappe six familles de biais, du sensori-moteur jusqu'à la personnalité, avec une stratégie précise pour chacune. Les risques se partagent entre l'individuel (fatigue, Dunning-Kruger, expertise partielle) et le collectif (culture du blâme, hiérarchie qui verrouille la contradiction). Les mitigations suivent la même découpe : mentorat et suivi de charge d'un côté, post-mortems sans blâme et leadership exemplaire de l'autre. La synthèse retient cinq réflexes applicables : hypothèses écrites, relecture croisée, procédures, signalement sans sanction, gestion de la charge.

Le schéma range les six familles : perception et mémoire en haut, jugement et traits en bas.
#align(center)[
  #diagram(
    spacing: (6mm, 8mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Sensori-moteurs*], fill: fond-rouge),
    node((1, 0), align(center)[*Attentionnels*], fill: white),
    node((2, 0), align(center)[*Mnésiques*], fill: white),
    node((0, 1), align(center)[*Jugement*], fill: white),
    node((1, 1), align(center)[*Raisonnement*], fill: white),
    node((2, 1), align(center)[*Personnalité*], fill: fond-rouge),
    edge((0, 0), (1, 0), "->"),
    edge((1, 0), (2, 0), "->"),
    edge((2, 0), (0, 1), "->"),
    edge((0, 1), (1, 1), "->"),
    edge((1, 1), (2, 1), "->"),
  )
]

=== Interprétation des résultats

Le facteur humain explique pourquoi les mesures techniques échouent : un admin sous surcharge ignore une alerte, un utilisateur confiant clique sur un lien. Les risques varient selon la personne et la culture : la sécurité est un système sociotechnique, pas juste des pare-feu.

Prochaine étape : intégrer ces observations dans l'évaluation du projet de semestre (charge cognitive, culture d'équipe, diversité des points de vue).
