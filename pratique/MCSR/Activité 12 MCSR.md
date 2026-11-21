# Activité 12 : MCSR appliquée à DataHealth

**Participants :** Adam Belaziz, Yanis Amani

## Contexte spécifique et cadre réglementaire

### Système à protéger

DataHealth est une startup suisse qui exploite une plateforme SaaS de
télésurveillance médicale pour environ 8 000 patients.

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

## 0. Phases 1 à 3

### 0.1 Processus (phase 1)

P01 est un processus support. P02 à P05 sont les services métier.

| ID | Processus | Objectif principal | Objectifs secondaires | Écarts maximaux admissibles | Dépendances |
| --- | --- | --- | --- | --- | --- |
| P01 | Authentification et gestion des accès | Contrôler l'accès selon le rôle de l'utilisateur | Sécurité des identités, traçabilité des connexions | Authentification indisponible > 8 h ouvrables ; privilège non autorisé | — |
| P02 | Collecte et transmission des mesures | Collecter les mesures des objets connectés et les transmettre à la plateforme | Intégrité, confidentialité et horodatage des mesures | Perte de mesures au-delà du cache de 48 h ; mesure altérée ou attribuée au mauvais patient | P01 |
| P03 | Partage avec les hôpitaux | Fournir aux hôpitaux partenaires un centre de données partagé | Étanchéité entre établissements, pseudonymisation des flux | Accès d'un hôpital aux patients d'un autre ; divulgation de données identifiantes | P01, P02 |
| P04 | Analyse et entraînement | Entraîner les modèles d'analyse sur les données du data lake | Respect du consentement, non-réidentification | Réidentification de personnes | P02, P03 |
| P05 | Consultation par les médecins | Consulter les dossiers patients et recevoir les alertes d'anomalies | Secret médical, traçabilité des accès | Portail indisponible > 8 h ouvrables ; accès à un dossier hors périmètre | P01, P02, P04 |

### 0.2 Objets informatiques à protéger (phase 2)

| ID | Nom | Description | Processus | Composants | Données et flux | Personnes | Conditions-cadres |
| --- | --- | --- | --- | --- | --- | --- | --- |
| O01 | Application mobile patients | Application iOS et Android | P01, P02 | Application multiplateforme, cache SQLite de 48 h | Mesures des objets connectés, envoi HTTPS vers l'API | Patients | App Store, Google Play |
| O02 | Plateforme backend et BD | Cluster Kubernetes managé et PostgreSQL | P01, P02, P03, P05 | Ingress, API REST qui applique les autorisations, PostgreSQL, sauvegardes | Mesures, dossiers patients, requêtes FHIR | Backend, DevOps/SRE | Cloud ISO 27001 en Suisse, sauvegardes à Francfort |
| O03 | Portail web et passerelle FHIR | Application web et points d'accès FHIR | P01, P03, P05 | SPA, passerelle FHIR, sessions | Consultation des dossiers, alertes, échanges FHIR | Médecins, hôpitaux | Cloud, accès HTTPS |
| O04 | Data lake et moteur ML | Ingestion, stockage et entraînement des modèles | P02, P04, P05 | Stockage objet, pipeline ETL de pseudonymisation, moteur d'anomalies | Mesures brutes, jeux pseudonymisés, scores d'anomalies | Data/ML, DevOps/SRE | Stockage en Suisse, entraînement en Irlande |
| O05 | Gestionnaire d'identités | Fournisseur d'identités OAuth2/OIDC | P01 à P05 | Service d'authentification, console MFA | Identifiants, jetons, rôles | Employés, médecins | Prestataire SaaS |
| O06 | Notifications et alertes | Diffusion des alertes du moteur ML | P05 | Service de notification, passerelles SMS et e-mail | Alertes, coordonnées des médecins | Médecins, support | Prestataire SMS |

### 0.3 Besoins de protection (phase 3)

| Objet | Objectifs | Événement inacceptable | Écart non admissible | Accru | Justification |
| --- | --- | --- | --- | --- | --- |
| O01 | C, I, D | Vol du cache d'un smartphone ; mesure altérée | Non | Non | L'impact touche un seul patient et au plus 48 h de mesures. |
| O02 | C, I, D, T | Fuite de la BD ; indisponibilité > 8 h ; sauvegardes lisibles à Francfort | Oui : indisponibilité de P05, fuite massive, accès hors périmètre | **Oui** | Contient les dossiers des 8 000 patients et décide des autorisations. |
| O03 | C, I, T | Accès d'un hôpital aux patients d'un autre | Non | Non | Ne stocke pas les dossiers et ne décide pas des autorisations : c'est O02 qui le fait. |
| O04 | C, I | Réidentification ; modèle falsifié | Oui : réidentification pour P04, fausses alertes pour P05 | **Oui** | Conserve les données brutes et exporte vers l'Irlande. |
| O05 | C, D, T | Panne de l'IdP ; vol de jeton | Non | Non | Le seuil de P01 est de 8 h. Les droits fins sont vérifiés par O02. |
| O06 | D, I | Alerte non envoyée ; SMS intercepté | Non | Non | Les alertes restent visibles dans le portail. La plateforme n'est pas un service d'urgence, à confirmer. |

C = confidentialité, I = intégrité, D = disponibilité, T = traçabilité.

## 1. Légende des statuts

| Code | Statut | Critère |
| --- | --- | --- |
| S | Satisfait | Mécanisme en place et preuve suffisante |
| P | Partiellement satisfait | Mécanisme en place mais incomplet, ou écart démontré |
| NS | Non satisfait | Mécanisme absent |
| NV | Non vérifié | Mécanisme affirmé sans preuve exploitable |
| NP | Non pertinent | Exigence sans objet, avec justification |

Preuves : D = document, C = configuration, J = journal, E = entretien, A = aucune.

## 2. Tableau d'audit

Évaluation provisoire, à mettre à jour après l'interview avec l'assistant. Pour
une exigence NV, la dernière colonne indique la preuve à demander. « ? » signifie
que le contexte ne dit pas si le mécanisme existe.

| ID | Famille | Exigence | Réf. | Applicable | Objets | Mécanisme | Constat | Preuve | Statut | Accru | Écart / MTO ou preuve à obtenir | Priorité |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| E01 | GV | Organisation de la sécurité | GV 1.1 | O | Entreprise | ? | Aucun responsable de la sécurité connu | A | NV | N | Organigramme, désignation d'un responsable | 1 |
| E02 | GV | Gestion des cyberrisques | GV 1.2* | N | — | — | Non applicable avec la MCSR | — | NP | N | — | — |
| E03 | GV | Contrôle du personnel | GV 1.3 | O | Entreprise | ? | Accès des équipes techniques aux données de santé, aucun contrôle connu | A | NV | N | Procédure d'embauche, engagements de confidentialité | 2 |
| E04 | GV | Formation et sensibilisation | GV 1.4 | O | Entreprise | ? | Aucune formation connue | A | NV | N | Plan de formation, listes de présence | 2 |
| E05 | ID | Objets informatiques à protéger | ID 2.1* | N | — | — | Non applicable avec la MCSR | — | NP | N | — | — |
| E06 | ID | Chaînes logistiques | ID 2.2 | O | O02, O04, O05, O06 | ? | Quatre fournisseurs critiques, évaluation non démontrée | E | NV | N | Contrats de sous-traitance, SLA, certificats | 1 |
| E07 | PR | Surface d'attaque, cloisonnement, durcissement | PR 3.1 | O | O02, O03, O04 | ? | Protection physique déléguée au cloud, durcissement non documenté | E | NV | N | Configuration Kubernetes, rapport CIS Benchmark | 2 |
| E08 | PR | Vulnérabilités et mises à jour | PR 3.2 | O | O01 à O04 | ? | Aucun processus de correctifs connu | A | NV | N | SBOM, rapport de scan, délais de correction | 2 |
| E09 | PR | Identités et accès | PR 3.3 | O | O02, O03, O05 | O | MFA disponible, mais obligation non démontrée | E | NV | N | Politique MFA, matrice des rôles | 1 |
| E10 | PR | Sécurité du réseau | PR 3.4 | O | O02, O03, O04 | ? | Segmentation et filtrage non documentés | A | NV | N | Règles réseau et pare-feu | 2 |
| E11 | PR | Malwares et attaques par les données | PR 3.5 | O | O01, O02, O03 | ? | Données reçues d'appareils non maîtrisés, validation non démontrée | A | NV | N | Validation des entrées de l'API, tests DAST | 2 |
| E12 | PR | Chiffrement et suppression | PR 3.6 | O | O01 à O06 | O | Data lake avec données brutes identifiantes ; SMS avec contenu des alertes | D | P | N | Voir M02 et M03 | 1 |
| E13 | PR | Sauvegardes | PR 3.7 | O | O02, O04 | O | Sauvegardes automatisées, restauration jamais démontrée | E | NV | N | Politique de sauvegarde, test de restauration | 2 |
| E14 | PR | Développement sécurisé | PR 3.8 | O | O01 à O04 | ? | CI/CD et séparation dev/prod non documentés | A | NV | N | Configuration CI/CD, séparation des environnements | 2 |
| E15 | PR | Disponibilité | PR 3.9 | O | O02, O03, O05 | O | Redondance multi-zones non démontrée ; IdP point unique de défaillance | E | NV | N | Architecture multi-zones, SLA | 2 |
| E16 | DE | Journalisation et surveillance | DE 4.1 | O | O01 à O06 | ? | Aucune journalisation centralisée connue | A | NV | N | Journaux d'accès, règles d'alerte | 1 |
| E17 | DE | Canal de signalement | DE 4.2 | O | O01, O03 | ? | Aucun canal connu | A | NV | N | Fichier security.txt | 3 |
| E18 | RS/RC | Gestion des incidents | RS/RC 5.1 | O | Entreprise | ? | Aucune procédure connue | A | NV | N | Procédure, registre des incidents | 1 |
| E19 | RS/RC | Plans d'urgence | RS/RC 5.2 | O | O02, O05 | ? | Aucun plan connu | A | NV | N | Plan d'urgence, compte rendu d'exercice | 2 |
| E20 | RS/RC | Communication de crise | RS/RC 5.3 | O | Entreprise | ? | Destinataires et responsables non définis | A | NV | N | Plan de communication | 3 |
| E21 | GV | Analyse d'impact | nLPD art. 22 | O | O02, O04 | ? | Obligatoire, existence inconnue | A | NV | O | Analyse d'impact validée | 1 |
| E22 | PR | Clés des sauvegardes détenues par DataHealth | PR 3.6 | O | O02 | O | Chiffrement affirmé, détenteur des clés inconnu | E | NV | O | Configuration KMS, contrat | 1 |
| E23 | PR | Tests d'étanchéité entre établissements | PR 3.3 | O | O02 | O | Contrôle affirmé, aucun test connu | E | NV | O | Tests d'autorisation, test d'intrusion | 1 |
| E24 | DE | Journal inaltérable des accès aux dossiers | DE 4.1 | O | O02 | ? | Aucun journal connu | A | NV | O | Stockage non modifiable, revue | 2 |
| E25 | RS/RC | Restauration en moins de 8 h | RS/RC 5.2 | O | O02 | ? | Aucune durée mesurée | A | NV | O | Rapport d'exercice | 2 |
| E26 | PR | Pseudonymisation dès l'ingestion | PR 3.6 | O | O04 | O | Données brutes stockées avant pseudonymisation | D | P | O | Voir M02 | 1 |
| E27 | PR | Intégrité des modèles | PR 3.8 | O | O04 | ? | Aucun registre de modèles connu | A | NV | O | Registre des modèles | 2 |
| E28 | GV | Consentement tracé | nLPD, LRH | O | O04 | ? | Aucun registre connu | A | NV | O | Registre des consentements | 2 |

## 3. Indicateurs

N = 28 lignes, NP = 2, A = 26 applicables, S = 0, P = 2, NS = 0, NV = 24.

| Indicateur | Formule | Valeur |
| --- | --- | --- |
| Exigences applicables | A / N | 92,9 % |
| Satisfaites ou partiellement satisfaites | (S + P) / A | 7,7 % |
| Pleinement satisfaites | S / A | 0 % |
| Mécanismes existants avec écart ou preuve incomplète | Mécanisme = O, statut P ou NV | 7, soit 26,9 % |

Conclusion : DataHealth ne documente pas sa sécurité. Les valeurs sont à
recalculer après l'interview.

### 3.1 Répartition par famille

| Famille | S | P | NS | NV | NP | Total |
| --- | --- | --- | --- | --- | --- | --- |
| GV | 0 | 0 | 0 | 5 | 1 | 6 |
| ID | 0 | 0 | 0 | 1 | 1 | 2 |
| PR | 0 | 2 | 0 | 11 | 0 | 13 |
| DE | 0 | 0 | 0 | 3 | 0 | 3 |
| RS/RC | 0 | 0 | 0 | 4 | 0 | 4 |
| **Total** | **0** | **2** | **0** | **24** | **2** | **28** |

### 3.2 Répartition pour les objets à protection accrue

Lignes qui citent l'objet, statut évalué pour cet objet.

| Objet | S | P | NS | NV | NP | Total |
| --- | --- | --- | --- | --- | --- | --- |
| O02 | 0 | 0 | 0 | 17 | 0 | 17 |
| O04 | 0 | 2 | 0 | 10 | 0 | 12 |

## 4. Mesures prioritaires

M02 et M03 corrigent les écarts démontrés. M01, M04 et M05 sont obligatoires
dans tous les cas. M06 à M08 s'appliquent si l'interview confirme l'écart.
Échéances en mois après l'audit.

| Priorité | MTO | Écart traité | Objets | Famille | Effort | Responsable | Échéance | Preuve attendue |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | M01 : désigner un responsable de la sécurité | E01 | Entreprise | GV | S | Direction | M+1 | Décision de la direction |
| 1 | M02 : pseudonymiser dès l'ingestion et supprimer les données brutes | E12, E26 | O04 | PR | M | Data/ML | M+3 | Pipeline modifié, test de k-anonymat |
| 1 | M03 : retirer toute donnée de santé des SMS | E12 | O06 | PR | S | Backend | M+1 | Gabarit du SMS |
| 1 | M04 : réaliser l'analyse d'impact | E21 | O02, O04 | GV | M | Responsable sécurité | M+3 | Analyse validée |
| 2 | M05 : rédiger la procédure d'incident avec annonce au PFPDT | E18, E20 | Entreprise | RS/RC | S | Responsable sécurité | M+2 | Procédure, exercice sur table |
| 2 | M06 : chiffrer les sauvegardes avec des clés de DataHealth | E22 | O02 | PR | M | DevOps/SRE | M+3 | Configuration KMS |
| 2 | M07 : imposer la MFA et tester l'étanchéité dans le CI/CD | E09, E23 | O02, O05 | PR | M | DevOps/SRE, backend | M+2 | Politique MFA, résultats des tests |
| 3 | M08 : centraliser les journaux d'accès aux dossiers | E16, E24 | O02, O03 | DE | L | DevOps/SRE | M+6 | Journaux, règles d'alerte |

## 5. Concepts de sécurité pour les objets à protection accrue (phase 4)

Ces MTO s'ajoutent aux exigences fondamentales.

### 5.1 O02 : Plateforme backend et BD

| Écart non admissible | MTO supplémentaire | Mise en œuvre | Indicateur de suivi |
| --- | --- | --- | --- |
| Fuite massive de dossiers, y compris par les sauvegardes de Francfort | Clés de chiffrement détenues par DataHealth ; accès administrateur temporaire et validé | DevOps/SRE, M+3 | Aucune clé chez le fournisseur |
| Accès d'un hôpital ou d'un médecin hors de son périmètre | Autorisation par établissement et par lien de soins, refus par défaut, testée à chaque déploiement | Backend, M+2 | 100 % des points d'accès testés |
| Accès abusif non détecté | Journal non modifiable de chaque accès à un dossier, alerte sur les accès en masse, revue mensuelle | DevOps/SRE, M+6 | 100 % des accès journalisés |
| Indisponibilité > 8 h | Déploiement multi-zones en Suisse, sauvegarde hors ligne, restauration exercée chaque trimestre | DevOps/SRE, M+3 | Restauration mesurée ≤ 8 h |

### 5.2 O04 : Data lake et moteur ML

| Écart non admissible | MTO supplémentaire | Mise en œuvre | Indicateur de suivi |
| --- | --- | --- | --- |
| Réidentification de personnes | Pseudonymisation avant stockage, table de correspondance séparée, suppression des données brutes | Data/ML, M+3 | Aucun identifiant direct dans le data lake |
| Export réidentifiable vers l'Irlande ou sans consentement | Contrôle de k-anonymat et filtre de consentement bloquants avant export | Data/ML, M+3 | Rapport de k-anonymat par export |
| Modèle falsifié produisant de fausses alertes | Registre des modèles avec empreinte, validation à deux dont un médecin, surveillance du taux d'alertes | Data/ML, M+4 | 100 % des modèles en production enregistrés |

## 6. PSSI simplifiée de DataHealth

| Élément | Valeur |
| --- | --- |
| Version | v0.1, 2026-11-01 |
| Propriétaire | Responsable de la sécurité |
| Approbation | Direction |
| Révision | Annuelle et après tout incident majeur |
| Diffusion | Collaborateurs et prestataires ayant accès aux systèmes |

### 1. Objet et périmètre

Cette politique protège les données de santé des patients et la continuité des
services. Elle couvre les processus P01 à P05, les objets O01 à O06, les
collaborateurs et les prestataires.

### 2. Objectifs et cadre réglementaire

La sécurité doit garantir :

- la confidentialité des données de santé et le secret médical ;
- l'intégrité des mesures et des alertes ;
- la disponibilité dans les écarts admissibles du tableau 0.1.

Les obligations légales sont listées dans le cadre réglementaire impératif.

### 3. Principes directeurs

1. **Minimisation** : seules les données nécessaires au soin sont collectées et conservées.
2. **Moindre privilège** : chacun reçoit uniquement les droits utiles à sa tâche.
3. **Sécurité par défaut** : toute fonction est conçue sécurisée et livrée avec ses protections actives.
4. **Confiance minimale** : la position dans le réseau ne donne aucun accès.
5. **Données hors de Suisse** : elles sont pseudonymisées ou chiffrées avec des clés de DataHealth.
6. **Preuve** : chaque règle se démontre par un document, une configuration ou un journal.

### 4. Rôles et responsabilités

| Rôle | Responsabilités |
| --- | --- |
| Direction | Responsabilité globale, approbation de la PSSI et des écarts acceptés |
| Responsable de la sécurité | Pilotage de la PSSI, des audits et des incidents ; rapport trimestriel à la direction |
| Conseiller à la protection des données | Analyse d'impact et annonces au PFPDT ; peut être cumulé avec le rôle précédent |
| Responsables d'objets | Application des règles à leur objet et fourniture des preuves |
| Collaborateurs et prestataires | Respect de la PSSI, formation, signalement des incidents |

### 5. Objets et besoins de protection

| Objet | Besoin | Responsable |
| --- | --- | --- |
| O01 Application mobile | Normal | Responsable mobile |
| O02 Plateforme backend et BD | **Accru** | Responsable DevOps/SRE |
| O03 Portail web | Normal | Responsable backend |
| O04 Data lake et moteur ML | **Accru** | Responsable Data/ML |
| O05 Gestionnaire d'identités | Normal | Responsable de la sécurité |
| O06 Notifications | Normal | Responsable backend |

### 6. Conformité

- Un audit MCSR doit être conduit chaque année.
- Chaque écart doit être traité par une MTO ou accepté par écrit par la direction.
- Un écart non admissible ne peut pas être accepté.

### 7. Exigences de protection

- **Accès** : la MFA doit être activée pour tous les comptes. Les droits doivent être revus chaque semestre.
- **Chiffrement** : les données de santé doivent être chiffrées en transit et au repos.
- **Messages** : un SMS ou un e-mail ne doit contenir aucune donnée de santé.
- **Vulnérabilités** : les failles critiques devraient être corrigées sous 7 jours.
- **Développement** : le CI/CD doit inclure des contrôles de sécurité. Aucune donnée réelle ne doit servir aux tests.
- **Sauvegardes** : elles doivent être quotidiennes, avec une copie hors ligne, et restaurées en exercice chaque trimestre.
- **Formation** : chaque collaborateur doit être formé à l'arrivée puis chaque année.

### 8. Objets à protection accrue

O02 et O04 doivent en plus appliquer les MTO de la section 5.

### 9. Détection et journalisation

- Les connexions, les accès aux dossiers et les actions d'administration doivent être journalisés.
- Les journaux doivent être conservés 12 mois sous une forme non modifiable.
- Les alertes doivent être revues chaque jour ouvrable.
- Un fichier security.txt doit permettre aux externes de signaler une faille.

### 10. Incidents et continuité

1. Tout incident doit être signalé au responsable de la sécurité dans l'heure.
2. Un incident qui touche des données de santé est escaladé à la direction.
3. Une violation à risque élevé doit être annoncée au PFPDT dans les meilleurs délais, et aux hôpitaux concernés.
4. La reprise d'O02 doit se faire en moins de 8 h. Les plans doivent être exercés chaque année.
5. Chaque incident majeur donne lieu à un retour d'expérience écrit.

### 11. Prestataires

- Chaque prestataire critique doit signer un contrat de sous-traitance avec des clauses de sécurité.
- Un prestataire devrait prouver son niveau par une certification ou un audit.
- La liste des prestataires doit être revue chaque année.

### 12. Exceptions et révision

- Une dérogation doit être écrite, limitée dans le temps et approuvée par la direction.
- Le non-respect de la PSSI peut entraîner des sanctions disciplinaires ou contractuelles.
