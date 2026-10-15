// Activité 10 - ce qui alimente la veille cybersécurité et technologique.
#import "/template.typ": *

== Activité 10 : Qu'est-ce qui alimente la veille cybersécurité et technologique ?

#encadre("Objectifs")[
  - Distinguer les canaux (comment on capte) des sources (ce qui fait autorité).
  - Montrer que les signaux rapides (réseaux sociaux, forums, fuites) ne deviennent de la veille qu'après validation et exploitation.
  - Relier chaque aliment à une décision : Identifier / Détecter vers SoA et playbook (prépare l'activité 11).
]

=== Métiers pertinents

- *Analyste CTI / SOC :* capte, trie et recoupe les signaux.
- *RSSI / risk manager :* arbitre ce qui entre dans la SoA et les priorités C/I/A.
- *Admin / développeur :* applique le correctif issu de la veille.
- *DPO :* suit les fuites et la notification en cas de données exposées.
- *Auditeur :* vérifie que la veille est tracée et rejouable.

=== Déroulement

- *Posture :* partir de ma pratique réelle (réseaux, blogs) puis confronter aux exigences d'une veille défendable.
- *Deux temps imposés par la question :*
  - d'abord les canaux : où je croise l'info ;
  - ensuite les sources : ce qui permet de la valider et de l'exploiter.

==== 1. Les canaux : comment l'info arrive

- *Réseaux sociaux et blogs :* X/Twitter, YouTube, LinkedIn, Reddit, Hacker News, blogs techniques et newsletters.
  - Atout : vitesse, signaux faibles (0-day, PoC, retour d'outil).
  - Limite : bruit, rumeurs, manipulations ; aucune autorité seule.
- *Forums cyber et zones de fuites :* forums spécialisés, leak sites et pages de rançongiciels (DLS), places de revente de bases.
  - Atout : exposition réelle (victimes citées, bases en circulation, TTP du moment).
  - Limite : accès borderline, faux et intoxications, cadre légal suisse à respecter.
  - Règle : ne pas y aller seul ; passer par relais (OFCS, fournisseur CTI, SOC).
- *Collectif et direct :* communautés, conférences, intervenants (ex. séance 03), échanges entre pairs, retours d'incidents internes.
  - Atout : contexte et validation par l'expérience.

Sans filtre, ces canaux informent mais ne protègent pas : ils surchargent (biais d'alerte, activité 4).

==== 2. Les sources : ce qui valide et rend exploitable

- *Institutionnel :* OFCS/BACS, CISA, ANSSI, Cybermalveillance.gouv.fr — doctrine, réflexes, ne pas payer, notification.
- *Technique et vulnérabilités :* CVE/NVD, bulletins éditeurs, correctifs et durcissements.
- *Renseignement structuré :* IoC, TTP, rapports CTI et CERT, filtres SOC.
- *Interne :* journaux, alertes hiérarchisées, post-mortems sans blâme, résultats de pentests et d'audits.
- *Normatif et techno :* ISO 27001, NIST CSF 2.0, évolutions DevSecOps, chiffrement, IA.

#table(
  columns: (1fr, 1.6fr, 1.4fr),
  [*Canal rapide*], [*Source qui valide*], [*Décision alimentée*],
  [Post X / Hacker News sur faille], [CVE/NVD + bulletin éditeur], [Patch priorisé selon C/I/A, tracé en SoA.],
  [Vidéo YT sur nouvel outil d'attaque], [Rapport CTI / OFCS], [Règle de détection, test des protections.],
  [Rumeur de fuite sur forum], [Fournisseur CTI / OFCS, vérification d'exposition], [Blocage d'IoC, notification PFPDT si avéré.],
)

Ordre imposé : capter vite, recouper, puis seulement verser au plan d'action.

=== Résultats

- *Canaux identifiés :* sociaux et blogs pour la vitesse, forums et fuites pour l'exposition, collectif pour le contexte.
- *Sources d'autorité :* institutionnel, CVE/éditeurs, CTI structuré, interne, normatif.
- *Règle de passage :* aucun signal brut ne déclenche seul ; il faut recoupement puis rattachement à un actif C/I/A et à une fonction Identifier / Détecter.
- *Trois cas tracés :* patch priorisé, détection ajoutée, fuite vérifiée et notifiée.

=== Interprétation des résultats

- *S'informer n'est pas faire de la veille :* la veille commence au tri (faux positifs écartés), à la validation (deux sources indépendantes) et à la traçabilité (SoA, playbook).
- *Défense en profondeur (activité 2) :* chaque aliment couvre un angle mort des autres ; les canaux rapides rattrapent la lenteur institutionnelle, l'institutionnel rattrape le bruit des canaux.
- *Facteur humain (activité 4) :* alertes hiérarchisées, procédures écrites et post-mortems rendent le flux tenable.
- *Vers l'activité 11 :* cette chaîne capter → valider → décider est l'entrée du schéma conception et opération de la sécurité.
- *Effet :* un flux subi devient une posture pilotée, défendable devant la direction et l'auditeur.

=== Références

- #link("https://www.cve.org")[CVE Program et NVD : vulnérabilités et scores]
- #link("https://news.ycombinator.com")[Hacker News : signaux techniques rapides, à recouper]
