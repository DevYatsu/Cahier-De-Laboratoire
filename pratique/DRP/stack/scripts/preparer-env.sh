#!/usr/bin/env bash
# Écrit .env avec les chemins Podman de CE poste : le socket de l'API et le stockage des conteneurs.
#
#   macOS (Podman machine) : chemins DANS la VM, ex. /run/podman/podman.sock
#   Linux rootless          : /run/user/<uid>/podman/podman.sock, ~/.local/share/containers
#   Linux root              : /run/podman/podman.sock, /var/lib/containers
#
# Un .env venu d'un autre poste (archive, copie) pointe vers un socket absent : socket-proxy reste
# « unhealthy », et Traefik et Alloy ne démarrent pas. Ce script est donc relancé à chaque restauration.
set -euo pipefail
cd "$(dirname "$0")/.."

info() { podman info --format "$1"; }

if [ "$(info '{{.Host.RemoteSocket.Exists}}')" != true ]; then
  # Linux : le socket de l'API est créé à la demande par systemd, mais l'unité n'est pas toujours activée.
  if [ "$(uname -s)" = Linux ] && command -v systemctl >/dev/null; then
    if [ "$(id -u)" -eq 0 ]; then systemctl enable --now podman.socket
    else systemctl --user enable --now podman.socket; fi
  fi
fi

SOCKET=$(info '{{.Host.RemoteSocket.Path}}' | sed 's#^unix://##')
if [ "$(info '{{.Host.RemoteSocket.Exists}}')" != true ]; then
  echo "ÉCHEC : socket de l'API Podman absent ($SOCKET)." >&2
  echo "  Linux : systemctl --user enable --now podman.socket   (ou sans --user en root)" >&2
  echo "  macOS : podman machine start" >&2
  exit 1
fi
STOCKAGE=$(info '{{.Store.GraphRoot}}' | sed 's#/storage$##')

# oom_score_adj du terminal (Linux ; 0 sous macOS, où les conteneurs tournent en root dans la VM).
# Un processus non privilégié ne peut pas baisser cette valeur : avec celle du terminal, `podman exec` n'a jamais à le faire.
OOM=$(cat /proc/self/oom_score_adj 2>/dev/null || echo 0)

printf 'PODMAN_SOCKET=%s\nPODMAN_STORAGE=%s\nOOM_SCORE_ADJ=%s\n' "$SOCKET" "$STOCKAGE" "$OOM" > .env
echo ".env : socket $SOCKET, stockage $STOCKAGE, oom_score_adj $OOM"
