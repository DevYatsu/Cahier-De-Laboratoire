// Exercice 4 - principaux secteurs, domaines et objets d'application (partie matin).
#import "/template.typ": *

== Exercice 4 : Principaux secteurs, domaines et objets d'application
#text(size: 0.9em, fill: gray)[Partie matin]

#encadre("Objectifs")[Recenser où la sécurité s'applique et qui elle concerne. Je distingue les secteurs public et privé ainsi que les domaines transverses, puis les échelles moi, nous et tous.]

=== Métiers pertinents

Tous les secteurs listés en Déroulement ont leurs métiers : admin systèmes et réseau sur les infrastructures critiques et l'OT, dev sur le cloud et les logiciels, RSSI en entreprise, DPO sur les dossiers patients et la fiscalité. Je me place côté dev : je construis une partie des services que les autres protègent.

=== Déroulement

La question porte sur où la sécurité s'applique et sur qui elle concerne. Je distingue le secteur public, le secteur privé, puis les domaines transverses.

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

Côté public, la sécurité couvre la défense, la santé, l'état civil et la justice, plus les infrastructures critiques comme l'énergie et les transports. Côté privé, elle protège le SI interne, les contrats, la comptabilité et la propriété intellectuelle. Les domaines transverses relient les deux : dispositifs médicaux, cloud, banques, SCADA. À chaque niveau je suis concerné : mes comptes et mes projets, puis mon équipe et ses clients, puis les services collectifs que tout citoyen utilise.

Le schéma résume la couverture : public et privé reliés par les transverses, qui irriguent les trois échelles.
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

Aucun secteur ne fonctionne sans sécurité. Un hôpital, une banque et une chaîne logistique ont des objets différents à protéger, mais la compromission bloque leur activité de la même façon. Côté dev, je retiens que chaque ligne de code atterrit dans un de ces secteurs : une faille dans une app de vote ou de paiement ne reste jamais théorique. Pour le projet de semestre, cela fixe le périmètre : décrire qui utilise le service, ce qu'il protège, et ce qu'une compromission coûterait à chaque échelle.

La cybersécurité à l'échelle nationale ou au sein d'alliances est aussi une condition de fonctionnement de la société : une compromission peut affecter des services essentiels et plusieurs pays à la fois.
