// Activité 5 - vocabulaire de base de la cybersécurité (partie après-midi).
#import "/template.typ": *

== Activité 5 : Définir le vocabulaire de base de la cybersécurité

#encadre("Objectifs")[
  - Extraire du glossaire Hucency les concepts que je ne connaissais pas encore.
  - Les résumer dans les grandes lignes.
  - Définir red team, blue team et purple team.
]

=== Métiers pertinents

- *RSSI :* arbitre le vocabulaire et les priorités.
- *SOC, blue team :* détectent et répondent aux incidents.
- *Red team :* simule l'attaquant en pentest.
- *CERT :* coordonne la réponse.
- *Développeur, admin :* appliquent les correctifs, contrôlent le Shadow IT.

=== Déroulement

- *Source principale :* #link("https://hucency.com/glossaire-de-la-cybersecurite/")[Hucency - Glossaire de la cybersécurité (55 définitions, sourcées ANSSI, CNIL, Cybermalveillance, ENISA)].
- *Méthode :* définitions reformulées dans les grandes lignes, pas recopiées.

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

Précision que je ne connaissais pas avant lecture, Emotet et Log4Shell montrent deux échelles :
- *Emotet :* menace persistante qui mute (botnet loué à d'autres attaquants).
- *Log4Shell :* faille supply chain, une seule bibliothèque omniprésente compromet tout l'écosystème.

==== Red team, blue team, purple team

#table(
  columns: (1fr, 2.5fr),
  [*Équipe*], [*Rôle*],
  [Red team], [Équipe offensive. Elle simule un attaquant réel : pentest, intrusion, phishing ciblé, élévation de privilèges. Son but est de prouver qu'une compromission est possible.],
  [Blue team], [Équipe défensive. Elle surveille (SOC, SIEM, EDR), durcit, détecte et répond aux incidents. Son but est d'empêcher la compromission ou de la contenir vite.],
  [Purple team], [Fonction de liaison, pas une troisième armée. Elle fait rejouer ensemble les scénarios de la red team à la blue team pour corriger les détections et valider les playbooks. Son but est l'apprentissage continu.],
)

Le cycle :
- *Red team :* attaque.
- *Blue team :* détecte et répond.
- *Purple team :* compare l'attaque aux alertes, ajuste les règles SIEM/EDR, rejoue le scénario jusqu'à détection fiable.

#align(center)[
  #diagram(
    spacing: (14mm, 12mm),
    node-inset: 8pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 1), [*Red team*], fill: fond-rouge),
    node((-1.2, -0.6), [*Blue team*], fill: white),
    node((1.2, -0.6), [*Purple team*], fill: white),
    node((0, -0.1), text(size: 9pt, fill: gray)[rejeu], stroke: none),
    edge((0, 1), (-1.2, -0.6), "->"),
    edge((-1.2, -0.6), (1.2, -0.6), "->"),
    edge((1.2, -0.6), (0, 1), "->"),
  )
]

=== Résultats

Les six termes se rangent en trois groupes, plus les équipes :
- *L'attaque :* APT, drive-by download, Emotet.
- *L'organisation de la défense :* le CERT collecte les signalements et coordonne la réponse.
- *Le terrain qui facilite l'attaque :* Log4Shell (dépendance omniprésente), Shadow IT (usages non contrôlés).
- *Qui fait quoi :* red, blue et purple team (attaquer, défendre, faire progresser les deux).

=== Interprétation des résultats

- *Défense en profondeur :* aucun acteur ne couvre seul la triade CIA.
  - Le CERT coordonne.
  - La blue team opère au quotidien.
  - La red team vérifie.
  - La purple team boucle l'amélioration.
- *Deux réflexes pour le projet de semestre :*
  - nommer chaque risque avec le bon terme (APT, drive-by, Shadow IT) ;
  - associer chaque mesure à son équipe (qui détecte, qui teste, qui corrige).
