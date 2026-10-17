// Exercice 4 - principaux secteurs, domaines et objets d'application (partie matin).
#import "/template.typ": *

== Exercice 4 : Principaux secteurs, domaines et objets d'application

#encadre("Objectifs")[
  - Recenser où la sécurité s'applique et qui elle concerne.
  - Distinguer secteurs public, privé et domaines transverses.
  - Situer les échelles moi, nous et tous.
]

=== Métiers pertinents

- *Admin systèmes et réseau :* infrastructures critiques, OT.
- *Développeur :* cloud, logiciels.
- *RSSI :* entreprise.
- *DPO :* dossiers patients, fiscalité.
- *Ma position :* côté dev, je construis une partie des services que les autres protègent.

=== Déroulement

*Secteur public :*
- Défense et sécurité nationale : armée, renseignement, police, protection civile.
- Santé publique : hôpitaux, services d'urgence, dossiers patients.
- Administrations et collectivités : état civil, fiscalité, vote, services en ligne.
- Éducation et recherche : universités, laboratoires, données scientifiques.
- Infrastructures critiques : énergie, eau, transports, télécommunications.
- Justice : tribunaux, casiers, preuves numériques.

*Secteur privé :*
- Entreprises : PME et grands groupes, secrets industriels, SI interne, postes de travail.
- Objets protégés : contrats, comptabilité, propriété intellectuelle, continuité d'activité.

*Domaines transverses, au global :*
- Santé et pharmaceutique : dispositifs médicaux, essais cliniques, brevets, chaînes de production.
- Informatique et technologique : cloud, logiciels, matériel, opérateurs télécoms, prestataires.
- Finance et assurance : banques, paiements, données clients.
- Industrie et énergie : OT (technologies opérationnelles), SCADA, chaînes logistiques.

*Qui est concerné ?*
- Moi : mes comptes, mes appareils, mes projets de développement.
- Nous : l'entreprise ou l'équipe où je travaille, ses clients et ses fournisseurs.
- Tout le monde : chaque citoyen utilise des services dont la compromission a un impact collectif.

=== Résultats

Le secteur public couvre la défense, la santé, l'état civil, la justice et les infrastructures critiques (énergie, transports). Le secteur privé protège le SI interne, les contrats, la comptabilité et la propriété intellectuelle. Les domaines transverses relient les deux : dispositifs médicaux, cloud, banques, SCADA. Je suis concerné à chaque échelle : moi par mes comptes et mes projets, nous par mon équipe et ses clients, tous par les services collectifs que chaque citoyen utilise.

#align(center)[
  #diagram(
    spacing: (6mm, 8mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Public*], fill: fond-rouge),
    node((1, 0), align(center)[*Transverses*], fill: white),
    node((2, 0), align(center)[*Privé*], fill: white),
    node((0, 1), align(center)[*Moi*], fill: fond-rouge),
    node((1, 1), align(center)[*Nous*], fill: fond-rouge),
    node((2, 1), align(center)[*Tous*], fill: fond-rouge),
    edge((0, 0), (1, 0), "->"),
    edge((1, 0), (2, 0), "->"),
    edge((1, 0), (0, 1), "->"),
    edge((1, 0), (1, 1), "->"),
    edge((1, 0), (2, 1), "->"),
  )
]

=== Interprétation des résultats

Aucun secteur ne fonctionne sans sécurité. Hôpital, banque et chaîne logistique protègent des objets différents, mais une compromission bloque leur activité de la même façon. Côté dev, chaque ligne de code atterrit dans un de ces secteurs : une faille dans une app de vote ou de paiement ne reste jamais théorique. À l'échelle nationale et des alliances, la cybersécurité conditionne le fonctionnement de la société, car une compromission peut toucher des services essentiels dans plusieurs pays à la fois.

Pour le projet de semestre, le périmètre se fixe en trois questions :
- Qui utilise le service ?
- Que protège-t-il ?
- Que coûterait une compromission à chaque échelle ?
