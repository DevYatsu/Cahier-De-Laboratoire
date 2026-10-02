// Intervention Pascal Linder - squelette de travail, à compléter.
#import "/template.typ": *

== Intervention Pascal Linder

#encadre("Objectifs")[Nous parler du piratage survenu il y a quelques années à la HE-Arc.]

=== Métiers pertinents

Membres du service info. À compléter.

=== Déroulement

==== Chronologie de l'attaque

- 9 juin: Intrusion -> utilisateur téléchargeant un malware en voulant installer un
- 10 juin: Notification de son hébergeur lui informant qu'il y a des connexions suspectes sur son compte, il change de mdp
- 13 juin: 1ère connexion de l'attaquant à travers le VPN
- 17 juin: l'attaquant scanne les ports à travers la connexion VPN
- 23 juin: Mouvements latéraux, l'attaquant essaie de se connecter sur d'autres serveurs internes à travers la connexion VPN.
- 27 juin: Connexion au serveur SQL, le service des automates tombe
- 28 juin: Connexion au serveur Exchange
- 29-30 juin: Scan de ports et le service tombe à nouveau, l'attaquant accède à un compte à privilèges, alertes EDR et Dump de data
- 1er juillet: Intrusion confirmée par le service info, VPN désactivé et alertes EDR
- 4 juillet: Informer NCSC SWITCH-CERT Audit qu'une attaque est bien confirmée + reçu d'un mail de rançon
- 5 juillet: Séance de crise et collecte de logs

==== Réactions

- Isolation du réseau: couper les services publiés et stopper la connexion internet
- Création cellule de crise (service info, direction, communication, SWITCH, police)
- Contacter nos partenaires pour nous aider dans cette crise
- Déterminer les moyens de communications (interne)
- Déterminer la gestion médiatique

==== 1ers réflexes en parallèle à la recherche et analyse de logs

- copie de sécurité des sauvegardes sur un support externe
- (Re)discussion et modification des priorités de remise en état des services
- Déplacement des boîtes de messagerie dans le cloud (moyen de comm entre le SI et la direction)
- Étude de la reconstruction d'un domaine informatique (adressage réseau, domaine, réinstallation des serveurs)
- Mise en place d'outils de sécurité supplémentaires pour le suivi de l'attaque (EDR, filtre DNS)

==== Réflexions/Contraintes

- SWITCH CERT propose de tout remettre à zéro
- xx

==== Conséquences / Défis

- Réinstallation d'un annuaire (Active Directory), importation d'une sauvegarde
- Tous les comptes et objets machines ont été désactivés
- Réactivation des comptes utilisateurs et de services après l'identification de l'utilisateur et d'un changement de mdp
- Réactivation des serveurs et services. Modif. des mdp.
- Réinstallation de tous les postes de travail (>1000 ordinateurs + ordinateurs étudiants)
- Interruption des services durant plusieurs semaines -> perte de productivité
- Accumulation de retard sur le traitement des dossiers
- Augmentation des heures travaillées -> épuisement du personnel (vacances)
- Comm avec les utilisateurs >3500 comptes
- Informations et gestion médiatique
- Difficultés liées aux nouvelles mesures mises en place, à l'incompréhension de la situation
- Manque de communication et documentation utilisateur

==== Finalité

- Exports de données mais on ne sait pas lesquelles
- Suivi des IP: connexions VPN
- Déclaration police + FedPol
- Analyse du disque
- Pas d'encryption
- Pas de publication
- Classe d'attaque: attaque non ciblée, par opportunité (moins de moyens des attaquants)

==== Nouvelles mesures - technique

- Déplacement de certains services dans le cloud (messagerie, MFA)
- On-premise / cloud, limiter la synchro des comptes, séparer les comptes à privilèges
- Mise en place de gestion des accès à privilèges
- Déploiement d'un EDR aussi sur les serveurs
- Limiter l'accès à internet (par zone)
- Engagement d'un EPT dédié à la sécurité informatique

==== Nouvelles mesures - utilisateur

- Limiter les accès VPN (zones géographiques) -> aujourd'hui retiré, car trop limitant en pratique
- Implémentation d'un filtre DNS (Cisco Umbrella)
- Limiter les postes de travail dans notre domaine (Active Directory), privilégier Intune
- Séparer la zone dédiée aux étudiants (services)
- Mise en place du SSRP avec MFA
- Enlever les droits administrateurs locaux sur les postes de travail
- Bandeau d'avertissement des mails externes

==== Conclusion

- Erreur humaine impossible à éliminer
- Utilisation du MFA partout où possible
- Former les utilisateurs !

=== Résultats

À compléter.

=== Interprétation des résultats

À compléter.