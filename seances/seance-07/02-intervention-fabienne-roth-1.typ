// Intervention spéciale - Fabienne Roth 1, responsable SOC (9h15-11h30).
#import "/template.typ": *

== Intervention spéciale : Fabienne Roth 1

Fabienne Roth est ingénieure cyber chez Roche, à Bâle. Son parcours : Senior
Engineer Identity & Access Management, puis Team Lead Secure Access Engineering,
puis Head of Monitoring & Incident Response. Thème : l'anatomie d'un SOC.

=== Éléments essentiels

==== Ce qu'est un SOC

Combien de temps un attaquant reste-t-il dans une entreprise sans être détecté ?
Cela dépend de ce qu'il fait, et du SOC et des outils de détection de
l'entreprise.

Le SOC réunit du personnel technique et opérationnel qualifié. C'est le point
focal des opérations de sécurité et de la défense du réseau. Il permet de *voir,
détecter, analyser, décider, répondre et apprendre*. Chaque décision pèse ses
conséquences sur l'entreprise : couper un système arrête l'attaquant, mais aussi
l'activité.

==== Les trois piliers

- *Humains et IA :* spécialistes techniques qui créent les alertes, détectent et
  prennent les mesures.
- *Processus :* règles opérationnelles, playbooks d'intervention (dont
  l'escalade vers le niveau supérieur), exigences de conformité légale.
- *Technologie :* SIEM, EDR/XDR, SOAR, flux de Threat Intelligence ; télémétrie
  à grande échelle, corrélation des événements, automatisation des tâches
  répétitives pour réduire le temps de détection et de réponse.

==== Assume Breach

La sécurité préventive devrait être infaillible à 100 %, mais une seule erreur
suffit à l'attaquant. Et même un système infaillible ne suffirait pas : les
attaquants ne forcent plus les portes blindées, ils entrent avec des
identifiants volés. Le SOC part donc du principe que l'attaquant est déjà dans
le réseau.

==== La mission du SOC

- *Réduire le dwell time :* raccourcir le temps pendant lequel l'intrus évolue
  sans être vu.
- *Limiter le blast radius :* isoler la menace avant qu'elle n'atteigne les
  actifs critiques.
- *Orchestrer l'intervention lourde (CIRT) :* investigation numérique
  approfondie et rétablissement sécurisé des systèmes critiques.
- *Valider les contrôles en continu :* vérifier qu'une alerte se déclenche bien
  quand une barrière préventive est franchie.
- *Être proactif :* anticiper les tactiques et les attaques futures.

Les jours de vacances sont en général les plus critiques : moins de personnel,
réaction plus lente. L'intrusion de la HE-Arc (juin-juillet 2022) en est un
exemple.

==== Typologie des menaces

#table(
  columns: (1fr, 2fr),
  [*Origine*], [*Acteurs*],
  [Externe : franchir le périmètre],
  [Opportunistes et bots ; attaques par rebond (supply chain) ; script kiddies
    et hacktivistes ; cybercriminalité organisée (Ransomware-as-a-Service) ;
    groupes étatiques (APT).],
  [Interne : malveillance ou négligence],
  [Négligence et erreur humaine ; compromission de comptes (vol d'identité) ;
    noyautage (introduire une personne pour désorganiser).],
)

Une APT est *avancée* (zero-day, malware sur mesure, furtivité), *persistante*
(espionnage sur le long terme) et une *menace* financée et coordonnée par un
gouvernement. Contre la menace interne, une personne récemment recrutée ou visée
par une enquête reçoit des accès restreints.

==== Comprendre l'attaquant

- *TTP :* le mode opératoire. La tactique dit *pourquoi* (accès initial,
  élévation de privilèges, mouvement latéral, exfiltration). La technique dit
  *comment* (phishing, Pass-the-Hash). La procédure décrit l'implémentation
  spécifique.
- *MITRE ATT&CK :* base de connaissances, mise à jour en continu, qui
  cartographie les tactiques et techniques.
- *Cyber Threat Intelligence :* collecter, analyser et contextualiser
  l'information sur les menaces pour orienter les décisions.
- *Pyramid of Pain :* plus l'indicateur détecté est haut (des hash jusqu'aux
  TTP), plus l'attaquant doit fournir d'effort pour s'adapter.
- *Threat Hunting :* recherche proactive de signes de compromission par des
  analystes, sans attendre une alerte.
- *Bluff ou réalité :* une revendication n'est pas une preuve. Une fuite
  annoncée peut être réelle, exagérée, ancienne ou inventée.

==== Étude de cas : Conti

Groupe cybercriminel russophone, à motivation financière, spécialisé dans le
ransomware. Il fonctionne comme une entreprise : salariés (administrateurs
réseau, pentesters, experts en criminologie), âge moyen de 25 à 30 ans. Mode
opératoire : entrer (phishing, identifiants volés, vulnérabilités), puis
progresser (vol d'identifiants, élévation de privilèges, mouvements latéraux).

#table(
  columns: (1fr, 3fr),
  [*Date*], [*Événement*],
  [2020], [Émergence du groupe.],
  [Janvier 2021], [Attaque de FatFace.],
  [Mai 2021], [Attaque du service de santé irlandais (HSE).],
  [Juillet 2021], [Fuite de documents internes.],
  [Février 2022],
  [Un membre, en désaccord avec la politique du groupe, publie les échanges
    internes.],
  [Mai-juin 2022], [Abandon progressif de la marque et des infrastructures.],
)

=== Pourquoi le SOC dépend-il fortement du service juridique ?

Le SOC établit les faits, mais la plupart des décisions qui en découlent sont
juridiques. Je vois cinq raisons.

+ *Les délais d'annonce démarrent avec la détection du SOC.* En Suisse, la nLPD
  (art. 24) impose d'annoncer au PFPDT une violation de données à risque élevé
  dans les meilleurs délais. Depuis avril 2025, les exploitants
  d'infrastructures critiques doivent signaler une cyberattaque à l'OFCS dans
  les 24 heures. Pour des données de résidents de l'UE, le RGPD (art. 33) fixe
  72 heures. Le juridique décide si l'incident déclenche ces obligations, mais
  il ne peut le faire qu'avec les faits du SOC, et vite.
+ *Les preuves doivent tenir devant un juge.* Une plainte pénale ou une action
  contre un employé exige des preuves collectées sans altération, avec une
  chaîne de conservation documentée. Le juridique fixe ces exigences avant que
  le SOC ne touche aux systèmes, sinon l'investigation détruit la preuve.
+ *Surveiller, c'est traiter des données personnelles.* Les journaux contiennent
  des données d'employés. Le droit suisse interdit les systèmes destinés à
  surveiller le comportement des travailleurs (OLT 3, art. 26). Le juridique
  définit ce que le SOC peut collecter, combien de temps il le garde, et comment
  il enquête sur une menace interne sans violer le droit du travail.
+ *La réponse à une extorsion est une décision juridique.* Payer une rançon peut
  violer des sanctions internationales si le groupe est sanctionné. Vérifier une
  fuite revendiquée sur un site `.onion` pose aussi la question du droit
  d'accéder à des données volées. Le principe « bluff ou réalité » ne se tranche
  pas sans le juridique.
+ *Les contrats créent leurs propres obligations.* Clients, fournisseurs et
  assureur cyber imposent souvent des délais de notification et des conditions
  de couverture. Le juridique sait lesquels s'appliquent, le SOC sait ce qui
  s'est passé.

*En résumé :* la dépendance va dans les deux sens. Le juridique ne peut pas
qualifier un incident sans les faits du SOC, et le SOC ne peut pas agir sans
savoir ce qu'il a le droit de collecter, de conserver et d'annoncer. C'est
pourquoi le juridique figure dans les playbooks d'escalade, et pas seulement
après la crise.
