// Activité 7 - surface d'attaque du kernel Linux (cas opérateur cloud).
#import "/template.typ": *

== Activité 7 : Pourquoi la surface d'attaque du kernel Linux est devenu récemment un problème ? Que faire (cas : opérateur cloud) ?
#text(size: 0.9em, fill: gray)[Partie après-midi · activité 7]

#encadre("Objectifs")[Comprendre pourquoi la surface d'attaque du kernel Linux est devenue un problème récemment, et quoi faire dans le cas d'un opérateur cloud.]

=== Métiers pertinents

L'admin cloud et l'exploitant hyperviseur portent l'isolation et le patching des nœuds. L'architecte sécurité choisit le runtime et les profils de confinement. Le SOC et la blue team opèrent la détection runtime. Le RSSI arbitre entre exposition multi-tenant et coût des redémarrages.

=== Déroulement

Je pars du risque propre à l'opérateur cloud : les conteneurs partagent le noyau de l'hôte. Une seule faille noyau casse la multi-tenancy. Un attaquant s'évade du conteneur ou de la VM. Il compromet l'hyperviseur ou le nœud hôte.

Trois facteurs rendent ce risque critique en 2026. D'abord le fuzzing assisté par IA. Les chercheurs et les attaquants scannent un code de plus de 40 millions de lignes avec des LLM. Le noyau frôle 2 000 CVE corrigées par version, contre environ 500 auparavant. Les mainteneurs absorbent un flux constant.

Ensuite la sérialisation des LPE (Local Privilege Escalation). Des failles comme Copy Fail, Dirty Frag ou Dirty Clone sortent avec un PoC immédiatement disponible. Un simple compte conteneur passe root en une commande. La manipulation du cache mémoire devient reproductible.

Enfin l'automatisation des attaques. Des agents IA adaptent seuls un PoC public. Ils s'évadent du conteneur. Ils obtiennent root sur l'hôte. Puis ils se déplacent latéralement dans l'infrastructure.

#table(
  columns: (1fr, 2fr, 2fr),
  [*Facteur*], [*Mécanisme*], [*Effet pour l'opérateur cloud*],
  [Fuzzing + IA], [Scan massif du code, ~2 000 CVE par version.], [Fenêtre d'exposition permanente, patching sous pression.],
  [LPE sérialisées], [PoC public, élévation conteneur vers root.], [Un seul tenant compromet le nœud partagé.],
  [Agents autonomes], [Adaptation auto du PoC, mouvement latéral.], [Compromission hôte puis propagation inter-tenants.],
)

=== Résultats

Un patch mensuel ne suffit plus. Je retiens un plan en quatre étapes : réduire, isoler, patcher à chaud, surveiller.

Le schéma ordonne le plan : durcir d'abord, surveiller en continu.
#align(center)[
  #diagram(
    spacing: (10mm, 8mm),
    node-inset: 7pt,
    node-corner-radius: 4pt,
    node-stroke: 0.8pt + encre,
    edge-stroke: 0.8pt + rouge,
    node((0, 0), align(center)[*Réduire*\ Hardening], fill: fond-rouge),
    edge("->"),
    node((1, 0), align(center)[*Isoler*\ gVisor, Kata], fill: white),
    edge("->"),
    node((2, 0), align(center)[*Patcher*\ Live-patch], fill: white),
    edge("->"),
    node((3, 0), align(center)[*Surveiller*\ eBPF], fill: fond-rouge),
  )
]

*Étape 1 : réduire la surface du noyau (hardening).* La plupart des failles récentes visent des modules réseau ou des systèmes de fichiers inutiles en production cloud. Je bloque leur chargement via `modprobe.d`. Je désactive les protocoles non requis et les vieux filesystems. Je coupe les fonctions à risque comme `io_uring` si aucune architecture ne l'exige. Je restreins les appels système avec des profils Seccomp stricts sur les runtimes. J'interdis `clone3`, `unshare` ou `keyctl` aux charges clientes.

*Étape 2 : durcir l'isolation (sandboxing).* Le runtime Docker / containerd classique partage le noyau hôte. Si le noyau tombe, l'hôte tombe. Pour les charges non dignes de confiance, je remplace l'isolation par gVisor ou Kata Containers. gVisor intercepte et émule les syscalls en espace utilisateur. Kata Containers encapsule chaque conteneur dans une micro-VM avec son propre noyau.

*Étape 3 : moderniser le patching.* Redémarrer des milliers d'hyperviseurs ralentit chaque correctif. Je déploie le live-patching (KernelCare, Kpatch, Livepatch). Il injecte le correctif en mémoire sans interrompre les clients. La fenêtre d'exposition tombe à zéro pour les CVE simples. Pour les correctifs structurels, je prévois un pipeline d'infrastructure : drain du nœud, mise à jour, test, redéploiement progressif et transparent.

*Étape 4 : détecter au runtime via eBPF.* Je déploie un outil CNAPP / CWPP basé sur eBPF, comme Cilium Tetragon ou Falco. Il observe le noyau en temps réel. Il lève une alerte sur une élévation de privilèges sans fichier modifié. Il signale une structure socket anormale.

#table(
  columns: (1fr, 2fr, 2fr),
  [*Étape*], [*Action que je pilote*], [*Outil ou mécanisme*],
  [Réduire], [Désactiver modules, filtrer syscalls.], [`modprobe.d`, Seccomp, sans `io_uring`.],
  [Isoler], [Runtime à isolation forte pour l'untrusted.], [gVisor, Kata Containers.],
  [Patcher], [Corriger à chaud, redéployer sans coupure.], [KernelCare / Kpatch / Livepatch, pipeline drain.],
  [Surveiller], [Détecter l'anomalie au cœur du noyau.], [eBPF, Tetragon, Falco.],
)

=== Interprétation des résultats

Ce plan applique la défense en profondeur. Chaque étape rattrape la précédente. Le hardening rate la CVE restante. Le sandboxing la confine. Le live-patching la ferme vite. La détection eBPF la voit quand elle s'exécute.

Il protège la triade CIA côté opérateur. La confidentialité sépare les tenants. L'intégrité bloque l'élévation conteneur vers root. La disponibilité survit au patching grâce au live-patch et au drain progressif. Je retrouve le moindre privilège et Zero Trust : aucun workload client n'obtient un syscall sensible par défaut.

Il suit un cycle PDCA. Je planifie avec l'inventaire des modules et des syscalls. Je déploie les profils et les runtimes. Je contrôle avec Tetragon et les audits. Je corrige avec le live-patch et la SoA. Côté ISO 27001, cela trace vers la gestion des vulnérabilités techniques et la sécurité des environnements de développement et d'exploitation. Le certificat ne prouve pas l'absence de CVE noyau. Il prouve qu'un système de patching et de surveillance tourne en continu.

Pour mon projet de semestre, j'en retiens trois réflexes : runtime isolé pour tout workload non digne de confiance, Seccomp strict par défaut, et correctif noyau sans reboot dès qu'une LPE publique sort.

=== Références

*Sources de l'analyse :*
- #link("https://www.tomshardware.com/software/linux/linux-kernel-nears-2-000-cves-per-release-as-ai-bug-hunters-scour-40-million-lines-of-code-maintainers-say-they-are-completely-overwhelmed")[Tom's Hardware : le noyau frôle 2 000 CVE par version, chasseurs IA sur 40 M de lignes, mainteneurs submergés]
- #link("https://linuxsecurity.com/features/linux-kernel-security-2025")[LinuxSecurity : état de la sécurité du noyau Linux 2025]
- #link("https://host.it/fr/blog/cve-kernel-linux-ai-patch-senza-riavvio/")[Host.it : CVE noyau Linux, IA et patch sans redémarrage]

*Isolation et détection :*
- #link("https://gvisor.dev")[gVisor : isolation par interception des syscalls]
- #link("https://katacontainers.io")[Kata Containers : conteneur dans une micro-VM]
- #link("https://ebpf.io")[eBPF : observation du noyau en temps réel]
- #link("https://falco.org")[Falco : détection runtime cloud-native]
- #link("https://tetragon.io")[Cilium Tetragon : sécurité runtime basée sur eBPF]
