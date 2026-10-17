// Activité 3 - protection concrète d'un WordPress (cas Ricardo).
#import "/template.typ": *

== Activité 3 : Protection concrète d'un WordPress (Ricardo)

#encadre("Objectifs")[
  - Recenser des serveurs WordPress par OSINT et intelligence collective.
  - Simuler une attaque générique puis ciblée, dans un cadre autorisé.
  - Évaluer les protections mises en place.
  - Durée indicative : 30 minutes.
]

=== Métiers pertinents
- *Analyste OSINT :* collecte des indices.
- *RSSI :* arbitrage.
- *Administrateur WordPress :* mises à jour.
- *SOC :* surveillance.
- *Équipe blue :* applique les contrôles.
- *Équipe red :* décrit seulement les scénarios de l'adversaire.

=== Déroulement
- *Cadre :* site fictif de Ricardo, autorisation écrite, périmètre limité aux sources passives.
- *Sources croisées :* index publics, pages d'archives, certificats, annonces du propriétaire.
- *Méthode :* qualifier chaque indice, partager uniquement les informations nécessaires.
- *Règle :* une concordance reste une hypothèse à confirmer par le propriétaire, jamais une preuve de vulnérabilité.

#table(
  columns: (1fr, 2fr, 1.4fr), [*Protection*], [*Contrôle*], [*Effet*],
  [Inventaire et mises à jour], [Référencer WordPress, extensions et thèmes ; corriger les écarts.], [Moins de composants exposés.],
  [MFA et moindre privilège], [Protéger l'administration par un second facteur et limiter les comptes.], [Accès compromis moins étendu.],
  [Segmentation et WAF], [Restreindre l'administration et filtrer les requêtes anormales.], [Moins d'exposition et de propagation.],
  [Sauvegardes testées], [Sauvegarder le site et la base, puis tester la restauration.], [Rétablissement plus rapide.],
  [Journalisation et alertes], [Centraliser les événements et qualifier les alertes.], [Détection et analyse des faux positifs.],
)

=== Temps 1 : Recensement passif de serveurs WordPress
- Rapprocher les signaux publics, contrôler les dates, supprimer les doublons.
- Conserver pour chaque ressource : source, indice, niveau de confiance.
- Faire confirmer les correspondances par le propriétaire.
- Aucun scan actif, aucune cible réelle testée.

=== Temps 2 : Attaque générique puis ciblée
La campagne générique recherche des erreurs de configuration, des composants obsolètes et des accès d'administration. Le WAF et les journaux signalent alors une activité répétée, et je vérifie les faux positifs avant de conclure. L'attaque ciblée utilise ensuite l'inventaire pour choisir le serveur le plus exposé ; MFA, moindre privilège et segmentation limitent l'accès et le mouvement vers la base. La réponse simulée enchaîne analyse, isolation et restauration. La simulation reste théorique : aucune commande, payload, credential ni exploitation réelle.

=== Résultats
- Un inventaire vérifiable de ressources candidates.
- Un scénario montrant l'effet de chaque protection : mises à jour, MFA, moindre privilège, segmentation, WAF, sauvegardes, alertes.
- Une simulation contenue, avec des écarts conservés et le besoin d'une réponse préparée.

=== Interprétation des résultats
La détection vient du croisement d'indices, pas d'une source isolée. La protection améliore la détection, limite la portée d'un incident et réduit le temps de rétablissement, mais elle ne garantit pas l'absence de compromission. Je retiens trois contrôles essentiels : un inventaire à jour, des faux positifs vérifiés, une restauration testée.

=== Références
- #link("https://developer.wordpress.org/advanced-administration/security/hardening/")[WordPress : Hardening WordPress]
- #link("https://csrc.nist.gov/pubs/sp/800/61/r3/final")[NIST SP 800-61 Rev. 3 : Incident Response Recommendations]
