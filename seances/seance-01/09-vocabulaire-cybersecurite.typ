// Activité 5 - vocabulaire de base de la cybersécurité (partie après-midi).
#import "/template.typ": *

== Activité 5 : Définir le vocabulaire de base de la cybersécurité
#text(size: 0.9em, fill: gray)[Partie après-midi · activité 5]

#encadre("Objectifs")[Extraire du glossaire Hucency les concepts que je ne connaissais pas encore et les résumer dans les grandes lignes. Définir ensuite red team, blue team et purple team.]

=== Métiers pertinents

Le RSSI arbitre le vocabulaire et les priorités. Le SOC et la blue team détectent et répondent aux incidents. La red team simule l'attaquant en pentest. Le CERT coordonne la réponse. Le dev et l'admin appliquent les correctifs et contrôlent le Shadow IT.

=== Déroulement

Source principale : #link("https://hucency.com/glossaire-de-la-cybersecurite/")[Hucency - Glossaire de la cybersécurité (55 définitions, sourcées ANSSI, CNIL, Cybermalveillance, ENISA)]. Les définitions ci-dessous sont reformulées dans les grandes lignes, pas recopiées.

==== Six concepts extraits du glossaire

#table(
  columns: (1.1fr, 2.5fr),
  [*Terme*], [*Définition (dans les grandes lignes)*],
  [APT (Advanced Persistent Threat)], [Attaque sophistiquée et furtive qui dure dans le temps. Un groupe structuré, souvent soutenu par un État, s'installe dans le système visé pour espionner, saboter ou voler de la propriété intellectuelle.],
  [CERT (Computer Emergency Response Team)], [Centre d'alerte et de réaction aux incidents. Il collecte les signalements, analyse les menaces et coordonne la réponse. En France, le CERT-FR est opéré par l'ANSSI.],
  [Drive-by download], [Infection sans action de l'utilisateur. La simple visite d'une page compromise suffit : une vulnérabilité du navigateur ou d'un plugin installe le malware à son insu.],
  [Emotet], [Trojan bancaire devenu une plateforme de distribution. Il volait des identifiants puis livrait d'autres malwares, dont des rançongiciels. Il compte parmi les malwares les plus destructeurs.],
  [Log4Shell], [Faille critique CVE-2021-44228 de la bibliothèque Apache Log4j, révélée en décembre 2021. Elle permet une exécution de code à distance et a exposé des millions de systèmes.],
  [Shadow IT], [Usages sans aval de la DSI : SaaS, cloud, applis ou appareils perso utilisés par les collaborateurs. Il crée des angles morts, complique la surveillance et augmente le risque de fuite.],
)

Précision que je ne connaissais pas avant lecture :

- *Emotet et Log4Shell montrent deux échelles.* Emotet illustre la menace persistante qui mute (botnet loué à d'autres attaquants). Log4Shell illustre la faille supply chain : une seule bibliothèque omniprésente compromet tout l'écosystème.

==== Red team, blue team, purple team

#table(
  columns: (1fr, 2.5fr),
  [*Équipe*], [*Rôle*],
  [Red team], [Équipe offensive. Elle simule un attaquant réel : pentest, intrusion, phishing ciblé, élévation de privilèges. Son but est de prouver qu'une compromission est possible.],
  [Blue team], [Équipe défensive. Elle surveille (SOC, SIEM, EDR), durcit, détecte et répond aux incidents. Son but est d'empêcher la compromission ou de la contenir vite.],
  [Purple team], [Fonction de liaison, pas une troisième armée. Elle fait rejouer ensemble les scénarios de la red team à la blue team pour corriger les détections et valider les playbooks. Son but est l'apprentissage continu.],
)

Le cycle est simple. La red team attaque. La blue team détecte et répond. La purple team compare l'attaque aux alertes, ajuste les règles SIEM/EDR, puis rejoue le scénario jusqu'à détection fiable.

=== Résultats

Les six termes du glossaire se rangent en trois groupes. APT, drive-by download et Emotet décrivent l'attaque. Le CERT décrit l'organisation de la défense : il collecte les signalements et coordonne la réponse. Log4Shell et Shadow IT décrivent le terrain qui facilite l'attaque : une dépendance omniprésente ou des usages non contrôlés. Red, blue et purple team décrivent qui fait quoi : attaquer, défendre, faire progresser les deux.

=== Interprétation des résultats

Le vocabulaire révèle une logique de défense en profondeur. Aucun acteur ne couvre tout seul la triade CIA. Le CERT coordonne, la blue team opère au quotidien, la red team vérifie, la purple team boucle l'amélioration. Pour mon projet de semestre, j'en retiens deux réflexes : nommer chaque risque avec le bon terme (APT, drive-by, Shadow IT) et associer chaque mesure à son équipe (qui détecte, qui teste, qui corrige).
