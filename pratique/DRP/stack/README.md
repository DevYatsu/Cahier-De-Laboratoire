# Stack « drp » : architecture du rapport, sauvegarde et restauration

Implémente `../architecture.mmd` sur le modèle de `stack-04` : Traefik (seul port publié, 8443), SSO Authelia en forward-auth,
un réseau privé par backend, Loki derrière une seconde instance Traefik en mTLS (CA « ingest » pour écrire, « reader » pour lire),
Prometheus et Alertmanager sur un réseau de supervision, socket Podman filtré (GET uniquement).
Hors du stack (`externe/`) : copie WORM (RustFS, Object Lock compliance), heartbeat externe, boîte de l'astreinte (Mailpit).

| Service | URL |
|---|---|
| Juice Shop | https://juiceshop.drp.localhost:8443 |
| SSO | https://auth.drp.localhost:8443 |
| Grafana, Prometheus, Alertmanager, cAdvisor, Alloy | https://<service>.drp.localhost:8443 (SSO) |
| Astreinte (Mailpit) | http://127.0.0.1:8025 |

## Démarrer

Prérequis (vérifiés par `init-secrets.sh`, qui affiche la commande d'installation manquante) :

- macOS : `brew install podman mkcert openssl@3 age`
- Debian/Ubuntu : `sudo apt install podman podman-compose mkcert libnss3-tools openssl age`
- Fedora : `sudo dnf install podman podman-compose mkcert nss-tools openssl age`

```sh
./init-secrets.sh                      # secrets/ + kit hors ligne ~/.config/drp (clé age, accès WORM)
                                       # + certificat d'entrée (scripts/cert-entree.sh, CA mkcert de ce poste)
                                       # + .env, chemins Podman de ce poste (scripts/preparer-env.sh)
(cd externe && podman compose up -d)   # d'abord : il crée le réseau « externe »
podman compose up -d
```

Identifiant SSO : `identifiants.md` (à ranger dans un gestionnaire de mots de passe, puis supprimer).

## DRP

```sh
scripts/temoins.sh      # un témoin par volume (dashboard, log, instant Prometheus, silence, TOTP)
scripts/sauvegarder.sh  # stop, export chiffré (age), SHA-256, start, copie WORM
scripts/restaurer.sh    # depuis le WORM : vérifie, restaure, puis scripts/verifier.sh (14 contrôles)
```

Journaux du test du 13.11.2026 : `journaux/`.
