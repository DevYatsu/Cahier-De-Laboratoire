#!/usr/bin/env bash
# Fonctions communes aux scripts du DRP. À sourcer depuis la racine du stack.
set -euo pipefail

PROJET=drp
# Volumes à sauvegarder : tout l'état qui ne se reconstruit pas depuis le dépôt.
VOLUMES=(grafana-data loki-data prometheus-data alertmanager-data authelia-data alloy-data)
HTTPS_PORT="${HTTPS_PORT:-8443}"
# Kit hors ligne : clé de déchiffrement et accès au WORM, rangés HORS du dossier du stack.
KIT="${DRP_KIT:-$HOME/.config/drp}"
AGE_ID="$KIT/age-identity.txt"
DEPOT_LOCAL=sauvegardes
T0=$(date +%s)

# Journal horodaté (UTC) : chaque ligne sert de trace pour le rapport de restauration.
log() { printf '%s  +%4ss  %s\n' "$(date -u +%H:%M:%S)" "$(( $(date +%s) - T0 ))" "$*"; }
ok()  { log "OK    $*"; }
ko()  { log "ÉCHEC $*"; ECHECS=$((ECHECS + 1)); }
ECHECS=0

# SHA-256 : sha256sum (coreutils, Linux), sinon shasum (macOS). Même format de sortie et option -c.
sha256() { if command -v sha256sum >/dev/null; then sha256sum "$@"; else shasum -a 256 "$@"; fi; }

compose() { podman compose "$@" 2>&1 | grep -v '>>>>' | grep -v '^$' || true; }

# Client S3 (aws-cli) sur le réseau « externe ». Dossier courant monté sur /w.
s3() {
  podman run --rm --network externe -v "$PWD:/w:z" -w /w \
    -v "$KIT/worm-credentials:/cred:ro,z" -e AWS_SHARED_CREDENTIALS_FILE=/cred \
    -e AWS_DEFAULT_REGION=us-east-1 docker.io/amazon/aws-cli:latest --endpoint-url http://worm:9000 "$@"
}

# Session SSO (Authelia) pour les vérifications à travers Traefik.
JAR=$(mktemp)
sso_login() {
  local u p
  u=$(cat secrets/grafana/admin-user)
  p="${SSO_PASSWORD:-$(sed -n 's/.*: `[^`]*` \/ `\([^`]*\)`.*/\1/p' identifiants.md 2>/dev/null)}"
  curl -s -c "$JAR" -b "$JAR" -H 'Content-Type: application/json' \
    -d "{\"username\":\"$u\",\"password\":\"$p\",\"keepMeLoggedIn\":false}" \
    "https://auth.drp.localhost:$HTTPS_PORT/api/firstfactor" | grep -q '"status":"OK"'
}
via_sso() { local h=$1 p=$2; shift 2; curl -s -b "$JAR" "$@" "https://$h.drp.localhost:$HTTPS_PORT$p"; }

# Attendre qu'une commande réussisse (délai en secondes).
attendre() {
  local delai=$1; shift
  local fin=$(( $(date +%s) + delai ))
  until "$@" >/dev/null 2>&1; do
    [ "$(date +%s)" -ge "$fin" ] && return 1
    sleep 2
  done
}
