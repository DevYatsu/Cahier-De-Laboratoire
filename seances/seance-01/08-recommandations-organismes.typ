// Activité 2 - recommandations d'organismes de sécurité (partie après-midi).
#import "/template.typ": *

== Activité 2 : Recommandations d'organismes de sécurité
#text(size: 0.9em, fill: gray)[Partie après-midi · activité 2]

#encadre("Objectifs")[Résumer et référencer les recommandations de l'OFCS (Office fédéral de la cybersécurité, bacs.admin.ch (ex-ncsc.admin.ch)) ou d'organismes similaires. Je couvre le phishing, le ransomware, le DDoS, les data leaks et les supply chains. J'ajoute les menaces de l'écosystème open source et de Microsoft Exchange.]

=== Métiers pertinents

Le RSSI pilote ces mesures et arbitre les priorités. Le SOC et la blue team les appliquent au quotidien. Le dev sécurise le code et les dépendances. Le chef de projet planifie les backups et les playbooks.

=== Déroulement

Le tableau ci-dessous résume les sept menaces et deux recommandations clés pour chacune.

#table(
  columns: (1fr, 1.6fr, 2fr),
  [*Menace*], [*Position OFCS / autre organisme*], [*2 recos clés*],
  [Phishing], [Menace n°1 en Suisse selon l'OFCS.], [Passer par un favori, jamais par un lien. Activer la 2FA ou FIDO2.],
  [Ransomware], [Ne jamais payer selon l'OFCS et CISA.], [Backup 3-2-1 offline et testé. Patcher et bloquer les macros.],
  [DDoS], [Tenir la charge avec le FAI selon l'OFCS.], [Préparer les contacts FAI et un CDN. Activer SYN-cookies, WAF et GeoIP.],
  [Data leaks], [Notifier le PFPDT et l'OFCS selon la loi.], [Aucune base sur Internet. Appliquer le moindre privilège et le chiffrement.],
  [Supply chain], [Doctrine CISA / ESF, pas de page OFCS dédiée.], [Exiger un SBOM et un VEX. Cartographier les fournisseurs.],
  [Open source], [Principes CISA sur la sécurité open source.], [Verrouiller les lockfiles et scanner avec SCA. Tenir un miroir interne avec allowlist.],
  [Exchange], [OFCS a relancé plus de 4500 entités.], [Appliquer les CU et SU sans délai. Considérer tout serveur non patché comme compromis.],
)

==== Phishing

Le phishing reste la menace n°1 en Suisse. L'OFCS compte 975 309 signalements en 2024, soit une hausse de 108 %. Le portail antiphishing.ch centralise les signalements via reports\@antiphishing.ch. Les attaques en temps réel imitent M365 et SharePoint et contournent la 2FA simple.

Je ne saisis jamais un mot de passe via un lien. Je passe par un favori enregistré. J'active la 2FA ou FIDO2 partout. Je signale chaque tentative. Si mon compte est compromis, je change le mot de passe et je dépose plainte. Côté domaine, je configure SPF, DKIM et DMARC.

==== Ransomware

Le ransomware entre par trois portes : un patch manquant, un RDP ou VPN sans 2FA, ou une macro piégée. La règle est claire : je ne paie pas la rançon. Je maintiens un backup 3-2-1 offline et testé. Je bloque les macros par défaut.

Si une machine est chiffrée, je l'isole du réseau. Je lance une analyse forensique avant toute réinstallation. Je vérifie les déchiffreurs gratuits du projet No More Ransom.

==== DDoS

Le DDoS sature un service avec des botnets ou de l'amplification. L'objectif n'est pas le vol mais l'indisponibilité. La doctrine OFCS dit de tenir la charge avec le FAI et la mitigation. Je ne paie pas en cas d'extorsion associée.

Je prépare les contacts du FAI et un CDN à l'avance. J'active les SYN-cookies, un WAF et du filtrage GeoIP. Je prévois un site de secours et un playbook écrit.

==== Data leaks

La fuite de données vient d'un backup exposé, d'une base exposée ou d'une exfiltration après intrusion. Je ne paie pas non plus dans ce cas. J'isole les systèmes concernés. J'inventorie les données touchées. Je notifie le PFPDT selon l'art. 24 nLPD via databreach.edoeb.admin.ch. Je notifie l'OFCS sous 24 h si je suis une infrastructure critique.

En prévention, je n'expose aucune base sur Internet. J'applique le moindre privilège strict. Je chiffre les données sensibles.

==== Supply chain

L'OFCS ne propose pas de page doctrine dédiée à la supply chain. La doctrine vient de CISA et de l'ESF. J'exige un SBOM au format SPDX ou CycloneDX avec un VEX. Je vérifie le SDLC et le SSDF du fournisseur. Je cartographie mes fournisseurs selon NIST SP 800-161. Je limite chaque composant au moindre privilège.

==== Menaces de l'écosystème open source

L'open source ajoute le typosquatting (diango au lieu de django). Il ajoute la dependency confusion entre registre public et privé. Il ajoute les mainteneurs compromis. Les cas Log4Shell et xz-utils montrent l'impact.

Je tiens un miroir interne avec une allowlist. Je verrouille les lockfiles et je ne mets pas à jour à l'aveugle. Je scanne avec un outil SCA comme Dependabot ou Trivy. J'évalue chaque projet avant adoption et je vérifie les signatures Sigstore. Je génère un SBOM à chaque build.

==== Microsoft Exchange

Exchange cumule trois familles de failles critiques. ProxyLogon couvre CVE-2021-26855, 26857, 26858 et 27065. Le groupe Hafnium l'exploite pour déposer un webshell SYSTEM. ProxyShell couvre CVE-2021-34473, 34523 et 31207. ProxyNotShell couvre CVE-2022-41040 et 41082. L'OFCS a relancé plus de 4500 entités suisses.

J'applique les mises à jour cumulatives et de sécurité sans délai. Je contrôle avec HealthChecker et Test-ProxyLogon.ps1. Je considère tout serveur non patché comme compromis et je le passe en forensique.

=== Résultats

Les sept menaces se rangent en trois groupes. Le phishing, le ransomware, le DDoS et les leaks forment le socle OFCS avec des réflexes directs. La supply chain et l'open source déplacent la confiance vers les fournisseurs et les dépendances. Exchange montre ce qui arrive quand un patch critique dort. Chaque menace tient en deux recos : un réflexe humain et une mesure technique. Le point commun est la préparation : backups testés, contacts prêts, inventaires à jour.

=== Interprétation des résultats

Ces recommandations protègent la triade CIA : confidentialité contre les leaks, intégrité contre le ransomware et la supply chain, disponibilité contre le DDoS. Elles appliquent la défense en profondeur : aucune mesure seule ne suffit et chaque couche rattrape la précédente. Elles suivent un cycle PDCA d'amélioration continue : patcher, tester, auditer, corriger. Pour mon projet de semestre, j'en retiens trois habitudes : SBOM à chaque build, backups testés, et playbook écrit avant l'incident.

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
