// Activité 2 - recommandations d'organismes de sécurité (partie après-midi).
#import "/template.typ": *

== Activité 2 : Recommandations d'organismes de sécurité

#encadre("Objectifs")[
  - Résumer et référencer les recommandations de l'OFCS (Office fédéral de la cybersécurité, bacs.admin.ch) ou d'organismes similaires.
  - Couvrir le phishing, le ransomware, le DDoS, les data leaks et les supply chains.
  - Ajouter les menaces de l'écosystème open source et de Microsoft Exchange.
]

=== Métiers pertinents

- *RSSI :* pilote les mesures, arbitre les priorités.
- *SOC, blue team :* appliquent au quotidien.
- *Développeur :* sécurise le code et les dépendances.
- *Chef de projet :* planifie les backups et les playbooks.

=== Déroulement

Sept menaces, deux recommandations clés pour chacune :

#table(
  columns: (1fr, 1.6fr, 2fr),
  [*Menace*], [*Position OFCS / autre organisme*], [*2 recos clés*],
  [Phishing], [Menace n°1 en Suisse selon l'OFCS.], [Passer par un favori, jamais par un lien. Activer la 2FA ou FIDO2.],
  [Ransomware], [Ne jamais payer selon l'OFCS et CISA.], [Backup 3-2-1 offline et testé. Patcher et bloquer les macros.],
  [DDoS], [Tenir la charge avec le FAI selon l'OFCS.], [Préparer les contacts FAI et un CDN. Activer SYN-cookies, WAF et GeoIP.],
  [Data leaks], [Notifier le PFPDT et l'OFCS selon la loi.], [Aucune base sur Internet. Appliquer le moindre privilège et le chiffrement.],
  [Supply chain], [Doctrine CISA / ESF, pas de page OFCS dédiée.], [Exiger un SBOM et un VEX. Cartographier les fournisseurs.],
  [Open source], [Principes CISA sur la sécurité open source.], [Verrouiller les lockfiles et scanner avec SCA. Tenir un miroir interne avec allowlist.],
  [Exchange], [Le NCSC (aujourd'hui OFCS) a signalé plus de 4 500 entités concernées.], [Appliquer les CU et SU sans délai. Considérer tout serveur non patché comme compromis.],
)

==== Phishing

- *Bilan 2024 (antiphishing.ch) :*
  - 975 309 signalements (+79 % sur un an) ;
  - 20 872 sites de phishing confirmés (+108 % sur un an) ;
  - ces chiffres décrivent les signalements centralisés par le portail, pas toutes les tentatives.
- *Tendance :* attaques en temps réel imitant M365 et SharePoint, contournant parfois la 2FA simple.
- *Réflexes :*
  - ne jamais saisir un mot de passe via un lien, passer par un favori ;
  - activer la 2FA ou FIDO2 partout ;
  - signaler chaque tentative.
- *Si compromis :* changer le mot de passe, déposer plainte.
- *Côté domaine :* configurer SPF, DKIM et DMARC.

==== Ransomware

- *Trois portes d'entrée :* patch manquant, RDP ou VPN sans 2FA, macro piégée.
- *Règle :* ne pas payer la rançon.
- *Prévention :* backup 3-2-1 offline et testé, macros bloquées par défaut.
- *Si une machine est chiffrée :*
  - l'isoler du réseau ;
  - analyse forensique avant toute réinstallation ;
  - vérifier les déchiffreurs gratuits de No More Ransom.

==== DDoS

- *Mécanisme :* saturation d'un service par botnets ou amplification.
- *But :* l'indisponibilité, pas le vol.
- *Doctrine OFCS :* tenir la charge avec le FAI et la mitigation ; ne pas payer en cas d'extorsion.
- *Préparation :*
  - contacts FAI et CDN prêts à l'avance ;
  - SYN-cookies, WAF, filtrage GeoIP ;
  - site de secours et playbook écrit.

==== Data leaks

- *Origines :* backup exposé, base exposée, exfiltration après intrusion.
- *Règle :* ne pas payer.
- *Réaction :*
  - isoler les systèmes concernés ;
  - inventorier les données touchées ;
  - notifier le PFPDT (art. 24 nLPD) via databreach.edoeb.admin.ch ;
  - notifier l'OFCS sous 24 h si infrastructure critique.
- *Prévention :* aucune base sur Internet, moindre privilège strict, chiffrement des données sensibles.

==== Supply chain

- *Doctrine :* pas de page OFCS dédiée ; elle vient de CISA et de l'ESF.
- *Mesures :*
  - exiger un SBOM (SPDX ou CycloneDX) avec un VEX ;
  - vérifier le SDLC et le SSDF du fournisseur ;
  - cartographier les fournisseurs selon NIST SP 800-161 ;
  - limiter chaque composant au moindre privilège.

==== Menaces de l'écosystème open source

- *Menaces propres :*
  - typosquatting (diango au lieu de django) ;
  - dependency confusion entre registre public et privé ;
  - mainteneurs compromis.
- *Cas marquants :* Log4Shell, xz-utils.
- *Mesures :*
  - miroir interne avec allowlist ;
  - lockfiles verrouillés, pas de mise à jour à l'aveugle ;
  - scan SCA (Dependabot, Trivy) ;
  - évaluation avant adoption, signatures Sigstore vérifiées ;
  - SBOM à chaque build.

==== Microsoft Exchange

- *Trois familles de failles critiques :*
  - *ProxyLogon :* CVE-2021-26855, 26857, 26858, 27065 ; exploité par Hafnium pour déposer un webshell SYSTEM.
  - *ProxyShell :* CVE-2021-34473, 34523, 31207.
  - *ProxyNotShell :* CVE-2022-41040, 41082.
- *Impact suisse :* le NCSC a informé plus de 4 500 entités exposées ; alerte historique reprise par l'OFCS.
- *Mesures :*
  - appliquer les mises à jour cumulatives (CU) et de sécurité (SU) sans délai ;
  - contrôler avec HealthChecker et Test-ProxyLogon.ps1 ;
  - traiter un serveur non patché comme à risque élevé, l'isoler pour investigation.

=== Résultats

Trois groupes de menaces :
- *Socle OFCS :* phishing, ransomware, DDoS, leaks, avec des réflexes directs.
- *Confiance fournisseurs :* supply chain et open source déplacent la confiance vers les dépendances.
- *Patch critique :* Exchange montre ce qui arrive quand un patch critique dort.

Constats transverses :
- *Chaque menace tient en deux recos :* un réflexe humain, une mesure technique.
- *Point commun :* la préparation (backups testés, contacts prêts, inventaires à jour).

#align(center)[
  #diagram(
    spacing: (6mm, 8mm),
    node-inset: 6pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Socle OFCS*\ Phishing, ransom, DDoS, leaks], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Confiance fournisseurs*\ Supply chain, open source], fill: white),
    edge("->"),
    node((2, 0), align(center)[*Patch critique*\ Exchange], fill: fond-rouge),
  )
]

=== Interprétation des résultats

- *Triade CIA :*
  - confidentialité contre les leaks ;
  - intégrité contre le ransomware et la supply chain ;
  - disponibilité contre le DDoS.
- *Défense en profondeur :* aucune mesure seule ne suffit, chaque couche rattrape la précédente.
- *Cycle PDCA :* patcher, tester, auditer, corriger.
- *Trois habitudes pour le projet de semestre :* SBOM à chaque build, backups testés, playbook écrit avant l'incident.

=== Références

*Phishing :*
- #link("https://www.bacs.admin.ch/fr/phishing-fr")[OFCS - Phishing]
- #link("https://www.antiphishing.ch")[antiphishing.ch]
- #link("https://www.cybermalveillance.gouv.fr/tous-nos-contenus/fiches-reflexes/hameconnage-phishing")[Cybermalveillance - Hameçonnage]

*Ransomware :*
- #link("https://www.bacs.admin.ch/fr/ransomware-fr")[OFCS - Ransomware]
- #link("https://www.cisa.gov/stopransomware/ransomware-guide")[CISA - Ransomware Guide]

*DDoS :*
- #link("https://www.bacs.admin.ch/fr/attaque-disponibilite")[OFCS - DDoS]
- #link("https://www.bacs.admin.ch/fr/attaque-ddos-que-faire")[OFCS - Attaque DDoS : que faire]

*Data leaks :*
- #link("https://www.bacs.admin.ch/fr/fuite-donnees")[OFCS - Fuite de données]
- #link("https://databreach.edoeb.admin.ch")[Portail de notification PFPDT]
- #link("https://www.bacs.admin.ch/fr/fuite-donnees-autorites")[BACS - Fuite de données autorités]

*Supply chain :*
- #link("https://www.cisa.gov/sites/default/files/publications/defending%5Fagainst%5Fsoftware%5Fsupply%5Fchain%5Fattacks%5F508.pdf")[CISA - Defending Against Software Supply Chain Attacks (PDF)]

*Open source :*
- #link("https://www.cisa.gov/resources-tools/resources/open-source-software-security-principles-and-practices")[CISA - Open Source Software Security Principles]

*Exchange :*
- #link("https://www.bacs.admin.ch/fr/exchange_fr")[OFCS - Faille Exchange]
- #link("https://cert.ssi.gouv.fr/alerte/CERTFR-2021-ALE-004/")[CERT-FR - Alerte CERTFR-2021-ALE-004]
