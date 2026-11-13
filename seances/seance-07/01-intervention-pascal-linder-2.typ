// Intervention spéciale - Pascal Linder 2, chargé de sécurité HE-Arc (8h15-9h).
#import "/template.typ": *

== Intervention spéciale : Pascal Linder 2

Pascal Linder, chargé de sécurité de la HE-Arc, revient sur l'intrusion de 2022
présentée en séance 03. Cette fois, il montre ce que l'école a changé depuis, et
comment elle a choisi son SOC.

=== Éléments essentiels

==== Le réseau avant 2022

- Deux réseaux : administratif et pédagogique.
- Serveur de messagerie interne, un pare-feu unique vers l'extérieur.
- Peu de cloisonnement à l'intérieur : une fois entré par le VPN, l'attaquant
  circulait librement d'un serveur à l'autre.

==== Le message de rançon

- Envoyé depuis une adresse ProtonMail, à plusieurs adresses de l'école pour
  être sûr qu'il soit lu.
- Menace : publier les données sur le blog du groupe, hébergé sur le dark
  web, en cas de non-paiement. C'est la double extorsion.

==== Le contexte de menace

Les attaques par exploitation de vulnérabilités augmentent chaque année. L'IA
accélère la découverte et l'exploitation des failles, ce qui réduit le délai
entre la publication d'une vulnérabilité et son exploitation.

==== Les sources de journaux

Chaque mesure opérationnelle produit des journaux exploitables : VPN, Entra ID,
MFA, EDR, PIM et le filtre DNS Cisco Umbrella. Le SIEM les centralise. Sans
cette collecte, aucune détection n'est possible.

==== Le réseau après 2022

- *Cloisonnement :* pare-feu de microsegmentation sur toute l'architecture.
- *Visibilité :* licence EDR étendue, tous les journaux remontent dans le SIEM
  et sont corrélés par le XDR.
- *Accès :* VPN limité par zone géographique, comptes à privilèges séparés,
  droits administrateur retirés des postes.
- *Exposition :* accès internet des serveurs limité, bandeau visuel sur les
  courriels externes, mises à jour plus fréquentes.
- *Humain :* sensibilisation générale et formations spécifiques.
- *SOC externe :* analyse des journaux 24/7, réaction rapide hors des heures de
  bureau, vue globale intégrée, expertise et amélioration continue.

==== Le choix du SOC

L'école suit une démarche d'achat public, pas un choix d'outil :

+ Inventaire de l'existant.
+ Liste des besoins.
+ Étude des solutions et constat des coûts.
+ Appel d'offres de marché public, avec besoins et contraintes.
+ Analyse des soumissionnaires.
+ Choix de Sophos, retenu pour ses nombreuses intégrations avec les services
  déjà en place.

==== L'amélioration continue

Depuis 2022, l'école applique la roue de Deming, Plan-Do-Check-Act, comme une
boucle sans fin. Exemples actuels :

- Tests d'intrusion, suivis des corrections.
- Audits.
- Exercices cyber, qui produisent des fiches réflexes.
- Débriefing après chaque cas.
- Analyse et correction de l'Active Directory avec l'outil Saporo.
- Conformité au NIST CSF.

=== Suite : que faut-il absolument réussir dans une entreprise pour progresser en cybersécurité ?

Après Pascal Linder 1, j'avais retenu trois conditions : savoir ce que l'on
protège, détecter tôt et rétablir vite, savoir dire ce que l'on ne sait pas. La
deuxième intervention montre comment l'école les a rendues durables. J'ajoute
trois conditions.

+ *Fermer la boucle :* une mesure non vérifiée se dégrade. L'école ne s'arrête
  pas aux mesures de 2022 : tests d'intrusion, audits et exercices vérifient
  qu'elles tiennent encore. C'est le PDCA, et c'est la condition qui rend les
  trois premières durables.
+ *Rendre la détection exploitable :* collecter des journaux ne suffit pas. Il
  faut quelqu'un pour les lire 24/7 et décider. Une école n'a pas cette équipe :
  elle achète un SOC externe. Savoir externaliser ce qu'on ne peut pas tenir en
  interne fait partie de la maturité.
+ *Partir des besoins, pas des outils :* le SOC a été choisi après inventaire,
  liste des besoins et appel d'offres. Le critère final, les intégrations avec
  l'existant, découle de l'inventaire. Un outil choisi sans cette étape ne voit
  qu'une partie du réseau.

*Ce que je critique :* la limitation géographique du VPN figure dans les mesures
après 2022, mais l'intervention 1 la disait retirée car trop contraignante. La
liste présentée mélange donc les mesures décidées et les mesures encore en
place. Un inventaire des mesures doit indiquer lesquelles sont actives, sinon il
donne une fausse impression de couverture.
