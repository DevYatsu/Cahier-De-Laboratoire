// Activité 7 - surface d'attaque du kernel Linux (cas opérateur cloud).
#import "/template.typ": *

== Activité 7 : Pourquoi la surface d'attaque du kernel Linux est devenu récemment un problème ? Que faire (cas : opérateur cloud) ?

#encadre("Objectifs")[
  - Comprendre pourquoi la surface d'attaque du kernel Linux est devenue un problème récemment.
  - Déterminer quoi faire dans le cas d'un opérateur cloud.
]

=== Métiers pertinents

- *Admin cloud, exploitant hyperviseur :* isolation et patching des nœuds.
- *Architecte sécurité :* choix du runtime et des profils de confinement.
- *SOC, blue team :* détection runtime.
- *RSSI :* arbitre entre exposition multi-tenant et coût des redémarrages.

=== Déroulement

- *Risque propre à l'opérateur cloud :* les conteneurs partagent le noyau de l'hôte.
  - Une seule faille noyau casse la multi-tenancy.
  - L'attaquant s'évade du conteneur ou de la VM.
  - Il compromet l'hyperviseur ou le nœud hôte.
- *Pourquoi difficile à contenir en 2026 :* fuzzing assisté par IA, industrialisation des proofs of concept (PoC), évolution rapide du noyau, d'où une pression accrue sur les mainteneurs.
  - Les chiffres de CVE par version varient selon la source et la période.
  - Les ~2 000 cités par certaines analyses sont un instantané à vérifier, pas une constante.
- *LPE (Local Privilege Escalation) récentes :* Copy Fail, Dirty Frag, Dirty Clone, souvent avec PoC public.
  - Le délai entre publication et exploitation varie.
  - L'impact dépend du noyau, de la configuration et de l'isolation.
  - Le passage conteneur → root est un scénario à reproduire et à réduire, pas une conséquence systématique.
- *Agents autonomes :* des recherches décrivent des agents capables d'adapter des PoC publics.
  - Évasion, root sur l'hôte et mouvement latéral dépendent de la vulnérabilité et des mesures en place.
  - Ce scénario n'est pas systématique.

#table(
  columns: (1fr, 2fr, 2fr),
  [*Facteur*], [*Mécanisme*], [*Effet pour l'opérateur cloud*],
  [Fuzzing + IA], [Scan massif du code, volume de CVE signalé dans les sources consultées.], [Pression sur le rythme de publication et de correction.],
  [LPE sérialisées], [PoC public, scénario d'élévation conteneur vers root.], [Risque pour le nœud partagé si la faille est exploitable et les mesures inefficaces.],
  [Agents autonomes], [Adaptation de PoC publics ; scénario d'évasion et mouvement latéral.], [Risque de compromission de l'hôte et de propagation inter-tenants si les conditions sont réunies.],
)

=== Résultats

- *Constat :* un cycle mensuel de patch ne suffit pas toujours.
- *Plan en quatre étapes :* réduire, isoler, patcher à chaud, surveiller.

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

- *Étape 1 : réduire la surface du noyau (hardening).* La plupart des failles récentes visent des modules réseau ou des filesystems inutiles en production cloud.
  - Bloquer leur chargement via `modprobe.d`.
  - Désactiver les protocoles non requis et les vieux filesystems.
  - Couper les fonctions à risque comme `io_uring` si aucune architecture ne l'exige.
  - Restreindre les appels système par des profils Seccomp stricts.
  - Interdire `clone3`, `unshare` ou `keyctl` aux charges clientes.
- *Étape 2 : durcir l'isolation (sandboxing).* Docker / containerd classique partage le noyau hôte : si le noyau tombe, l'hôte tombe.
  - Pour les charges non dignes de confiance : gVisor ou Kata Containers.
  - *gVisor :* intercepte et émule les syscalls en espace utilisateur.
  - *Kata Containers :* chaque conteneur dans une micro-VM avec son propre noyau.
- *Étape 3 : moderniser le patching.* Redémarrer des milliers d'hyperviseurs ralentit chaque correctif.
  - *Live-patching (KernelCare, Kpatch, Livepatch) :* charge un correctif en mémoire sans redémarrage immédiat, lorsque correctif et système le permettent.
  - Limite : seulement les correctifs compatibles, sans supprimer tous les risques.
  - *Changements structurels :* pipeline d'infrastructure (drain du nœud, mise à jour, test, redémarrage ou redéploiement progressif).
- *Étape 4 : détecter au runtime via eBPF.* Outil CNAPP / CWPP basé sur eBPF (Cilium Tetragon, Falco).
  - Observe le noyau en temps réel.
  - Alerte sur une élévation de privilèges sans fichier modifié.
  - Signale une structure socket anormale.

#table(
  columns: (1fr, 2fr, 2fr),
  [*Étape*], [*Action que je pilote*], [*Outil ou mécanisme*],
  [Réduire], [Désactiver modules, filtrer syscalls.], [`modprobe.d`, Seccomp, sans `io_uring`.],
  [Isoler], [Runtime à isolation forte pour l'untrusted.], [gVisor, Kata Containers.],
  [Patcher], [Corriger à chaud lorsque c'est compatible ; drain et redémarrage pour les changements structurels.], [KernelCare / Kpatch / Livepatch, pipeline drain.],
  [Surveiller], [Détecter l'anomalie au cœur du noyau.], [eBPF, Tetragon, Falco.],
)

=== Interprétation des résultats

- *Défense en profondeur :* chaque étape rattrape la précédente.
  - Le hardening réduit l'exposition.
  - Le sandboxing confine les charges non fiables.
  - Le live-patching réduit la fenêtre d'exposition, si le correctif est compatible.
  - La détection eBPF signale les comportements suspects à l'exécution.
- *Triade CIA côté opérateur :*
  - confidentialité : séparation des tenants ;
  - intégrité : bloquer ou réduire l'élévation conteneur → root ;
  - disponibilité : maintenue pendant le patching si le live-patch est compatible, sinon drain ou redémarrage.
- *Moindre privilège et Zero Trust :* aucun workload client n'obtient par défaut un syscall sensible.
- *Cycle PDCA :*
  - Plan : inventaire des modules et des syscalls ;
  - Do : déploiement des profils et runtimes ;
  - Check : Tetragon et audits ;
  - Act : live-patch et SoA.
- *ISO 27001 :* trace vers la gestion des vulnérabilités techniques et la sécurité des environnements de développement et d'exploitation.
  - Le certificat ne prouve pas l'absence de CVE noyau.
  - Il prouve qu'un système de patching et de surveillance tourne en continu.
- *Trois réflexes pour le projet de semestre :*
  - runtime isolé pour tout workload non digne de confiance ;
  - Seccomp strict par défaut ;
  - live-patching si compatible, drain ou redémarrage pour les changements structurels.

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
