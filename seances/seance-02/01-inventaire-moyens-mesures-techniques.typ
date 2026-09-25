// Exercice 5 - inventaire des moyens/mesures techniques de la cybersécurité.
#import "/template.typ": *

== Exercice 5 : Inventaire des moyens/mesures techniques de la cybersécurité

#encadre("Objectifs")[Créer un tableau mentionnant les catégories du slide, explicitant leur objectif pour chacune, puis des exemples de mesures techniques.]

#table(
  columns: (1.2fr, 3fr),
  align: (left, left),
  [*Catégorie*], [*Mesures techniques*],
  [*Prévention*], [Formations, tests, cadre réglementaire, mise à jour, chiffrement des accès],
  [*Détection*], [Logs, NDR, EDR, SIEM, monitoring],
  [*Confinement*], [VM, VLAN, sandbox, éviter les dépendances compromises],
  [*Contrainte*], [Architecture, PRA],
  [*Récupération*], [Tests, remise à 100 % en production],
)
