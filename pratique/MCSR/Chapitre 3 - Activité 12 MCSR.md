# Activité 12 : MCSR appliquée à DataHealth
**Participants :** Adam Belaziz, Yanis Amani
## Contexte spécifique et cadre réglementaire
### Système à protéger
DataHealth est une startup suisse qui exploite une plateforme SaaS de télésurveillance médicale pour environ 8 000 patients.

| Élément | Description |
| --- | --- |
| Acteurs | Patients, médecins, hôpitaux partenaires, équipes backend, DevOps/SRE, Data/ML et support |
| Services | Collecte des mesures des objets connectés, consultation par les médecins, détection d'anomalies par IA, partage avec les hôpitaux |
| Ressources | Application mobile, API backend, base de données patients, data lake, portail web, infrastructure cloud |
| Fournisseurs | Cloud certifié ISO 27001, entraînement ML en Irlande, fournisseur d'identités SaaS, passerelle SMS, magasins d'applications |
### Objectifs stratégiques et économiques
Ces objectifs sont déduits du contexte et restent à confirmer auprès de l'assistant.

- Fournir un service fiable sur lequel les médecins fondent une décision médicale.

- Garder la confiance des hôpitaux partenaires, principale source de revenus.

- Valoriser les données par l'IA, avantage concurrentiel de la startup.

- Rester conforme : une non-conformité bloque les contrats hospitaliers.
### Spécificités du domaine de la santé
- Les données de santé sont sensibles et couvertes par le secret médical.

- Une mesure ou une alerte erronée peut provoquer une erreur médicale.

- Des données quittent la Suisse vers Francfort et l'Irlande.

- Le moteur d'anomalies peut être un dispositif médical.
### Cadre réglementaire impératif


| Texte | Portée | Conséquence |
| --- | --- | --- |
| nLPD | Données de santé = données sensibles | Protection dès la conception, analyse d'impact obligatoire, annonce des violations au PFPDT |
| nLPD art. 16 | Sauvegardes à Francfort, entraînement en Irlande | Transfert permis vers ces pays, mais contrat de sous-traitance et maîtrise des clés exigés |
| Secret professionnel, art. 321 CP | DataHealth agit comme auxiliaire des médecins | Toute divulgation de données identifiantes est un écart non admissible |
| RGPD | Sous-traitants dans l'UE, patients résidant dans l'UE | Mêmes exigences que la nLPD pour ces flux |
| MedDO | Logiciel de détection d'anomalies, à confirmer | Exigences de qualité et de traçabilité sur le moteur d'anomalies |
| LRH | Si l'entraînement est qualifié de recherche, à confirmer | Consentement des patients pour la réutilisation des données |
## 0. Rappel : tableaux des phases 1 à 3
### 0.1 Activités / processus (phase 1)
P01 est un processus support. P02 à P05 sont les services métier.

| ID | Processus | Objectif principal | Objectifs secondaires | Écarts maximaux admissibles | Dépendances |
| --- | --- | --- | --- | --- | --- |
| P01 | Authentification et gestion des accès | Contrôler l'accès selon le rôle de l'utilisateur | Sécurité des identités, traçabilité des connexions | Authentification indisponible > 8 h ouvrables ; privilège non autorisé | — |
| P02 | Collecte et transmission des mesures | Collecter les mesures des objets connectés et les transmettre à la plateforme | Intégrité, confidentialité et horodatage des mesures | Perte de mesures au-delà du cache de 48 h ; mesure altérée ou attribuée au mauvais patient | P01 |
| P03 | Partage avec les hôpitaux | Fournir aux hôpitaux partenaires un centre de données partagé | Étanchéité entre établissements, pseudonymisation des flux | Accès d'un hôpital aux patients d'un autre ; divulgation de données identifiantes | P01, P02 |
| P04 | Analyse et entraînement | Entraîner les modèles d'analyse sur les données du data lake | Respect du consentement, non-réidentification | Réidentification de personnes | P02, P03 |
| P05 | Consultation par les médecins | Consulter les dossiers patients et recevoir les alertes d'anomalies | Secret médical, traçabilité des accès | Portail indisponible > 8 h ouvrables ; accès à un dossier hors périmètre | P01, P02, P04 |
### 0.2 Objets informatiques à protéger (phase 2)


| ID | Nom | Description / plateformes | Processus servis | Composants principaux | Données et flux | Personnes / groupes | Conditions-cadres (fournisseurs, localisation) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| O01 | Application mobile patients | Application iOS et Android | P01, P02 | Application multiplateforme, cache SQLite de 48 h | Mesures des objets connectés, envoi HTTPS vers l'API | Patients | App Store, Google Play |
| O02 | Plateforme backend et BD | Cluster Kubernetes managé et PostgreSQL | P01, P02, P03, P05 | Ingress, API REST qui applique les autorisations, PostgreSQL, sauvegardes | Mesures, dossiers patients, requêtes FHIR | Backend, DevOps/SRE | Cloud ISO 27001 en Suisse, sauvegardes à Francfort |
| O03 | Portail web et passerelle FHIR | Application web et points d'accès FHIR | P01, P03, P05 | SPA, passerelle FHIR, sessions | Consultation des dossiers, alertes, échanges FHIR | Médecins, hôpitaux | Cloud, accès HTTPS |
| O04 | Data lake et moteur ML | Ingestion, stockage et entraînement des modèles | P02, P04, P05 | Stockage objet, pipeline ETL de pseudonymisation, moteur d'anomalies | Mesures brutes, jeux pseudonymisés, scores d'anomalies | Data/ML, DevOps/SRE | Stockage en Suisse, entraînement en Irlande |
| O05 | Gestionnaire d'identités | Fournisseur d'identités OAuth2/OIDC | P01 à P05 | Service d'authentification, console MFA | Identifiants, jetons, rôles | Employés, médecins | Prestataire SaaS |
| O06 | Notifications et alertes | Diffusion des alertes du moteur ML | P05 | Service de notification, passerelles SMS et e-mail | Alertes, coordonnées des médecins | Médecins, support | Prestataire SMS |
### 0.3 Besoins de protection (phase 3)


| Objet | Objectif concerné (confidentialité, intégrité, disponibilité, traçabilité, autre) | Événement inacceptable | Écart non admissible ? (oui/non, lequel) | Besoin de protection accru ? | Justification |
| --- | --- | --- | --- | --- | --- |
| O01 | C, I, D | Vol du cache d'un smartphone ; mesure altérée | Non | Non | L'impact touche un seul patient et au plus 48 h de mesures. |
| O02 | C, I, D, T | Fuite de la BD ; indisponibilité > 8 h ; sauvegardes lisibles à Francfort | Oui : indisponibilité de P05, fuite massive, accès hors périmètre | **Oui** | Contient les dossiers des 8 000 patients et décide des autorisations. |
| O03 | C, I, T | Accès d'un hôpital aux patients d'un autre | Non | Non | Ne stocke pas les dossiers et ne décide pas des autorisations : c'est O02 qui le fait. |
| O04 | C, I | Réidentification ; modèle falsifié | Oui : réidentification pour P04, fausses alertes pour P05 | **Oui** | Conserve les données brutes et exporte vers l'Irlande. |
| O05 | C, D, T | Panne de l'IdP ; vol de jeton | Non | Non | Le seuil de P01 est de 8 h. Les droits fins sont vérifiés par O02. |
| O06 | D, I | Alerte non envoyée ; SMS intercepté | Non | Non | Les alertes restent visibles dans le portail. La plateforme n'est pas un service d'urgence, à confirmer. |
C = confidentialité, I = intégrité, D = disponibilité, T = traçabilité.

Rappel : un objet a un besoin de protection accru uniquement si la violation d'un objectif peut provoquer au moins un écart non admissible.
## 1. Légende des statuts


| Code | Statut | Critère |
| --- | --- | --- |
| S | Satisfait | Mécanisme en place **et** preuve suffisante |
| P | Partiellement satisfait | Mécanisme en place mais couverture incomplète ou écart démontré |
| NS | Non satisfait | Mécanisme absent |
| NV | Non vérifié | Mécanisme affirmé mais aucune preuve exploitable pour conclure |
| NP | Non pertinent | Exigence sans objet pour ce périmètre (justification obligatoire) |
Types de preuve : D = document, C = configuration / capture d'écran, J = journal, E = entretien (preuve faible), A = aucune.
## 2. Tableau d'audit
Une ligne par exigence fondamentale examinée (annexe C de la méthode) et, pour O02 et O04, par exigence complémentaire (E21 à E28).

Évaluation provisoire, fondée sur la fiche de cas DataHealth (« fiche ») et à mettre à jour après l'interview avec l'assistant. Un mécanisme que la fiche ne mentionne pas est noté absent (N, statut NS). Un mécanisme que la fiche affirme sans preuve est noté NV, avec la preuve à obtenir.

| ID | Famille | Exigence (résumé) | Réf. annexe C | Applicable (O/N) | Objet(s) | Mécanisme existant (O/N) | Constat | Preuve (type + référence) | Statut | Accru (O/N) | Écart / MTO proposée | Priorité (1-3) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| E01 | GV | Organisation de la sécurité | GV 1.1 | O | Entreprise | N | Aucun responsable de la sécurité désigné | A | NS | N | M01 : désigner un responsable de la sécurité | 1 |
| E02 | GV | Gestion des cyberrisques | GV 1.2* | N | — | — | Non applicable : la MCSR remplace ici l'analyse de risques | — | NP | N | — | — |
| E03 | GV | Contrôle du personnel | GV 1.3 | O | Entreprise | N | Les équipes techniques accèdent aux données de santé sans contrôle ni engagement connu | A | NS | N | M07 : engagement de confidentialité signé à l'embauche | 2 |
| E04 | GV | Formation et sensibilisation | GV 1.4 | O | Entreprise | N | Aucune formation mentionnée | A | NS | N | M07 : formation à l'arrivée puis annuelle | 2 |
| E05 | ID | Objets informatiques à protéger | ID 2.1* | N | — | — | Non applicable : l'inventaire est produit par les phases 1 à 3 | — | NP | N | — | — |
| E06 | ID | Chaînes logistiques | ID 2.2 | O | O02, O04, O05, O06 | O | Quatre fournisseurs critiques ; seule la certification ISO 27001 du cloud est affirmée | E : fiche, description de l'hébergeur | NV | N | Obtenir : contrats de sous-traitance, SLA, certificats des quatre fournisseurs | 1 |
| E07 | PR | Surface d'attaque, cloisonnement, durcissement | PR 3.1 | O | O02, O03, O04 | O | Protection physique déléguée au cloud ; durcissement non documenté | E : fiche, hébergement cloud | NV | N | Obtenir : configuration Kubernetes, rapport CIS Benchmark | 2 |
| E08 | PR | Vulnérabilités et mises à jour | PR 3.2 | O | O01 à O04 | N | Aucun processus de correctifs mentionné | A | NS | N | Scan des dépendances dans le CI/CD, délais de correction de 7 et 30 jours | 2 |
| E09 | PR | Identités et accès | PR 3.3 | O | O02, O03, O05 | O | MFA disponible dans l'IdP, obligation non démontrée | E : fiche, gestionnaire d'identités | NV | N | Obtenir : politique MFA, matrice des rôles | 1 |
| E10 | PR | Sécurité du réseau | PR 3.4 | O | O02, O03, O04 | N | Aucune segmentation ni filtrage mentionné | A | NS | N | Politiques réseau Kubernetes, refus par défaut entre services | 2 |
| E11 | PR | Malwares et attaques par les données | PR 3.5 | O | O01, O02, O03 | N | Données reçues d'appareils non maîtrisés ; aucune validation mentionnée | A | NS | N | Validation des entrées de l'API, tests DAST | 2 |
| E12 | PR | Chiffrement et suppression | PR 3.6 | O | O01 à O06 | O | Data lake avec données brutes identifiantes ; SMS avec contenu des alertes | D : fiche, flux du data lake et des alertes | P | N | M02 et M03 | 1 |
| E13 | PR | Sauvegardes | PR 3.7 | O | O02, O04 | O | Sauvegardes automatisées affirmées, restauration jamais démontrée | E : fiche, infrastructure | NV | N | Obtenir : politique de sauvegarde, rapport de test de restauration | 2 |
| E14 | PR | Développement sécurisé | PR 3.8 | O | O01 à O04 | N | Aucun contrôle de sécurité ni séparation dev/prod mentionnés | A | NS | N | Contrôles SAST dans le CI/CD, environnements séparés | 2 |
| E15 | PR | Disponibilité | PR 3.9 | O | O02, O03, O05 | O | Redondance multi-zones affirmée ; IdP point unique de défaillance | E : fiche, infrastructure | NV | N | Obtenir : schéma d'architecture multi-zones, SLA de l'IdP | 2 |
| E16 | DE | Journalisation et surveillance | DE 4.1 | O | O01 à O06 | N | Aucune journalisation centralisée mentionnée | A | NS | N | M08 : centraliser les journaux | 1 |
| E17 | DE | Canal de signalement | DE 4.2 | O | O01, O03 | N | Aucun canal mentionné | A | NS | N | Publier un fichier security.txt | 3 |
| E18 | RS/RC | Gestion des incidents | RS/RC 5.1 | O | Entreprise | N | Aucune procédure mentionnée | A | NS | N | M05 : procédure d'incident | 1 |
| E19 | RS/RC | Plans d'urgence | RS/RC 5.2 | O | O02, O05 | N | Aucun plan mentionné | A | NS | N | M06 : plan d'urgence exercé | 2 |
| E20 | RS/RC | Communication de crise | RS/RC 5.3 | O | Entreprise | N | Destinataires et responsables non définis | A | NS | N | M05 : plan de communication intégré à la procédure | 3 |
| E21 | GV | Analyse d'impact | nLPD art. 22 | O | O02, O04 | N | Obligatoire pour des données de santé ; aucune analyse mentionnée | A | NS | O | M04 : réaliser l'analyse d'impact | 1 |
| E22 | PR | Clés des sauvegardes détenues par DataHealth | PR 3.6 | O | O02 | O | Chiffrement des sauvegardes affirmé, détenteur des clés inconnu | E : fiche, sauvegardes à Francfort | NV | O | Obtenir : configuration KMS, contrat cloud | 1 |
| E23 | PR | Tests d'étanchéité entre établissements | PR 3.3 | O | O02 | O | Contrôle par l'API affirmé, aucun test connu | E : fiche, API backend | NV | O | Obtenir : tests d'autorisation, rapport de test d'intrusion | 1 |
| E24 | DE | Journal inaltérable des accès aux dossiers | DE 4.1 | O | O02 | N | Aucun journal des accès mentionné | A | NS | O | M08 : journal non modifiable des accès | 2 |
| E25 | RS/RC | Restauration en moins de 8 h | RS/RC 5.2 | O | O02 | N | Aucune procédure ni durée de restauration mentionnée | A | NS | O | M06 : exercice de restauration mesuré | 2 |
| E26 | PR | Pseudonymisation dès l'ingestion | PR 3.6 | O | O04 | O | Pipeline de pseudonymisation présent, mais données brutes stockées avant | D : fiche, pipeline ETL | P | O | M02 | 1 |
| E27 | PR | Intégrité des modèles | PR 3.8 | O | O04 | N | Aucun registre de modèles mentionné | A | NS | O | Registre des modèles avec empreinte (voir 5.2) | 2 |
| E28 | GV | Consentement tracé | nLPD, LRH | O | O04 | N | Aucun registre de consentement mentionné | A | NS | O | Registre des consentements, filtre avant entraînement | 2 |
## 3. Indicateurs (statistiques)
N = 28 lignes examinées, NP = 2, A = N − NP = 26, S = 0, P = 2, NS = 17, NV = 7.

| Indicateur | Formule | Valeur |
| --- | --- | --- |
| Exigences applicables | A / N | 92,9 % |
| Applicables satisfaites ou partiellement satisfaites | (S + P) / A | 7,7 % |
| Applicables pleinement satisfaites | S / A | 0 % |
| Mécanismes existants avec écart ou preuve incomplète | Mécanisme existant = O et statut P ou NV | 9 (soit 34,6 % de A) |
Conclusion : aucune exigence n'est démontrée. 17 exigences applicables n'ont aucun mécanisme connu, et les 9 mécanismes affirmés manquent de preuve ou présentent un écart. Les valeurs sont à recalculer après l'interview.
### 3.1 Répartition par famille (statistique)


| Famille | S | P | NS | NV | NP | Total |
| --- | --- | --- | --- | --- | --- | --- |
| GV | 0 | 0 | 5 | 0 | 1 | 6 |
| ID | 0 | 0 | 0 | 1 | 1 | 2 |
| PR | 0 | 2 | 5 | 6 | 0 | 13 |
| DE | 0 | 0 | 3 | 0 | 0 | 3 |
| RS/RC | 0 | 0 | 4 | 0 | 0 | 4 |
| **Total** | **0** | **2** | **17** | **7** | **2** | **28** |
### 3.2 Répartition pour les objets à besoin de protection accru (statistique)
Lignes du tableau d'audit qui citent l'objet, statut évalué pour cet objet.

| Objet | S | P | NS | NV | NP |
| --- | --- | --- | --- | --- | --- |
| O02 | 0 | 0 | 9 | 8 | 0 |
| O04 | 0 | 2 | 7 | 3 | 0 |
## 4. Choix des mesures prioritaires
Critères : (1) réduit un écart non admissible, (2) lève une obligation réglementaire, (3) effort faible à moyen, (4) preuve rapide à obtenir. Les exigences NV (E06, E07, E09, E13, E15, E22, E23) ne reçoivent pas de MTO tant que l'écart n'est pas démontré : leur preuve est demandée à l'interview. Échéances en mois après l'audit.

| Priorité | MTO | Écart traité | Objet(s) | Famille | Effort (S/M/L) | Responsable | Échéance | Preuve de mise en œuvre attendue |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | M01 : désigner un responsable de la sécurité | E01 | Entreprise | GV | S | Direction | M+1 | Décision de la direction |
| 1 | M02 : pseudonymiser dès l'ingestion et supprimer les données brutes | E12, E26 | O04 | PR | M | Data/ML | M+3 | Pipeline modifié, test de k-anonymat |
| 1 | M03 : retirer toute donnée de santé des SMS | E12 | O06 | PR | S | Backend | M+1 | Gabarit du SMS |
| 1 | M04 : réaliser l'analyse d'impact | E21 | O02, O04 | GV | M | Responsable sécurité | M+3 | Analyse validée par la direction |
| 2 | M05 : rédiger la procédure d'incident avec annonce au PFPDT et plan de communication | E18, E20 | Entreprise | RS/RC | S | Responsable sécurité | M+2 | Procédure, compte rendu d'exercice sur table |
| 2 | M06 : rédiger le plan d'urgence d'O02 et exercer une restauration complète | E19, E25 | O02 | RS/RC | M | DevOps/SRE | M+3 | Plan d'urgence, compte rendu avec durée mesurée ≤ 8 h |
| 2 | M07 : former tous les collaborateurs et faire signer un engagement de confidentialité | E03, E04 | Entreprise | GV | S | Responsable sécurité | M+2 | Listes de présence, engagements signés |
| 3 | M08 : centraliser les journaux et journaliser chaque accès aux dossiers | E16, E24 | O02, O03 | DE | L | DevOps/SRE | M+6 | Journaux, règles d'alerte |
## 5. Concepts de sécurité pour les objets à protection accrue (phase 4)
Un tableau par objet à protection accrue. Ces MTO s'ajoutent aux exigences fondamentales.
### 5.1 O02 : Plateforme backend et BD


| Écart non admissible à éviter | MTO supplémentaire (au-delà des exigences fondamentales) | Mise en œuvre (comment, qui, quand) | Preuve / indicateur de suivi |
| --- | --- | --- | --- |
| Fuite massive de dossiers, y compris par les sauvegardes de Francfort | Clés de chiffrement détenues par DataHealth ; accès administrateur temporaire et validé | Clés gérées par DataHealth dans le KMS du cloud, accès administrateur à la demande avec double validation ; DevOps/SRE ; M+3 | Configuration KMS : aucune clé chez le fournisseur |
| Accès d'un hôpital ou d'un médecin hors de son périmètre | Autorisation par établissement et par lien de soins, refus par défaut | Tests d'autorisation automatiques sur chaque point d'accès, exécutés à chaque déploiement ; backend ; M+2 | 100 % des points d'accès testés |
| Accès abusif non détecté | Journal non modifiable de chaque accès à un dossier, alerte sur les accès en masse | Journaux envoyés vers un stockage non modifiable, revue mensuelle des accès ; DevOps/SRE ; M+6 | 100 % des accès journalisés |
| Indisponibilité > 8 h | Déploiement multi-zones en Suisse, sauvegarde hors ligne | Cluster réparti sur deux zones, restauration exercée chaque trimestre ; DevOps/SRE ; M+3 | Restauration mesurée ≤ 8 h |
### 5.2 O04 : Data lake et moteur ML


| Écart non admissible à éviter | MTO supplémentaire (au-delà des exigences fondamentales) | Mise en œuvre (comment, qui, quand) | Preuve / indicateur de suivi |
| --- | --- | --- | --- |
| Réidentification de personnes | Pseudonymisation avant stockage, table de correspondance séparée, suppression des données brutes | Étape de pseudonymisation placée en tête du pipeline ETL, table stockée dans un coffre à accès restreint ; Data/ML ; M+3 | Aucun identifiant direct dans le data lake |
| Export réidentifiable vers l'Irlande ou sans consentement | Contrôle de k-anonymat et filtre de consentement bloquants avant export | Contrôle automatique qui bloque l'export en cas d'échec ; Data/ML ; M+3 | Rapport de k-anonymat par export |
| Modèle falsifié produisant de fausses alertes | Registre des modèles avec empreinte, validation à deux dont un médecin | Empreinte calculée à l'entraînement et vérifiée au déploiement, surveillance du taux d'alertes ; Data/ML ; M+4 | 100 % des modèles en production enregistrés |
## 6. PSSI simplifiée de DataHealth
### Gestion du document


| Élément | Valeur |
| --- | --- |
| Titre | PSSI de DataHealth |
| Version / date | v0.1 / 2026-11-01 |
| Propriétaire | Responsable de la sécurité |
| Approbation | Direction, en attente (projet) |
| Révision | Au moins une fois par an, et après tout incident majeur ou changement important |
| Diffusion | Tous les collaborateurs, et les prestataires ayant accès aux systèmes |
### Chapitre 1 : Objet, périmètre et destinataires
Cette politique fixe les règles qui protègent les données de santé des patients et la continuité du service de télésurveillance.

Elle s'applique :

- aux processus P01 à P05 et aux objets informatiques O01 à O06 (annexe B) ;

- à tous les collaborateurs, quel que soit leur contrat ;

- aux prestataires qui accèdent aux systèmes ou aux données de DataHealth.

Les médecins et les hôpitaux partenaires utilisent le service. Les règles qui les concernent figurent dans leurs contrats et conditions d'utilisation.
### Chapitre 2 : Enjeux, objectifs et cadre réglementaire
**Enjeux.** Les médecins fondent des décisions médicales sur les mesures et les alertes. Les hôpitaux partenaires apportent l'essentiel des revenus. Une fuite ou une non-conformité bloque ces contrats.

**Objectifs de sécurité.** La sécurité doit garantir :

- la confidentialité des données de santé et le respect du secret médical ;

- l'intégrité des mesures, des dossiers et des alertes ;

- la disponibilité du portail et de la plateforme : au plus 8 h ouvrables d'interruption ;

- la traçabilité de chaque accès à un dossier patient.

**Cadre réglementaire applicable.**

| Texte | Obligation pour DataHealth |
| --- | --- |
| nLPD art. 7 | Protéger les données dès la conception et par défaut |
| nLPD art. 9 | Encadrer chaque sous-traitant par un contrat |
| nLPD art. 16 | Encadrer les transferts vers l'Allemagne (sauvegardes) et l'Irlande (entraînement) |
| nLPD art. 22 | Réaliser une analyse d'impact, car les données de santé sont sensibles |
| nLPD art. 24 | Annoncer au PFPDT toute violation à risque élevé |
| Code pénal art. 321 | Respecter le secret professionnel en tant qu'auxiliaire des médecins |
| RGPD art. 28 et 33 | Pour les patients et sous-traitants de l'UE : contrat de sous-traitance, notification sous 72 h |
| MedDO (à confirmer) | Qualité et traçabilité du moteur d'anomalies s'il est qualifié de dispositif médical |
| LRH (à confirmer) | Consentement des patients si l'entraînement est qualifié de recherche |
| Contrats hospitaliers | Niveaux de service et clauses de sécurité convenus avec chaque hôpital |
### Chapitre 3 : Principes directeurs
1. **Minimisation** : seules les données strictement nécessaires au suivi médical doivent être collectées et conservées.

2. **Moindre privilège** : chaque personne doit recevoir uniquement les droits utiles à sa tâche.

3. **Sécurité dès la conception et par défaut** : toute nouvelle fonction doit être livrée avec ses protections actives.

4. **Confiance minimale** : un accès doit être accordé sur l'identité et le rôle vérifiés, jamais sur la seule position dans le réseau.

5. **Maîtrise des données hors de Suisse** : toute donnée qui quitte la Suisse doit être pseudonymisée ou chiffrée avec des clés détenues par DataHealth.

6. **Preuve et traçabilité** : chaque règle doit pouvoir être démontrée par un document, une configuration ou un journal.
### Chapitre 4 : Rôles et responsabilités


| Rôle | Responsabilités |
| --- | --- |
| Direction | Porte la responsabilité globale. Approuve la PSSI, les dérogations et les risques acceptés. |
| Responsable de la sécurité | Désigné par la direction. Pilote la PSSI, les audits et les incidents. Rapporte à la direction au moins une fois par trimestre. |
| Conseiller à la protection des données | Conduit l'analyse d'impact et les annonces au PFPDT. Le rôle peut être cumulé avec le précédent. |
| Responsables d'objets | Appliquent les règles à leur objet et fournissent les preuves lors des audits. |
| Collaborateurs | Respectent la PSSI, suivent la formation et signalent tout incident. |
| Prestataires | Respectent les clauses de sécurité de leur contrat et signalent tout incident. |
### Chapitre 5 : Inventaire et besoins de protection
Le besoin de protection est « accru » quand un événement peut provoquer un écart non admissible (fuite massive, réidentification, interruption > 8 h).

| Objet | Besoin | Responsable d'objet |
| --- | --- | --- |
| O01 Application mobile patients | Normal | Responsable mobile |
| O02 Plateforme backend et base de données | **Accru** | Responsable DevOps/SRE |
| O03 Portail web et passerelle FHIR | Normal | Responsable backend |
| O04 Data lake et moteur ML | **Accru** | Responsable Data/ML |
| O05 Gestionnaire d'identités | Normal | Responsable de la sécurité |
| O06 Notifications et alertes | Normal | Responsable backend |

L'inventaire doit être mis à jour à chaque ajout ou retrait d'un objet, et revu chaque année.
### Chapitre 6 : Gestion des risques et de la conformité
- Un audit selon la MCSR doit être conduit chaque année et après tout changement important.

- Chaque écart doit recevoir un statut, une preuve et une priorité.

- Chaque écart doit être traité par une mesure technique ou organisationnelle (MTO), ou accepté par écrit par la direction.

- Un écart non admissible ne peut pas être accepté. Il doit être traité.

- L'analyse d'impact doit être réalisée avant M+3, puis mise à jour à chaque nouveau traitement de données de santé.

- Le responsable de la sécurité doit suivre trois indicateurs chaque trimestre : part des exigences satisfaites, part des exigences non vérifiées, avancement du plan d'actions (annexe C).
### Chapitre 7 : Exigences de protection
- **Identités et accès** : l'authentification multifacteur (MFA) doit être activée pour tous les comptes de collaborateurs. Elle devrait être imposée aux comptes des médecins. Les droits doivent être revus chaque semestre.

- **Chiffrement** : les données de santé doivent être chiffrées pendant leur transfert et leur stockage.

- **Messages** : un SMS ou un e-mail ne doit contenir aucune donnée de santé. Il renvoie vers le portail.

- **Vulnérabilités** : les failles critiques devraient être corrigées sous 7 jours, les autres sous 30 jours.

- **Développement sécurisé** : la chaîne de construction et de déploiement (CI/CD) doit inclure des contrôles de sécurité automatiques. Aucune donnée réelle de patient ne doit servir aux tests.

- **Sauvegardes** : les sauvegardes doivent être quotidiennes, avec une copie hors ligne. Une restauration doit être exercée chaque trimestre.

- **Postes et réseaux** : les postes doivent être chiffrés et mis à jour automatiquement. Les environnements de développement et de production doivent être séparés.

- **Sensibilisation** : chaque collaborateur doit être formé à son arrivée, puis chaque année. Une liste de présence en apporte la preuve.
### Chapitre 8 : Exigences complémentaires pour les objets à protection accrue
Ces règles s'ajoutent à celles du chapitre 7.

**O02 Plateforme backend et base de données**

- Les clés de chiffrement des données et des sauvegardes doivent être détenues par DataHealth, et non par le fournisseur cloud.

- Un accès administrateur doit être temporaire et validé par une seconde personne.

- Un hôpital ou un médecin ne doit accéder qu'aux patients de son établissement et de son lien de soins. Cette règle doit être testée à chaque déploiement.

- Tout accès à un dossier patient doit être journalisé (qui, quand, quel dossier) dans un journal non modifiable.

- La plateforme doit être déployée sur plusieurs zones en Suisse. Une restauration complète doit être démontrée en moins de 8 h.

**O04 Data lake et moteur ML**

- Les données doivent être pseudonymisées avant leur stockage. Les données brutes identifiantes doivent être supprimées.

- La table de correspondance entre pseudonymes et identités doit être stockée à part, avec un accès restreint.

- Aucun export vers l'Irlande ne doit partir sans contrôle de k-anonymat (chaque personne se confond avec au moins k autres) et sans vérification du consentement.

- Chaque modèle mis en production doit être enregistré avec son empreinte et validé par deux personnes, dont un médecin.
### Chapitre 9 : Détection et journalisation
- **Ce qui est journalisé** : les connexions, les accès aux dossiers patients, les actions d'administration et les exports de données.

- **Durée** : les journaux doivent être conservés 12 mois sous une forme non modifiable.

- **Qui surveille** : l'équipe DevOps/SRE doit revoir les alertes chaque jour ouvrable. Le responsable de la sécurité revoit les accès aux dossiers chaque mois.

- **Seuils d'alerte** : une alerte doit se déclencher au-delà de 10 échecs de connexion en 5 minutes sur un compte, ou de 50 dossiers consultés en une heure par un même compte. Ces seuils initiaux sont ajustés après trois mois.

- **Signalement externe** : un fichier security.txt doit indiquer aux personnes externes comment signaler une faille.
### Chapitre 10 : Gestion des incidents, continuité et reprise
1. **Détection et signalement** : tout incident doit être signalé au responsable de la sécurité dans l'heure qui suit sa détection.

2. **Escalade** : un incident qui touche des données de santé doit être escaladé à la direction dans les 4 h.

3. **Notification** : une violation à risque élevé doit être annoncée au PFPDT dans les meilleurs délais. Pour les personnes dans l'UE, l'autorité compétente doit être notifiée sous 72 h. Les hôpitaux concernés et, si nécessaire, les patients doivent être informés.

4. **Reprise** : O02 doit être remis en service en moins de 8 h. Les plans d'urgence doivent être exercés chaque année.

5. **Retour d'expérience** : chaque incident majeur doit donner lieu à un rapport écrit dans les 30 jours, avec les mesures retenues.
### Chapitre 11 : Tiers et sous-traitants
- **Évaluation** : chaque prestataire critique (cloud, gestionnaire d'identités, passerelle SMS, entraînement ML) doit être évalué avant contrat. Il devrait prouver son niveau par une certification ISO 27001 ou un rapport d'audit.

- **Clauses contractuelles** : chaque contrat doit inclure un accord de sous-traitance, des niveaux de service, un délai d'annonce des incidents et un droit d'audit.

- **Localisation des données** : les données identifiantes doivent rester en Suisse. Une donnée stockée ou traitée à l'étranger doit être pseudonymisée ou chiffrée avec des clés de DataHealth.

- **Revue** : la liste des prestataires et de leurs contrats doit être revue chaque année.
### Chapitre 12 : Application, exceptions et révision
- **Dérogation** : une dérogation doit être demandée par écrit, justifiée, limitée à 12 mois au plus et approuvée par la direction. Le responsable de la sécurité tient le registre des dérogations.

- **Non-respect** : le non-respect de la PSSI peut entraîner des sanctions disciplinaires pour un collaborateur, ou contractuelles pour un prestataire.

- **Révision** : la PSSI doit être révisée au moins une fois par an, et après tout incident majeur ou changement important. Chaque version est approuvée par la direction.
### Annexes
**Annexe A : Glossaire**

| Terme | Définition |
| --- | --- |
| CI/CD | Chaîne automatique qui construit, teste et déploie le logiciel |
| FHIR | Norme d'échange de données médicales entre systèmes |
| MCSR | Norme minimale pour améliorer la résilience informatique |
| MFA | Authentification multifacteur : mot de passe plus un second facteur |
| MTO | Mesure technique ou organisationnelle |
| PFPDT | Préposé fédéral à la protection des données et à la transparence |
| Pseudonymisation | Remplacement des identifiants par un code, réversible uniquement avec une table séparée |

**Annexe B : Objets et besoins de protection** : voir sections 0.2 et 0.3.

**Annexe C : Plan d'actions priorisé** : voir section 4 (mesures M01 à M08).
### Liste de contrôle qualité (auto-évaluation)
- [x] Chaque règle est vérifiable : elle fixe un délai, une fréquence ou une preuve.

- [x] Chaque écart prioritaire de l'audit est couvert : E01 (ch. 4), E06 (ch. 11), E09 et E12 (ch. 7), E16 (ch. 9), E18 (ch. 10), E21 (ch. 6), E22, E23 et E26 (ch. 8).

- [x] Les objets à protection accrue (O02, O04) ont des exigences complémentaires explicites (ch. 8).

- [x] Les rôles sont des fonctions, pas des noms de personnes.

- [x] Le document est lisible par un non-informaticien : les sigles sont définis dans le glossaire.

- [x] Les obligations réglementaires identifiées sont mentionnées au chapitre 2.
