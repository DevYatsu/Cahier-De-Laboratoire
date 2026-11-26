// Devoir « Réponse à incident et DRP » - 4 pages au total.
// Chaque page est une fiche autonome : on peut l'imprimer seule et l'utiliser pendant un incident.

// ================================================================ palette
#let accent = rgb("#E30613")       // rouge HE-Arc, réservé aux repères
#let encre  = rgb("#1f2328")
#let doux   = rgb("#6b7280")
#let trait  = rgb("#e5e7eb")
#let fond   = rgb("#f6f7f9")
#let vert   = rgb("#15803d")
#let bleu   = rgb("#1d4ed8")
#let orange = rgb("#c2410c")

// ================================================================ page et texte
#set document(title: "Réponse à incident et DRP", author: ("Yanis Amani", "Adam Belaziz"))
#set page(paper: "a4", margin: (x: 1.5cm, top: 1.3cm, bottom: 1.4cm),
  footer: context {
    set text(7pt, fill: doux)
    line(length: 100%, stroke: 0.4pt + trait)
    v(-0.5em)
    [Stack d'observabilité « drp » · HE-Arc 3275.1 · Y. Amani, A. Belaziz · Usage interne #h(1fr) #counter(page).display("1 / 1", both: true)]
  })
#set text(font: ("Helvetica Neue", "DejaVu Sans"), size: 8.6pt, fill: encre, lang: "fr")
#set par(justify: false, leading: 0.62em, spacing: 0.9em)
#set list(spacing: 0.6em, indent: 0.2em, marker: text(fill: accent)[•])
#set enum(spacing: 0.6em, indent: 0.2em, numbering: n => text(fill: accent, weight: "bold")[#n.])
#show strong: set text(weight: "bold")

// Code : police à chasse fixe, petit fond gris pour le repérer d'un coup d'œil.
#show raw: set text(font: ("JetBrainsMono NF", "DejaVu Sans Mono"), size: 7pt)
#show raw.where(block: false): it => box(fill: fond, inset: (x: 0.25em), outset: (y: 0.2em), radius: 2pt, it)
#show raw.where(block: true): it => block(width: 100%, fill: fond, inset: 0.45em, radius: 3pt, it)

// Titres de section dans une fiche : petit, rouge, filet fin.
#show heading.where(level: 2): it => block(above: 1.15em, below: 0.6em, width: 100%, {
  set text(9.5pt, weight: "bold")
  it.body
  v(-0.55em)
  line(length: 100%, stroke: 0.5pt + trait)
})

// Tableaux : pas de traits verticaux, en-tête souligné, lignes alternées.
#set table(stroke: (x, y) => (
    top: if y == 0 { none } else { 0.4pt + trait },
    bottom: if y == 0 { 0.8pt + encre } else { 0.4pt + trait },
  ),
  fill: (_, y) => if y > 0 and calc.even(y) { fond },
  inset: (x: 0.45em, y: 0.45em))
#show table.cell.where(y: 0): set text(7.4pt, weight: "bold", fill: doux)
#show table: set text(7.9pt)

// ================================================================ composants
#let ok = text(fill: vert, weight: "bold")[OK]

#let encadre(titre: none, couleur: accent, body) = block(width: 100%, breakable: false,
  stroke: (left: 2.5pt + couleur), fill: couleur.lighten(94%), inset: (x: 0.8em, y: 0.65em), radius: (right: 3pt))[
  #if titre != none [#text(fill: couleur, weight: "bold")[#titre] #v(0.1em)]
  #body]

#let badge(niveau) = {
  let c = (critique: accent, "élevée": orange, moyenne: rgb("#a16207"), faible: vert).at(niveau)
  box(fill: c.lighten(88%), inset: (x: 0.35em, y: 0.2em), radius: 2pt, text(7pt, fill: c, weight: "bold", niveau))
}

#let pastille(n) = box(width: 1.6em, height: 1.6em, radius: 50%, fill: accent,
  align(center + horizon, text(fill: white, weight: "bold", 8pt, str(n))))

// Une étape : pastille numérotée, titre, commande optionnelle, puis puces.
#let etape(n, titre, commande: none, body) = block(width: 100%, breakable: false, above: 0.8em, below: 0.8em,
  grid(columns: (1.6em, 1fr), column-gutter: 0.6em,
    pastille(n),
    {
      text(weight: "bold", titre)
      if commande != none { linebreak(); v(0.05em); commande }
      v(0.1em)
      body
    }))

// En-tête de fiche : référence, titre, objet, puis le cartouche de contrôle documentaire.
// Il rend chaque page lisible seule : on sait ce qu'elle couvre, qui l'applique et quand elle sert.
#let fiche(ref, titre, objet, declencheur: none, acteur: none) = {
  block(width: 100%, fill: fond, inset: (x: 0.9em, y: 0.75em), radius: 4pt, stroke: (left: 3pt + accent), {
    grid(columns: (auto, 1fr, auto), column-gutter: 0.8em, align: (horizon, horizon, right + horizon),
      box(fill: accent, inset: (x: 0.5em, y: 0.35em), radius: 3pt, text(fill: white, weight: "bold", 9pt, ref)),
      [#text(14pt, weight: "bold", titre) \ #v(-0.2em) #text(8pt, fill: doux, objet)],
      text(7.2pt, fill: doux)[Version 1.0 · 13.11.2026 \ Prochaine revue : 13.12.2026 \ *Usage interne*],
    )
    if declencheur != none or acteur != none {
      v(0.25em)
      line(length: 100%, stroke: 0.4pt + trait)
      v(-0.35em)
      set text(7.8pt)
      grid(columns: (1fr, 1fr), column-gutter: 1em,
        [#text(fill: doux, weight: "bold")[QUAND L'UTILISER] \ #declencheur],
        [#text(fill: doux, weight: "bold")[QUI L'APPLIQUE] \ #acteur])
    }
  })
  v(0.2em)
}

// ================================================================ page 1 : playbook
// Bandeau du devoir : les noms doivent figurer en tête du PDF.
#grid(columns: (1fr, auto), align: (left + bottom, right + bottom),
  [#text(13pt, weight: "bold")[Réponse à incident et DRP] #h(0.4em) #text(8pt, fill: doux)[stack d'observabilité « drp » · HE-Arc 3275.1]],
  text(10pt, weight: "bold")[Yanis Amani · Adam Belaziz])
#v(-0.5em)
#line(length: 100%, stroke: 1pt + accent)
#v(-0.2em)
#fiche("PB-01", "Playbook : brute-force sur le login",
  "Juice Shop et Authelia, exposés par Traefik (seul port publié, TLS, logs d'accès JSON collectés par Alloy vers Loki).",
  declencheur: [E-mail `[FIRING] BruteForceLogin` ou `BruteForceSSO` reçu par la boîte de l'astreinte.],
  acteur: [L'astreinte, avec Grafana (Explore, source Loki). Escalade : RSSI, puis direction.])

#etape(1, "Qualifier l'alerte et fixer la gravité")[
- *`BruteForceLogin`* : plus de 10 réponses `401` sur `/rest/user/login` en 1 min pour une même `ClientHost` (ruler de Loki).
- *`BruteForceSSO`* : plus de 5 échecs Authelia en 5 min.
- #badge("faible") *G1* : des échecs seulement. #h(0.6em) #badge("élevée") *G2* : un `200` sur le login juste après les échecs, donc un compte peut-être compromis.
- #badge("critique") *G3* : G2 sur un compte administrateur, ou collecte coupée pendant l'attaque (`LogsAbsents`, `CibleInjoignable{job="alloy"}`).
]

#etape(2, "Rôles et escalade")[
- *Astreinte* (nommée, reçoit l'e-mail) : accuse réception en 15 min. Sans réponse, le *suppléant* prend le relais.
- *Liste d'astreinte* : imprimée et dans les téléphones, donc hors du système attaqué.
- *Escalade* : au RSSI dès G2, à la direction dès G3. La direction décide, par exemple de couper le service.
]

#etape(3, "Vérifier : requêtes prêtes à copier")[
- *Quelle source attaque ?*
  ```
  sum by (ClientHost) (count_over_time({container="traefik"} | json | RequestPath="/rest/user/login" | DownstreamStatus="401" [15m]))
  ```
- *Un login a-t-il réussi ? (G2)* #h(0.3em) `{container="traefik"} | json | RequestPath="/rest/user/login" | DownstreamStatus="200"`
- *Qu'a fait la source ?*
  ```
  {container="traefik"} | json | ClientHost="<ip>" | line_format "{{.RequestMethod}} {{.RequestPath}} {{.DownstreamStatus}}"
  ```
- *Le SSO est-il visé ?* #h(0.3em) `{container="authelia"} |= "Unsuccessful 1FA authentication attempt"`
- *La collecte tient-elle ?* (Prometheus) #h(0.3em) `up{job="alloy"}`, `sum(rate(loki_distributor_lines_received_total[5m]))`. Plus aucun log n'est pas la fin de l'attaque : collecte arrêtée, ou coupée par l'attaquant #sym.arrow G3.
- *Faux positif possible* : un test oublié, ou un utilisateur qui a perdu son mot de passe (une source, peu d'essais).
]

#etape(4, "Contenir sans éteindre, préserver les preuves, éradiquer")[
- *Bloquer la source* : middleware `ipAllowList` inversé dans `traefik/dynamic/`, rechargé à chaud. Durcir `rate-limit`.
- *En G2* : désactiver le compte Juice Shop et invalider ses sessions. *Couper Juice Shop* reste une décision de la direction.
- *Preuves* : exporter les résultats (UTC), calculer leur SHA-256, noter qui a fait quoi et quand. Si Loki est altéré, la copie WORM du bucket `logs` fait foi.
- *Éradiquer* (après confinement, pour ne pas alerter l'attaquant) : réinitialiser le mot de passe, révoquer les sessions, défaire ce que la source a créé ou modifié (requête « Qu'a fait la source ? »).
]

#etape(5, "Communiquer")[
- *En interne* : RSSI, direction, juriste. Chaque décision est écrite avec l'heure.
- *Données personnelles exposées (G2)* : annonce au PFPDT dans les meilleurs délais si le risque est élevé (nLPD art. 24).
- *Infrastructure critique* : annonce à l'OFCS sous 24 h (LSI). *Utilisateurs touchés* : réinitialisation, messages approuvés.
]

#etape(6, "Clore et tirer les leçons")[
- *Fin* : source bloquée, 30 min sans tentative, comptes réinitialisés, aucune session de l'attaquant active.
- *Retour d'expérience sans coupable* sous 5 jours ouvrés ; chaque action a un responsable et une échéance.
]

#encadre(titre: "Testé le 13.11.2026", couleur: vert)[
#grid(columns: (1fr, 1fr, 1fr), column-gutter: 0.8em,
  [*14:59:30 UTC* \ 20 logins faux envoyés.],
  [*+26 s* \ Alerte active dans Alertmanager.],
  [*+52 s* \ E-mail `[FIRING:1] BruteForceLogin` reçu.],
)
#v(0.1em)
#text(7.6pt, fill: doux)[Journal `6-test-alerte-brute-force.log`. La `ClientHost` vue est `192.168.127.1`, la passerelle de Podman machine : dans le labo, bloquer la source bloquerait tout le monde (voir LIM-01).]
]

// ================================================================ page 2 : DRP, préparation
#pagebreak()
#fiche("DRP-01 A", "Plan de reprise : inventaire, objectifs, sauvegarde",
  "Ce qu'il faut protéger, combien de perte et d'arrêt on accepte, et comment la sauvegarde tient ces objectifs.",
  declencheur: [À relire avant chaque test mensuel et à chaque ajout de service ou de volume. La procédure de reprise est la fiche DRP-01 B.],
  acteur: [Propriétaires du stack (rédaction, revue). Validation des objectifs : direction.])

== Inventaire et impact
#text(7.6pt, fill: doux)[Stack : 11 conteneurs (dossier `stack/`). Hors du stack, projet et comptes séparés : copie WORM RustFS, heartbeat externe, boîte de l'astreinte.]
#v(-0.2em)
#table(columns: (4.3cm, 1fr, 1.45cm, 1.75cm, 2.7cm),
  [Élément · emplacement], [Impact si on le perd], [Gravité], [RPO], [Restauré depuis],
  [*Secrets* : clés des 3 CA, clé de chiffrement Authelia, comptes · `secrets/`, `.env`, hors git], [Base Authelia illisible ; tous les certificats mTLS à refaire.], badge("critique"), [24 h], [archive chiffrée, WORM],
  [*Kit hors ligne* : clé privée `age`, accès au WORM · hors du poste], [Toutes les sauvegardes illisibles. Irrécupérable.], badge("critique"), [aucune perte admise], [copie physique],
  [`loki-data` : logs (30 j, sécurité 180 j) · volume], [Les preuves d'un incident disparaissent.], badge("critique"), [1 min (preuves) \ 24 h (Loki)], [bucket WORM `logs` \ archive de nuit],
  [`authelia-data` : TOTP, bannissements · volume], [Chaque utilisateur réenrôle son second facteur.], badge("élevée"), [24 h], [archive de nuit],
  [`grafana-data` : comptes, dashboards faits à la main · volume], [Dashboards d'enquête perdus.], badge("moyenne"), [24 h], [archive de nuit],
  [Images des conteneurs (4,3 Go) · registres publics], [Reprise retardée ; une image peut disparaître (vécu avec MinIO).], badge("moyenne"), [sans objet], [registres],
  [`alertmanager-`, `prometheus-`, `alloy-data` · volumes], [Silences, historique des métriques ; quelques logs en double.], badge("faible"), [24 h], [archive de nuit],
  [Configurations, règles, dashboards provisionnés · git], [Aucun : tout se reconstruit.], badge("faible"), [dernier commit], [dépôt git],
)

== Objectifs de reprise et justification
#table(columns: (2.4cm, 1.3cm, 1fr, 2.6cm),
  [Objectif], [Valeur], [Pourquoi cette valeur], [Tenu par],
  [*MTD* \ arrêt max. tolérable], [*24 h*], [Sans le stack, aucun incident n'est détecté ni documenté. Or une cyberattaque sur une infrastructure critique doit être annoncée à l'OFCS sous 24 h (LSI).], [RTO bien inférieur],
  [*RTO* \ délai de reprise], [*1 h*], [Doit rester très en dessous du MTD : il reste 23 h pour enquêter et annoncer. Une heure couvre le pire cas prévu : poste neuf, 4,3 Go d'images à télécharger.], [*mesuré : 70 s* (poste existant)],
  [*RPO logs* \ perte de données], [*1 min*], [Les logs sont les preuves. Un brute-force dure quelques minutes : perdre plus d'une minute peut effacer toute l'attaque.], [Alloy, lots de 60 s vers le WORM],
  [*RPO volumes*], [*24 h*], [Dashboards, comptes et TOTP changent peu : une journée perdue coûte au pire un réenrôlement TOTP. Sauvegarder plus souvent rendrait le stack aveugle 15 s à chaque fois.], [sauvegarde de nuit],
)

== Stratégie de sauvegarde
#grid(columns: (1fr, 1fr), column-gutter: 1.1em,
[
- *Quoi* : les 6 volumes, plus `secrets/` et `.env`. Sans eux, les données seules ne redémarrent rien. Images et configurations viennent des registres et de git.
- *Quand* : chaque nuit à 03:00, `scripts/sauvegarder.sh`.
- *Cohérence* : stack arrêté pendant l'export (bases SQLite et TSDB figées). Coût : *15 s* sans détection.
- *Conservation* : 30 jours (sauvegardes), 365 jours (logs) ; 1 jour dans le labo.
- *Test* : une restauration chronométrée par mois ; un échec est un incident.
],
[
- *Règle 3-2-1* : 3 copies, 2 supports, 1 hors du stack :
  + les volumes en service ;
  + les archives du poste (`sauvegardes/`) ;
  + le bucket *WORM* (« write once, read many », Object Lock en mode compliance) : personne ne l'efface avant la fin de la rétention, pas même l'administrateur (testé : `AccessDenied`).
- *Chiffrement* : `age`. Le poste n'a que la clé *publique* : le voler ne permet pas de lire les sauvegardes.
- *Intégrité* : une empreinte SHA-256 par fichier, vérifiée avant toute restauration.
],
)

// ================================================================ page 3 : DRP, restauration
#pagebreak()
#fiche("DRP-01 B", "Plan de reprise : restaurer le service",
  "Passer de « le stack ne marche plus » à « service rétabli et vérifié », sans autre aide que cette fiche.",
  declencheur: [Volumes perdus ou corrompus, disque du poste perdu, rançongiciel. Après une intrusion : seulement une fois l'attaquant chassé (PB-01).],
  acteur: [L'astreinte, seule. Elle prévient le RSSI au début et à la fin de la reprise.])

#encadre(titre: "Avant de commencer : 3 prérequis", couleur: bleu)[
#grid(columns: (1fr, 1fr, 1fr), column-gutter: 0.8em,
  [☐ Un poste avec *Podman* et le *dépôt git* cloné.],
  [☐ Le *kit hors ligne* dans `~/.config/drp/` (ou `DRP_KIT=<chemin>`).],
  [☐ La *copie WORM* joignable (projet `hors-stack` démarré).],
)
#v(0.1em)
#text(7.6pt)[*Choisir la sauvegarde* : la dernière par défaut. Après une compromission, prendre la dernière *antérieure* à la première trace de l'attaquant, sinon on restaure aussi sa porte dérobée.]
]

== Procédure
#etape(1, "Lancer la restauration", commande: [`scripts/restaurer.sh` #h(0.3em) (dernière sauvegarde) #h(0.3em) ou #h(0.3em) `scripts/restaurer.sh <ID>`])[
- Le script lit la sauvegarde *dans le WORM*, jamais sur le disque local : celui-ci peut être perdu ou piégé.
]
#etape(2, "Le script vérifie avant de toucher à quoi que ce soit")[
- Il contrôle les empreintes SHA-256, puis teste le déchiffrement.
- *S'il affiche « ARRÊT »* : ne rien forcer. Relancer avec l'`<ID>` de la sauvegarde précédente.
]
#etape(3, "Il remet les secrets, puis recrée des volumes vides")[
- `secrets/` et `.env` sont restaurés seulement s'ils manquent.
- Un premier `podman compose up`, puis `stop`, crée les volumes avec les bons propriétaires (sinon Grafana refuse de démarrer).
]
#etape(4, "Il vide puis remplit chaque volume", commande: [`age -d … | gunzip | podman volume import drp_<volume> -`])[
- Le vidage est obligatoire : `import` *fusionne*, et les fichiers du premier démarrage se mêleraient aux données restaurées.
]
#etape(5, "Il redémarre et vérifie de bout en bout", commande: [`scripts/verifier.sh`])[
- *Succès* : la dernière ligne affiche « SERVICE RÉTABLI ET VÉRIFIÉ » et le RTO mesuré. La reprise est close.
- *Échec* : « la restauration n'est PAS réussie » #sym.arrow traiter comme un incident et prévenir le RSSI.
]

== En cas de problème
#table(columns: (5.2cm, 1fr),
  [Symptôme], [Action],
  [« ARRÊT » : empreinte ou déchiffrement refusé], [Sauvegarde altérée. Relancer avec l'`<ID>` précédent ; signaler l'altération au RSSI.],
  [WORM injoignable], [Démarrer le projet `hors-stack`. Ne pas restaurer depuis `sauvegardes/` local sans accord du RSSI.],
  [Kit hors ligne perdu], [Les sauvegardes sont illisibles. Repartir à vide avec `init-secrets.sh` : données perdues, TOTP à réenrôler.],
  [Une vérification échoue], [Ne pas déclarer le service rétabli. Garder le journal du script, escalader au RSSI.],
)

== Restauration testée le 13.11.2026
#block(breakable: false, grid(columns: (1.25fr, 1fr), column-gutter: 1.1em,
[
#text(7.6pt, fill: doux)[Journaux dans `stack/journaux/`, numérotés 0 à 5.]
+ *Témoins* : une donnée marquée par volume (dashboard, log, instant Prometheus, silence, empreinte des TOTP).
+ *Sauvegarde* : 9 fichiers, 177 Mo, copiés dans le WORM, relus *avant* le sinistre.
+ *Sinistre* (14:57:58 UTC) : `podman compose down -v`, puis suppression de `secrets/`, `.env` et des sauvegardes locales. Restent le dépôt, le kit et le WORM.
+ *Restauration* : `scripts/restaurer.sh`, sans intervention.
+ *Résultat* : *14 vérifications sur 14* #ok : 11 conteneurs, SSO, témoins retrouvés, nouveaux logs collectés, 9 cibles Prometheus sur 9, TOTP identiques, heartbeat reçu.
],
[
#table(columns: (1fr, auto),
  [Étape], [Temps],
  [Téléchargement WORM (171 Mo), vérifications], [2 s],
  [Secrets, premier démarrage puis arrêt], [12 s],
  [Import des 6 volumes], [7 s],
  [Redémarrage], [2 s],
  [Vérifications jusqu'au service rétabli], [49 s],
  table.cell(fill: accent.lighten(90%))[*RTO mesuré* (objectif 1 h)], table.cell(fill: accent.lighten(90%))[#text(fill: accent)[*70 s*]],
)],
))

// ================================================================ page 4 : limites
#pagebreak()
#fiche("LIM-01", "Limites : ce que ce plan ne couvre pas",
  "Les risques que PB-01 et DRP-01 laissent ouverts, ce qu'ils coûteraient, et ce qu'il faudrait en production.")

#let groupe(t) = table.cell(colspan: 3, fill: fond, text(7.4pt, weight: "bold", fill: accent, upper(t)))
#table(columns: (3.9cm, 1fr, 4.6cm),
  [Limite], [Conséquence], [En production],
  groupe("Sinistres hors périmètre"),
  [*Perte de l'hôte*], [L'hôte emporte WORM, heartbeat et astreinte ; il ne reste que git et le kit hors ligne. Aucune preuve ni alerte n'est alors disponible.], [Copie chez un autre fournisseur, sur un autre site.],
  [*Compromission ancienne*], [La restauration remettrait aussi une porte dérobée ; aucune sauvegarde antérieure n'est conservée pour comparer.], [Rétention 30 jours ; analyse de la sauvegarde avant usage.],
  [*Continuité (pas de PCA)*], [Pendant les 15 s de sauvegarde et toute la reprise, aucune détection ni service ne fonctionne.], [Instance de secours ou réplication.],
  [*Perte du kit hors ligne*], [Toutes les sauvegardes deviennent illisibles ; reprise à vide avec perte des données et TOTP.], [Deux copies du kit, en deux lieux.],
  groupe("Non testé ou non prouvé"),
  [*RTO sur poste neuf*], [Le RTO réel peut dépasser 70 s ; l'objectif d'1 h n'est pas prouvé sur poste vierge.], [Exercice annuel sur un poste vierge.],
  [*Corruption silencieuse*], [Des données peuvent manquer ou être corrompues sans que les témoins ne le montrent.], [Contrôles d'intégrité par application.],
  [*Communication*], [Les annonces légales et l'escalade n'ont jamais été exercées ; risque de retard ou d'erreur.], [Exercice sur table avec la direction.],
  groupe("Écarts du labo"),
  [*Source invisible*], [Bloquer la source vue par Traefik bloquerait tous les utilisateurs du labo.], [Proxy protocol, ou hôte Linux.],
  [*Un seul compte S3*], [Alloy et `scripts/sauvegarder.sh` utilisent le même compte racine RustFS : une clé volée donne accès aux buckets `logs` et `sauvegardes`.], [Un compte en écriture seule par usage.],
  [*Composants jeunes*], [RustFS et la sortie S3 d'Alloy peuvent casser la collecte ou le WORM sans prévenir.], [Stockage objet éprouvé.],
  [*Écarts au schéma*], [Le trafic interne reste en clair et l'entrée utilise 8443, donc l'architecture réelle diffère du schéma.], [TLS de bout en bout, port 443.],
)

