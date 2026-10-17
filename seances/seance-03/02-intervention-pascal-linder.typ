// Intervention Pascal Linder - squelette de travail, à compléter.
#import "/template.typ": *

== Intervention Pascal Linder

#encadre("Objectifs")[
  - Noter en vrac le déroulé de l'intervention de Pascal Linder sur l'intrusion subie par la HE-Arc.
  - Consolider le vocabulaire : acronymes, définitions, relations.
  - Résumer ce que j'en retiens en trois à cinq thématiques.
  - Indiquer les aspects à approfondir.
  - Répondre à la question : que faut-il absolument réussir dans une entreprise pour progresser en cybersécurité ?
  - Ajouter du recul et de la critique.
]

=== Métiers pertinents

- *Service informatique (SI) :* administrateurs systèmes et réseau ; ils détectent l'intrusion, isolent le réseau, analysent les logs, puis reconstruisent l'Active Directory et réinstallent serveurs et postes.
- *Responsable de la sécurité informatique :* poste créé après l'attaque (un EPT dédié) ; il pilote les nouvelles mesures : MFA, EDR, gestion des accès à privilèges, filtre DNS.
- *Direction :* membre de la cellule de crise ; elle arbitre les priorités de remise en état des services.
- *Communication :* membre de la cellule de crise ; elle gère la communication interne vers plus de 3500 comptes et la gestion médiatique.
- *Analystes de SWITCH CERT et du NCSC :* réponse à incident ; ils conseillent la cellule de crise et proposent de tout remettre à zéro.
- *Analyste forensique :* analyse du disque, suivi des IP de connexion VPN.
- *Enquêteurs de la police et de FedPol :* reçoivent la déclaration, mènent l'enquête pénale.
- *Partenaires et prestataires externes :* renforcent l'équipe pendant la crise.

=== Déroulement

==== Chronologie de l'attaque

- 9 juin: Intrusion -> utilisateur téléchargeant un malware en voulant installer
  un
- 10 juin: Notification de son hébergeur lui informant qu'il y a des connexions
  suspectes sur son compte, il change de mdp
- 13 juin: 1ère connexion de l'attaquant à travers le VPN
- 17 juin: l'attaquant scanne les ports à travers la connexion VPN
- 23 juin: Mouvements latéraux, l'attaquant essaie de se connecter sur d'autres
  serveurs internes à travers la connexion VPN.
- 27 juin: Connexion au serveur SQL, le service des automates tombe
- 28 juin: Connexion au serveur Exchange
- 29-30 juin: Scan de ports et le service tombe à nouveau, l'attaquant accède à
  un compte à privilèges, alertes EDR et Dump de data
- 1er juillet: Intrusion confirmée par le service info, VPN désactivé et alertes
  EDR
- 4 juillet: Informer NCSC SWITCH CERT Audit qu'une attaque est bien confirmée +
  reçu d'un mail de rançon
- 5 juillet: Séance de crise et collecte de logs

==== Réactions

- Isolation du réseau: couper les services publiés et stopper la connexion
  internet
- Création cellule de crise (service info, direction, communication, SWITCH,
  police)
- Contacter nos partenaires pour nous aider dans cette crise
- Déterminer les moyens de communications (interne)
- Déterminer la gestion médiatique

==== 1ers réflexes en parallèle à la recherche et analyse de logs

- copie de sécurité des sauvegardes sur un support externe
- (Re)discussion et modification des priorités de remise en état des services
- Déplacement des boîtes de messagerie dans le cloud (moyen de comm entre le SI
  et la direction)
- Étude de la reconstruction d'un domaine informatique (adressage réseau,
  domaine, réinstallation des serveurs)
- Mise en place d'outils de sécurité supplémentaires pour le suivi de l'attaque
  (EDR, filtre DNS)

==== Réflexions/Contraintes

- *Délai imposé :* tout remettre en service avant la rentrée académique 2022-2023, soit environ un mois et demi. La direction doit trancher fin juillet ; repartir d'un domaine neuf en un mois est jugé irréaliste.
- *Choix de reconstruction :* SWITCH CERT propose de tout repartir de zéro, mais l'école ne retient pas cette option. Elle restaure la sauvegarde antérieure à l'intrusion (date de début connue), puis réinstalle l'OS de chaque poste. Comptes et objets machines sont désactivés, et les mots de passe des comptes de services et des 3500 utilisateurs changés.
- *Joindre les utilisateurs sans messagerie :* vacances, six sites, une partie du personnel pas encore au courant ; les utilisateurs doivent contacter l'école eux-mêmes.
- *Ingénierie sociale :* l'annuaire volé sert à de faux appels pour se faire passer pour des utilisateurs, d'où une réinitialisation des comptes en personne uniquement, sur présentation d'une carte d'identité.
- *Priorités de remise en service :* l'infrastructure de base passe avant les besoins métiers. La direction ne comprend pas toujours cet ordre, ce qui crée des tensions.
- *Facteur humain :* personnel épuisé en pleine période de vacances, enseignants stressés pour préparer la rentrée. La direction accepte un rythme soutenable pour garder le personnel efficace. Le service informatique n'a aucune expérience de la MFA pour accompagner les utilisateurs : documentation interne et FAQ à créer.

==== Conséquences / Défis

- Réinstallation d'un annuaire (Active Directory), importation d'une sauvegarde
- Tous les comptes et objets machines ont été désactivés
- Réactivation des comptes utilisateurs et de services après l'identification de
  l'utilisateur et d'un changement de mdp
- Réactivation des serveurs et services. Modif. des mdp.
- Réinstallation de tous les postes de travail (>1000 ordinateurs + ordinateurs
  étudiants)
- Interruption des services durant plusieurs semaines -> perte de productivité
- Accumulation de retard sur le traitement des dossiers
- Augmentation des heures travaillées -> épuisement du personnel (vacances)
- Comm avec les utilisateurs >3500 comptes
- Informations et gestion médiatique
- Difficultés liées aux nouvelles mesures mises en place, à l'incompréhension de
  la situation
- Manque de communication et documentation utilisateur

==== Finalité

- Exports de données mais on ne sait pas lesquelles
- Suivi des IP: connexions VPN
- Déclaration police + FedPol
- Analyse du disque
- Pas d'encryption
- Pas de publication
- Classe d'attaque: attaque non ciblée, par opportunité (moins de moyens des
  attaquants)

==== Nouvelles mesures - technique

- Déplacement de certains services dans le cloud (messagerie, MFA)
- On-premise / cloud, limiter la synchro des comptes, séparer les comptes à
  privilèges
- Mise en place de gestion des accès à privilèges
- Déploiement d'un EDR aussi sur les serveurs
- Limiter l'accès à internet (par zone)
- Engagement d'un EPT dédié à la sécurité informatique

==== Nouvelles mesures - utilisateur

- Limiter les accès VPN (zones géographiques) -> aujourd'hui retiré, car trop
  limitant en pratique
- Implémentation d'un filtre DNS (Cisco Umbrella)
- Limiter les postes de travail dans notre domaine (Active Directory),
  privilégier Intune
- Séparer la zone dédiée aux étudiants (services)
- Mise en place du SRP avec MFA
- Enlever les droits administrateurs locaux sur les postes de travail
- Bandeau d'avertissement des mails externes

==== Conclusion

- Erreur humaine impossible à éliminer
- Utilisation du MFA partout où possible
- Former les utilisateurs !

==== Vocabulaire

- *EDR* : Endpoint Detection and Response.
- *SWITCH CERT* : CERT national suisse, l'organisme à alerter.
- *SRP* : Secure Remote Password.
- *EPT* : équivalent plein temps (un poste à 100 %).
- *VPN* : Virtual Private Network.
- *MFA* : Multi-Factor Authentication.
- *DNS* : Domain Name System.
- *NCSC* : centre national de cyber-sécurité suisse.
- *SI* : Systèmes d'information.
- *SQL* : Structured Query Language.
- *IP* : Internet Protocol.

=== Résultats

*L'intrusion vient d'un utilisateur, pas d'une faille technique.* Le 9 juin, un poste télécharge un malware en voulant installer un logiciel ; le 10 juin, l'hébergeur alerte sur des connexions suspectes. Aucun exploit, aucune campagne ciblée : une opportunité saisie.

*La persistance passe par le VPN, puis par les comptes à privilèges.* Du 13 au 23 juin, l'attaquant utilise le VPN, scanne les ports et tente un mouvement latéral. Le point de bascule survient les 29-30 juin avec l'accès à un compte à privilèges. C'est ce passage qui élargit réellement la portée de l'incident, pas l'intrusion initiale.

*La réponse est tenue, mais elle se paie cher.* La procédure est suivie : cellule de crise, isolement du réseau, alerte du NCSC et de SWITCH CERT, saisines police et FedPol. Le prix : des semaines d'interruption, plus de 1000 postes réinstallés, 3500 comptes repris un par un.

*L'attaquant n'a pas utilisé son levier.* Il n'y a eu ni chiffrement ni publication, et les données exportées restent non identifiées. Cette absence de chiffrement ne rassure pas : le compte à privilèges lui en ouvrait la voie.

=== Interprétation des résultats

*Que faut-il absolument réussir pour progresser en cybersécurité ?* Ni un outil, ni une certification, mais trois choses, dans cet ordre :
+ *Savoir ce que l'on protège et où :* sans inventaire fiable, reconstruire le domaine et réinstaller plus de 1000 postes ne peut être ni planifié ni chiffré.
+ *Détecter tôt et rétablir vite :* ces deux durées sont les seules qui comptent vraiment. Ici, la compromission est restée invisible en interne pendant trois semaines (du 9 juin au 1er juillet), puis le rétablissement a pris des semaines.
+ *Savoir dire ce que l'on ne sait pas :* l'export est confirmé mais non caractérisé ; c'est le risque que je retiens comme le plus sérieux.

*Ce que je critique :*
- *Le changement de mot de passe du 10 juin n'a rien arrêté :* l'attaquant entre par le VPN le 13. Changer un mot de passe sans révoquer les sessions actives ne referme rien si les identifiants sont déjà exfiltrés ; c'est la MFA qui traite ce cas, pas le changement de secret.
- *Limitation géographique du VPN retirée, trop limitante :* la mesure théoriquement excellente et la mesure effectivement déployable ne sont pas la même chose.
- *Sauvegardes :* l'absence de chiffrement a tenu les données hors de portée de l'attaquant, mais la copie des sauvegardes sur support externe au début de la crise n'a, elle, jamais été cartonnée.

*Ce que je voudrais approfondir :*
- *L'obligation de déclaration :* ce qui déclenche l'alerte du NCSC et la saisine de FedPol, et dans quel délai ; mes notes donnent la chronologie, pas la règle.
- *Le périmètre de la reconstruction :* tout réinitialiser (proposition de SWITCH CERT) ou réparer chirurgicalement ? La décision repose sur des critères de coût et de risque que je ne sais pas encore évaluer.
- *Le volet forensique :* identifier les données exportées suppose des méthodes que je n'ai jamais pratiquées.

*Ce que cela change pour moi :* cet incident relie mon futur travail de dev et d'admin à celui du RSSI. Mes correctifs et mon inventaire déterminent si la reconstitution est possible, et le temps de rétablissement se mesure sur ce que j'ai produit. J'en tire deux réflexes : tenir l'inventaire à jour, et traiter la MFA et la restauration testée comme des prérequis, pas comme des améliorations.
