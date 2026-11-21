// Devoir « Réponse à incident et DRP » - 4 pages au plus, puis l'annexe (usage de l'IA).

// ================================================================ palette
#let accent = rgb("#E30613")       // rouge HE-Arc, réservé aux repères
#let encre  = rgb("#1f2328")
#let doux   = rgb("#6b7280")
#let trait  = rgb("#e5e7eb")
#let fond   = rgb("#f6f7f9")
#let vert   = rgb("#15803d")
#let bleu   = rgb("#1d4ed8")

// ================================================================ page et texte
#set document(title: "Réponse à incident et DRP", author: ("Yanis Amani", "Adam Belaziz"))
#set page(paper: "a4", margin: (x: 1.6cm, top: 1.5cm, bottom: 1.6cm),
  footer: context {
    set text(7.5pt, fill: doux)
    line(length: 100%, stroke: 0.4pt + trait)
    v(-0.4em)
    [Réponse à incident et DRP · 3275.1 #h(1fr) #counter(page).display("1 / 1", both: true)]
  })
#set text(font: ("Helvetica Neue", "DejaVu Sans"), size: 9pt, fill: encre, lang: "fr")
#set par(justify: false, leading: 0.7em, spacing: 1.1em)
#set list(spacing: 0.75em, indent: 0.2em, marker: text(fill: accent)[•])
#set enum(spacing: 0.75em, indent: 0.2em, numbering: n => text(fill: accent, weight: "bold")[#n.])
#show strong: set text(weight: "bold")

// Code : police à chasse fixe, petit fond gris pour le repérer d'un coup d'œil.
#show raw: set text(font: ("JetBrainsMono NF", "DejaVu Sans Mono"), size: 7.4pt)
#show raw.where(block: false): it => box(fill: fond, inset: (x: 0.25em), outset: (y: 0.2em), radius: 2pt, it)
#show raw.where(block: true): it => block(width: 100%, fill: fond, inset: 0.5em, radius: 3pt, it)

// Titres : numéro en pastille rouge, filet fin dessous.
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => block(above: 2em, below: 1em, width: 100%, {
  set text(13pt, weight: "bold")
  if it.numbering != none {
    box(fill: accent, inset: (x: 0.4em, y: 0.25em), radius: 3pt, text(fill: white, 10pt, counter(heading).display("1")))
    h(0.5em)
  }
  it.body
  v(-0.2em)
  line(length: 100%, stroke: 0.6pt + trait)
})
#show heading.where(level: 2): it => block(above: 1.6em, below: 0.8em, {
  set text(10pt, weight: "bold")
  if it.numbering != none { text(fill: accent, counter(heading).display("1.1")); h(0.5em) }
  it.body
})

// Tableaux : pas de traits verticaux, en-tête souligné, lignes alternées.
#set table(stroke: (x, y) => (
    top: if y == 0 { none } else { 0.4pt + trait },
    bottom: if y == 0 { 0.8pt + encre } else { 0.4pt + trait },
  ),
  fill: (_, y) => if y > 0 and calc.even(y) { fond },
  inset: (x: 0.6em, y: 0.6em))
#show table.cell.where(y: 0): set text(8pt, weight: "bold", fill: doux)

// ================================================================ composants
#let ok = text(fill: vert, weight: "bold")[OK]

#let encadre(titre: none, couleur: accent, body) = block(width: 100%, breakable: false,
  stroke: (left: 2.5pt + couleur), fill: couleur.lighten(94%), inset: (x: 0.9em, y: 0.8em), radius: (right: 3pt))[
  #if titre != none [#text(fill: couleur, weight: "bold")[#titre] #v(0.2em)]
  #body]

#let badge(niveau) = {
  let c = (critique: accent, "élevée": rgb("#c2410c"), moyenne: rgb("#a16207"), faible: vert).at(niveau)
  box(fill: c.lighten(88%), inset: (x: 0.4em, y: 0.22em), radius: 2pt, text(7.4pt, fill: c, weight: "bold", niveau))
}

#let chiffre(label, valeur, body) = block(width: 100%, stroke: 0.5pt + trait, inset: 0.7em, radius: 4pt)[
  #text(7.2pt, fill: doux, weight: "bold", tracking: 0.04em, upper(label)) \
  #v(-0.1em)
  #text(18pt, fill: accent, weight: "bold", valeur)
  #v(-0.3em)
  #set text(8.2pt); #body]

#let pastille(n) = box(width: 1.7em, height: 1.7em, radius: 50%, fill: accent,
  align(center + horizon, text(fill: white, weight: "bold", 8.5pt, str(n))))

// Une étape : pastille numérotée, titre, commande optionnelle, puis puces.
#let etape(n, titre, commande: none, body) = block(width: 100%, breakable: false, above: 1.1em, below: 1.1em,
  grid(columns: (1.7em, 1fr), column-gutter: 0.7em,
    pastille(n),
    {
      text(weight: "bold", titre)
      if commande != none { linebreak(); v(0.1em); commande }
      v(0.15em)
      body
    }))

// ================================================================ en-tête
#block(width: 100%, fill: fond, inset: (x: 1em, y: 0.9em), radius: 4pt, stroke: (left: 3pt + accent))[
  #grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
    [#text(18pt, weight: "bold")[Réponse à incident et DRP] \
     #v(0.1em)
     #text(9pt, fill: doux)[Stack d'observabilité « drp » · architecture du rapport (`architecture.mmd`)]],
    [#text(9pt, weight: "bold")[Yanis Amani · Adam Belaziz] \
     #text(8pt, fill: doux)[HE-Arc · 3275.1 · 13.11.2026]])
]

#v(0.4em)
#grid(columns: (1fr, 1fr), column-gutter: 1.2em,
[
*Le stack* (dossier `stack/`, 11 conteneurs)
- *Traefik* : seul port publié (TLS, limitation de débit, logs d'accès JSON).
- *Authelia* : connexion unique (SSO) devant chaque service.
- *Réseaux privés* : un par backend ; Prometheus et Alertmanager sur un réseau de supervision.
- *Loki* : joignable seulement par un second Traefik en mTLS (une CA pour écrire, une pour lire).
- *Socket Podman* : filtré, lecture seule (GET).
],
[
*Hors du stack* (projet séparé, autres comptes, 3 conteneurs)
- *Copie WORM* : stockage RustFS inaltérable (Object Lock, mode compliance).
- *Heartbeat externe* : signale si le stack se tait.
- *Boîte de l'astreinte* : reçoit les alertes par e-mail.
],
)

// ================================================================ 1. Playbook
= Playbook PB-01 : brute-force sur le login

#etape(1, "Déclencheur et gravité")[
- *Alerte `BruteForceLogin`* : plus de 10 réponses `401` sur `/rest/user/login` en 1 min, pour une même `ClientHost` (logs Traefik, ruler de Loki).
- *Alerte sœur `BruteForceSSO`* : plus de 5 échecs Authelia en 5 min.
- #badge("faible") *G1* : des échecs seulement.
- #badge("élevée") *G2* : un `200` sur le login juste après les échecs : un compte est peut-être compromis.
- #badge("critique") *G3* : G2 sur un compte administrateur, ou collecte coupée pendant l'attaque (`LogsAbsents`, `CibleInjoignable{job="alloy"}`).
]

#etape(2, "Qui fait quoi")[
- *Astreinte* (nommée, reçoit l'e-mail) : accuse réception en 15 min. Sinon, le *suppléant* prend le relais.
- *Liste d'astreinte* : imprimée et dans les téléphones, donc hors du système attaqué.
- *Escalade* : au RSSI dès G2, à la direction dès G3. La direction décide, par exemple de couper le service (CSF `GV.RR-01`).
]

#etape(3, "Vérifier (requêtes prêtes dans Grafana, Explore, source Loki)")[
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
- *La collecte tient-elle ?* (Prometheus) #h(0.3em) `up{job="alloy"}`, `sum(rate(loki_distributor_lines_received_total[5m]))`
- *Faux positif possible* : un test oublié, ou un utilisateur qui a perdu son mot de passe (une source, peu d'essais).
]

#etape(4, "Contenir sans éteindre, et garder les preuves")[
- *Bloquer la source* : middleware `ipAllowList` inversé dans `traefik/dynamic/`, rechargé à chaud. Durcir `rate-limit`.
- *En G2* : désactiver le compte Juice Shop et invalider ses sessions.
- *Couper Juice Shop* sacrifie la disponibilité : c'est une décision de la direction.
- *Preuves* : exporter les résultats (horodatés en UTC), calculer leur SHA-256, noter qui a fait quoi et quand.
- *Si Loki est altéré* : la copie WORM du bucket `logs` (lots d'une minute, inaltérables) fait foi.
]

#etape(5, "Communiquer")[
- *En interne* : RSSI, direction, juriste. Chaque décision est écrite avec l'heure.
- *Données personnelles exposées (G2)* : annonce au PFPDT dans les meilleurs délais si le risque est élevé (nLPD art. 24).
- *Infrastructure critique* : annonce à l'OFCS sous 24 h (LSI).
- *Utilisateurs touchés* : réinitialisation du mot de passe. Messages approuvés par la direction (CSF `RC.CO`).
]

#etape(6, "Clore et tirer les leçons")[
- *Fin* quand : source bloquée, 30 min sans tentative, comptes réinitialisés, aucune session de l'attaquant active.
- *Retour d'expérience sans coupable* sous 5 jours ouvrés : ce qui a marché, ce qui a freiné, ce qu'on change.
- *Chaque action* a un responsable et une échéance (CSF `ID.IM`).
]

#encadre(titre: "Testé", couleur: vert)[
#grid(columns: (1fr, 1fr, 1fr), column-gutter: 0.8em,
  [*14:59:30 UTC* \ 20 logins faux envoyés.],
  [*+26 s* \ Alerte active dans Alertmanager.],
  [*+52 s* \ E-mail `[FIRING:1] BruteForceLogin` reçu par l'astreinte.],
)
#v(0.2em)
#text(8pt, fill: doux)[Journal `6-test-alerte-brute-force.log`. La `ClientHost` vue est `192.168.127.1`, la passerelle de Podman machine, pas l'attaquant (voir Limites).]
]

// ================================================================ 2. DRP
= Plan de reprise (DRP)

#encadre(titre: "Le DRP en bref")[
- *But* : remettre le stack en marche après un sinistre (disque perdu, volumes effacés, rançongiciel).
- *Qui* : l'astreinte, seule, avec le dépôt git et le *kit hors ligne* (rangé hors du poste).
- *Une commande* : `scripts/restaurer.sh`, puis lire le verdict de `scripts/verifier.sh`.
]

#v(0.3em)
#grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 0.6em,
  chiffre("MTD", "24 h", [Arrêt maximal tolérable : au-delà, plus d'annonce possible à l'OFCS.]),
  chiffre("RTO", "1 h", [Reprise visée sur un poste neuf. *Mesuré : 70 s* (même poste).]),
  chiffre("RPO logs", "1 min", [Alloy copie les logs en continu dans le WORM, par lots de 60 s.]),
  chiffre("RPO volumes", "24 h", [Une sauvegarde par nuit. Dashboards et comptes changent peu.]),
)
#text(8pt, fill: doux)[*RTO* : temps acceptable avant le retour du service. *RPO* : quantité de données qu'on accepte de perdre. *MTD* : durée d'arrêt au-delà de laquelle l'organisation est en faute.]

== Ce que l'on protège

#block(breakable: false, table(columns: (4.4cm, 2.2cm, 1fr, 1.8cm),
  [Élément], [Où il vit], [Si on le perd…], [Gravité],
  [*Secrets* : clés des 3 CA, clé de chiffrement Authelia, comptes], [`secrets/`, hors git], [La base Authelia devient illisible ; tous les certificats mTLS sont à refaire.], badge("critique"),
  [*Kit hors ligne* : clé privée `age`, accès au WORM], [hors du poste], [Toutes les sauvegardes deviennent illisibles. *À ne jamais perdre.*], badge("critique"),
  [`loki-data` : logs (30 j, sécurité 180 j)], [volume], [Les preuves d'un incident disparaissent (la copie WORM les garde).], badge("critique"),
  [`authelia-data` : TOTP, bannissements], [volume], [Chaque utilisateur doit réenrôler son second facteur.], badge("élevée"),
  [`grafana-data` : comptes, dashboards faits à la main], [volume], [Les dashboards d'enquête sont perdus.], badge("moyenne"),
  [Images des conteneurs (4,3 Go)], [registres publics], [Reprise retardée ; une image peut disparaître (vécu avec MinIO).], badge("moyenne"),
  [`alertmanager-data`, `prometheus-data`, `alloy-data`], [volumes], [Silences, historique des métriques ; quelques logs en double.], badge("faible"),
  [Configurations, règles, dashboards provisionnés], [dépôt git], [Rien : tout se reconstruit depuis le dépôt.], badge("faible"),
))

== Comment on sauvegarde

#grid(columns: (1fr, 1fr), column-gutter: 1.2em,
[
- *Quoi* : les 6 volumes, plus `secrets/` et `.env`. Sans eux, les données seules ne redémarrent rien.
- *Quand* : chaque nuit à 03:00, avec `scripts/sauvegarder.sh`.
- *Comment* : stack arrêté pendant l'export (bases SQLite et TSDB cohérentes). Coût : *15 s* sans détection.
- *Conservation* : 30 jours pour les sauvegardes, 365 jours pour les logs (1 jour dans le labo).
- *Test* : une restauration chronométrée par mois ; un échec est un incident.
],
[
- *Règle 3-2-1* : 3 copies, 2 supports, 1 hors du stack :
  + les volumes en service ;
  + les archives sur le disque du poste (`sauvegardes/`) ;
  + le bucket *WORM* (« write once, read many ») : personne ne peut l'effacer avant la fin de la rétention, pas même l'administrateur (testé : `AccessDenied`).
- *Chiffrement* : `age`. Le poste n'a que la clé *publique* : le voler ne permet pas de lire les sauvegardes.
- *Intégrité* : une empreinte SHA-256 par fichier, vérifiée avant toute restauration (CSF `RC.RP-03`).
],
)

== Restaurer, pas à pas

#encadre(titre: "Avant de commencer : 3 choses à avoir", couleur: bleu)[
#grid(columns: (1fr, 1fr, 1fr), column-gutter: 0.8em,
  [☐ Un poste avec *Podman* et le *dépôt git* cloné.],
  [☐ Le *kit hors ligne* dans `~/.config/drp/` (ou `DRP_KIT=<chemin>`).],
  [☐ La *copie WORM* joignable (projet `hors-stack` démarré).],
)]

#etape(1, "Lancer la restauration", commande: [`scripts/restaurer.sh` #h(0.3em) ou #h(0.3em) `scripts/restaurer.sh <ID>`])[
- Le script prend la dernière sauvegarde *dans le WORM*, jamais sur le disque local (il peut être perdu ou piégé).
]
#etape(2, "Il vérifie avant de toucher à quoi que ce soit")[
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
- *Succès* : la dernière ligne affiche « SERVICE RÉTABLI ET VÉRIFIÉ » et le RTO mesuré.
- *Échec* : « la restauration n'est PAS réussie » #sym.arrow traiter comme un incident et prévenir le RSSI.
]

== Le test réel

#block(breakable: false, grid(columns: (1.2fr, 1fr), column-gutter: 1.2em,
[
#text(8pt, fill: doux)[13.11.2026 · journaux dans `stack/journaux/`]
+ *Témoins* : une donnée marquée par volume (dashboard, log, instant Prometheus, silence, empreinte des TOTP).
+ *Sauvegarde* : 9 fichiers, 177 Mo, copiés dans le WORM, relus *avant* le sinistre.
+ *Sinistre* (14:57:58 UTC) : `podman compose down -v`, puis suppression de `secrets/`, `.env` et des sauvegardes locales. Restent le dépôt, le kit et le WORM.
+ *Restauration* : `scripts/restaurer.sh`, sans intervention.
+ *Résultat* : *14 vérifications sur 14* #ok : 11 conteneurs en marche, SSO, témoins retrouvés, nouveaux logs collectés, 9 cibles Prometheus sur 9, TOTP identiques, heartbeat reçu.
],
[
#table(columns: (1fr, auto),
  [Étape], [Temps],
  [Téléchargement WORM (171 Mo), vérifications], [2 s],
  [Secrets, premier démarrage puis arrêt], [12 s],
  [Import des 6 volumes], [7 s],
  [Redémarrage], [2 s],
  [Vérifications jusqu'au service rétabli], [49 s],
  table.cell(fill: accent.lighten(90%))[*RTO mesuré*], table.cell(fill: accent.lighten(90%))[#text(fill: accent)[*70 s*]],
)],
))

// ================================================================ 3. Limites
= Limites

#let limite(titre, body) = block(width: 100%, breakable: false, stroke: 0.5pt + trait, radius: 4pt, inset: 0.9em)[
  #text(weight: "bold", titre) #v(0.15em) #body]

#grid(columns: (1fr, 1fr), column-gutter: 0.9em, row-gutter: 0.9em,
  limite("Infrastructure du labo")[
    - *WORM sur le même hôte* : l'Object Lock protège contre l'API S3, pas contre `podman volume rm` ni la perte du disque. Le heartbeat et la boîte de l'astreinte tombent aussi avec l'hôte.
    - *Un seul compte S3* : Alloy et les sauvegardes partagent le compte racine de RustFS.
    - *Composants jeunes* : RustFS, et la sortie S3 d'Alloy est expérimentale.
    - *En production* : un autre fournisseur, un autre compte, un compte en écriture seule.
  ],
  limite("Mesures et couverture")[
    - *RTO au meilleur cas* : même poste, images en cache. Celui d'un poste neuf (1 h) est estimé.
    - *Pas de PCA* : ni détection ni mode dégradé pendant la sauvegarde (15 s par jour) et la reprise.
    - *Corruption silencieuse* : les témoins prouvent la présence de quelques données, pas l'intégrité de toutes.
    - *Non testé* : la communication, la reprise sur un poste neuf, la perte du kit (irrécupérable par construction).
  ],
  limite("Compromission")[
    - Le plan restaure la *dernière* sauvegarde. Après une intrusion ancienne, il en faut une *antérieure*.
    - La rétention du labo (1 jour) ne le permet pas, et rien ne prouve qu'une sauvegarde est saine.
  ],
  limite("Écarts au schéma")[
    - *Source invisible* : Traefik voit la passerelle Podman (`192.168.127.1`). Bloquer « l'attaquant » bloquerait tout le monde ; il faudrait le proxy protocol ou un hôte Linux.
    - *HTTP vers les backends* (le schéma dit HTTPS) ; port *8443* au lieu de 443 (interdit sans root sur macOS).
  ],
)

// ================================================================ Annexe
#pagebreak()
#set heading(numbering: none)
= Annexe : usage de l'IA

- *Outil* : Claude Code (CLI, mode auto).
- *Modèle* : Claude Opus 5.5 (`claude-opus-5-5`).
- *Date* : 13.11.2026.

== Prompts, tels quels

+ L'IA proposait d'exécuter la restauration sur `stack-04`. Réponse : « reprends comment la stack-04 est structurer et fais un
  docker compose mais avec notre nouvelle stack definis dans l'activite »
+ « pourquoi rustfs ? »

== Ce que l'IA a produit

- Le `compose.yaml` du stack et du projet externe.
- Toutes les configurations : Traefik ×2, Authelia, Loki, Alloy, Prometheus, Alertmanager.
- Les scripts `init-secrets.sh`, `temoins.sh`, `sauvegarder.sh`, `restaurer.sh`, `verifier.sh`.
- L'exécution du test et la rédaction de ce document.

== Ce que nous avons gardé, corrigé ou rejeté

#table(columns: (5.5cm, 1fr),
  [Décision], [Pourquoi],
  [*Rejeté* : MinIO pour la copie WORM], [Images retirées des registres (`access denied`) ; remplacé par RustFS après un test : suppression refusée en compliance.],
  [*Corrigé* : port 443], [macOS refuse 443 sur `127.0.0.1` ; exposer 443 sur toutes les interfaces aurait élargi la surface : 8443 retenu.],
  [*Corrigé* : noms des conteneurs], [Conflit avec les conteneurs de `stack-04` ; préfixe `drp-` plutôt que supprimer `stack-04`.],
  [*Corrigé* : premier témoin Grafana], [Erreur de l'IA dans son propre script (arguments `-X POST` perdus) ; repérée parce qu'un « OK » manquait.],
  [*Ajouté* : vidage avant import], [`podman volume import` fusionne ; sans vidage, WAL et index du premier démarrage se mêlent aux données.],
  [*Gardé* : RPO, RTO, MTD, playbook], [À relire : ce sont des choix d'organisation, que nous devons pouvoir défendre sans l'IA.],
)
