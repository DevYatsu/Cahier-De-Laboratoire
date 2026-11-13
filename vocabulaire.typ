// Vocabulaire centralisé - termes des interventions spéciales et apprentissages
// divers.
#import "/template.typ": *

#pagebreak()
= Vocabulaire

Vocabulaire commun à toutes les interventions spéciales et aux apprentissages
divers. Source : PL1 et PL2 (Pascal Linder 1 et 2), VD (Vincent David), FR1
(Fabienne Roth 1).

== Organismes et rôles

#table(
  columns: (1fr, 2fr, 2fr),
  [*Terme*], [*Définition*], [*Relations*],
  [OFCS],
  [Office fédéral de la cybersécurité, anciennement NCSC. VD, PL1.],
  [Reçoit les annonces de cyberattaques des infrastructures critiques. Lien
    avec le juridique, FR1.],
  [SWITCH CERT],
  [Équipe de réponse aux incidents du réseau académique suisse. PL1.],
  [Conseille la cellule de crise de la HE-Arc. Proche du CIRT.],
  [PFPDT],
  [Préposé fédéral à la protection des données et à la transparence. FR1.],
  [Reçoit les annonces de violation de données prévues par la nLPD.],
  [SOC],
  [Security Operations Center : équipe et dispositif qui voient, détectent,
    analysent, décident, répondent et apprennent. VD, PL2, FR1.],
  [S'appuie sur SIEM, EDR/XDR, SOAR. Déclenche le CIRT. Dépend du juridique.],
  [CIRT],
  [Computer Incident Response Team : mène l'investigation approfondie et le
    rétablissement. FR1.],
  [Prend le relais du SOC pour les incidents lourds.],
  [EPT],
  [Équivalent plein temps, soit un poste à 100 %. PL1.],
  [Poste de chargé de sécurité créé après 2022.],
  [SI],
  [Systèmes d'information, et par extension le service qui les gère. PL1.],
  [],
)

== Menaces et attaquants

#table(
  columns: (1fr, 2fr, 2fr),
  [*Terme*], [*Définition*], [*Relations*],
  [APT],
  [Advanced Persistent Threat : groupe, souvent étatique, avancé, persistant
    et financé. Utilise zero-day et malware sur mesure. FR1.],
  [Opposé de l'opportuniste. Se décrit par ses TTP.],
  [RaaS],
  [Ransomware-as-a-Service : rançongiciel loué par ses auteurs à des affiliés.
    FR1.],
  [Modèle de Conti. Pratique la double extorsion.],
  [Double extorsion],
  [Chiffrer les données et menacer de les publier. PL2.],
  [Blog `.onion` dans l'attaque de la HE-Arc. Voir « bluff ou réalité ».],
  [Supply chain attack],
  [Attaque par rebond : compromettre un fournisseur pour atteindre sa cible.
    FR1.],
  [Menace externe.],
  [Script kiddie],
  [Attaquant peu qualifié qui utilise des outils existants. FR1.],
  [Menace externe opportuniste.],
  [Zero-day],
  [Vulnérabilité exploitée avant qu'un correctif n'existe. FR1.],
  [Arme typique des APT.],
  [Pass-the-Hash],
  [Technique de réutilisation de l'empreinte d'un mot de passe sans le
    connaître. FR1.],
  [Technique au sens des TTP, sert le mouvement latéral.],
  [Mouvement latéral],
  [Progression de l'attaquant d'une machine à l'autre dans le réseau. PL1,
    FR1.],
  [Tactique ATT&CK. Freiné par la microsegmentation, PL2.],
  [Noyautage],
  [Introduire une personne dans une organisation pour la désorganiser. FR1.],
  [Menace interne.],
)

== Concepts de défense

#table(
  columns: (1fr, 2fr, 2fr),
  [*Terme*], [*Définition*], [*Relations*],
  [Assume Breach],
  [Partir du principe que l'attaquant est déjà dans le réseau. FR1.],
  [Justifie la détection par le SOC en plus de la prévention.],
  [Dwell time],
  [Durée pendant laquelle l'intrus reste non détecté. FR1.],
  [Trois semaines à la HE-Arc en 2022, PL1. Le SOC cherche à le réduire.],
  [Blast radius],
  [Étendue des dégâts qu'une compromission peut causer. FR1.],
  [Réduit par la microsegmentation et la séparation des comptes à privilèges.],
  [TTP],
  [Tactics, Techniques & Procedures : le pourquoi, le comment et
    l'implémentation d'une attaque. FR1.],
  [Cataloguées par MITRE ATT&CK. Sommet de la Pyramid of Pain.],
  [MITRE ATT&CK],
  [Base de connaissances, mise à jour en continu, des tactiques et techniques
    d'attaque. FR1.],
  [Référentiel des TTP. Sert au Threat Hunting.],
  [CTI],
  [Cyber Threat Intelligence : collecter, analyser et contextualiser
    l'information sur les menaces. FR1.],
  [Alimente le SOC et le Threat Hunting.],
  [Pyramid of Pain],
  [Modèle de l'effort imposé à l'attaquant selon l'indicateur détecté, des hash
    jusqu'aux TTP. FR1.],
  [Détecter les TTP coûte le plus à l'attaquant.],
  [Threat Hunting],
  [Recherche proactive de compromission, sans attendre une alerte. FR1.],
  [Complète la détection par alerte. Appuyé par CTI et ATT&CK.],
  [Playbook],
  [Procédure écrite de réponse à un type d'incident, avec l'escalade. FR1.],
  [Pilier processus du SOC. Fiches réflexes, PL2.],
  [Microsegmentation],
  [Cloisonnement fin du réseau par des pare-feux internes. PL2.],
  [Limite le mouvement latéral et le blast radius.],
  [PDCA],
  [Plan, Do, Check, Act : roue de Deming, boucle d'amélioration continue. PL2.],
  [Cadre de l'amélioration continue de la HE-Arc. Base d'ISO 27001.],
  [Pentest],
  [Test d'intrusion : attaque autorisée pour trouver les failles. PL2.],
  [Étape Check du PDCA.],
)

== Outils et technologies

#table(
  columns: (1fr, 2fr, 2fr),
  [*Terme*], [*Définition*], [*Relations*],
  [SIEM],
  [Security Information and Event Management : centralise et corrèle les
    journaux. PL2, FR1.],
  [Outil central du SOC. Alimenté par EDR, VPN, Entra ID.],
  [EDR],
  [Endpoint Detection and Response : détection et réponse sur les postes et
    serveurs. PL1, PL2.],
  [Étendu en XDR. Source de journaux du SIEM.],
  [XDR],
  [Extended Detection and Response : EDR étendu, qui corrèle postes, réseau,
    identités et cloud. PL2, FR1.],
  [Généralise l'EDR. Proche du SIEM.],
  [SOAR],
  [Security Orchestration, Automation and Response : automatise les réponses
    répétitives. FR1.],
  [Exécute les playbooks. Réduit le temps de réponse.],
  [PIM],
  [Privileged Identity Management : accès à privilèges temporaires et validés.
    PL2.],
  [Applique la séparation des comptes à privilèges.],
  [Entra ID],
  [Annuaire cloud de Microsoft, ex-Azure AD. PL2.],
  [Source de journaux. Porte la MFA et le PIM.],
  [AD],
  [Active Directory : annuaire des comptes et machines d'un domaine Windows.
    PL1, PL2.],
  [Reconstruit en 2022, audité depuis.],
  [MFA],
  [Multi-Factor Authentication : au moins deux facteurs pour s'authentifier.
    PL1, PL2.],
  [Neutralise les identifiants volés. Voir Assume Breach.],
  [SRP],
  [Secure Remote Password : protocole d'authentification par mot de passe sans
    transmettre le secret. PL1.],
  [Déployé avec la MFA.],
  [VPN],
  [Virtual Private Network : tunnel chiffré vers le réseau interne. PL1, PL2.],
  [Porte d'entrée de l'attaquant en 2022.],
  [DNS],
  [Domain Name System : traduit les noms de domaine en adresses IP. PL1.],
  [Filtré par Cisco Umbrella.],
  [Cisco Umbrella],
  [Filtre DNS qui bloque les domaines malveillants. PL1, PL2.],
  [Source de journaux du SIEM.],
  [IP],
  [Internet Protocol : adressage des machines sur le réseau. PL1.],
  [IP de connexion VPN suivies en forensique.],
  [SQL],
  [Structured Query Language : langage des bases de données relationnelles.
    PL1.],
  [Serveur SQL atteint le 27 juin 2022.],
)

== Développement et exploitation

#table(
  columns: (1fr, 2fr, 2fr),
  [*Terme*], [*Définition*], [*Relations*],
  [CI/CD],
  [Continuous Integration / Continuous Delivery : chaîne automatisée de
    livraison du code. VD.],
  [Lieu des contrôles de sécurité automatisés.],
  [API], [Application Programming Interface. VD.], [Exposée par des endpoints.],
  [Endpoint],
  [Point d'accès exposé d'une API ou d'un service. VD.],
  [Surface d'attaque à surveiller.],
  [I/O], [Entrées/sorties (Input/Output). VD.], [],
  [Runtime],
  [Environnement d'exécution d'un programme. VD.],
  [Observé par l'observabilité.],
)
