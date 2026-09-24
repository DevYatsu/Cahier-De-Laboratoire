// Activité 3 - protection concrète d'un WordPress (cas Ricardo).
#import "/template.typ": *

== Activité 3 : Protection concrète d'un WordPress (Ricardo)

#encadre("Objectifs")[Utiliser l'OSINT et l'intelligence collective pour recenser des serveurs WordPress, puis simuler une attaque générique et ciblée dans un cadre autorisé. Évaluer les protections mises en place. Durée indicative : 30 minutes.]

=== Métiers pertinents
L'analyste OSINT, le RSSI, l'administrateur WordPress et le SOC couvrent respectivement la collecte, l'arbitrage, les mises à jour et la surveillance. L'équipe blue applique les contrôles ; l'équipe red décrit seulement les scénarios de l'adversaire.

=== Déroulement
Je travaille sur le site fictif de Ricardo, avec une autorisation écrite et un périmètre limité aux sources passives. Je croise les index publics, les pages d'archives, les certificats et les annonces du propriétaire, puis je qualifie chaque indice et limite les données partagées aux informations nécessaires. Une concordance devient une hypothèse à confirmer par le propriétaire, jamais une preuve de vulnérabilité.

#table(
  columns: (1fr, 2fr, 1.4fr), [*Protection*], [*Contrôle*], [*Effet*],
  [Inventaire et mises à jour], [Référencer WordPress, extensions et thèmes ; corriger les écarts.], [Moins de composants exposés.],
  [MFA et moindre privilège], [Protéger l'administration par un second facteur et limiter les comptes.], [Accès compromis moins étendu.],
  [Segmentation et WAF], [Restreindre l'administration et filtrer les requêtes anormales.], [Moins d'exposition et de propagation.],
  [Sauvegardes testées], [Sauvegarder le site et la base, puis tester la restauration.], [Rétablissement plus rapide.],
  [Journalisation et alertes], [Centraliser les événements et qualifier les alertes.], [Détection et analyse des faux positifs.],
)

=== Temps 1 : Recensement passif de serveurs WordPress
Je rapproche les signaux publics, contrôle les dates et supprime les doublons. Je conserve pour chaque ressource sa source, son indice et son niveau de confiance ; le propriétaire confirme les correspondances. Je n'effectue aucun scan actif et je ne teste aucune cible réelle.

=== Temps 2 : Attaque générique puis ciblée
La campagne générique cherche des erreurs de configuration, des composants obsolètes et des accès d'administration. Dans la simulation, le WAF et les journaux signalent une activité répétée : je vérifie les faux positifs avant de conclure. L'attaque ciblée utilise ensuite l'inventaire pour choisir le serveur le plus exposé ; la MFA, le moindre privilège et la segmentation limitent l'accès et le mouvement vers la base. Je simule l'analyse, l'isolation et la restauration, sans commande, payload, credential ni exploitation réelle.

=== Résultats
J'obtiens un inventaire vérifiable de ressources candidates et un scénario montrant l'effet des mises à jour, de la MFA, du moindre privilège, de la segmentation, du WAF, des sauvegardes et des alertes. La simulation est contenue, mais je conserve les écarts et la nécessité d'une réponse préparée.

=== Interprétation des résultats
La détection vient du croisement d'indices, pas d'une source isolée. La protection améliore réellement la détection, limite la portée d'un incident et réduit le temps de rétablissement ; elle ne garantit pas l'absence de compromission. Je retiens l'inventaire à jour, les faux positifs vérifiés et la restauration testée comme contrôles essentiels.

=== Références
- #link("https://developer.wordpress.org/advanced-administration/security/hardening/")[WordPress : Hardening WordPress]
- #link("https://csrc.nist.gov/pubs/sp/800/61/r3/final")[NIST SP 800-61 Rev. 3 : Incident Response Recommendations]
