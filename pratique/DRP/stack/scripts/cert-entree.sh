#!/usr/bin/env bash
# Certificat TLS de l'entrée (Traefik, vu par le navigateur), pour macOS et Linux.
#
# Signé par la CA locale de mkcert, que `mkcert -install` déclare de confiance sur CE poste
# (trousseau macOS, magasin système Linux, et NSS pour Firefox et Chrome sous Linux).
# Régénéré s'il manque, s'il est illisible, s'il ne couvre pas tous les noms, s'il expire dans
# moins de 30 jours, ou s'il est signé par la CA d'un autre poste (restauration sur un poste neuf).
# Sans certificat valable, Traefik (sniStrict) répond SSL_ERROR_UNRECOGNIZED_NAME_ALERT.
#
# Usage : scripts/cert-entree.sh        (idempotent ; relance Traefik s'il tourne et que le certificat change)
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/prerequis.sh

DOMAINE=drp.localhost
NOMS=(auth grafana juiceshop prometheus alertmanager cadvisor alloy)
DIR=secrets/edge
CERT=$DIR/cert.pem
KEY=$DIR/key.pem

exiger mkcert openssl
[ "$(uname -s)" = Linux ] && ! command -v certutil >/dev/null \
  && echo "ATTENTION : certutil absent, Firefox et Chrome ne feront pas confiance au certificat. $(paquet certutil)" >&2

# Idempotent. Sous macOS, demande le mot de passe administrateur la première fois (trousseau système).
mkcert -install
CA="$(mkcert -CAROOT)/rootCA.pem"

# Retourne le motif de régénération, ou rien si le certificat convient.
probleme() {
  [ -s "$CERT" ] && [ -s "$KEY" ] || { echo "absent"; return; }
  $OPENSSL x509 -in "$CERT" -noout 2>/dev/null || { echo "illisible"; return; }
  # Une clé qui ne correspond pas au certificat fait échouer Traefik au chargement, sans arrêter le conteneur.
  [ "$($OPENSSL x509 -in "$CERT" -noout -pubkey)" = "$($OPENSSL pkey -in "$KEY" -pubout 2>/dev/null)" ] \
    || { echo "clé et certificat ne correspondent pas"; return; }
  $OPENSSL x509 -in "$CERT" -noout -checkend $((30 * 86400)) >/dev/null || { echo "expire dans moins de 30 jours"; return; }
  $OPENSSL verify -CAfile "$CA" "$CERT" >/dev/null 2>&1 || { echo "signé par la CA d'un autre poste"; return; }
  local san; san=$($OPENSSL x509 -in "$CERT" -noout -ext subjectAltName)
  for n in "${NOMS[@]}"; do
    grep -qE "DNS:$n\.${DOMAINE//./\\.}(,|$)" <<<"$san" || { echo "nom manquant : $n.$DOMAINE"; return; }
  done
}

MOTIF=$(probleme)
if [ -z "$MOTIF" ]; then
  echo "Certificat d'entrée valable : $CERT"
  exit 0
fi

echo "Certificat d'entrée à (re)générer : $MOTIF"
mkdir -p "$DIR"
mkcert -cert-file "$CERT" -key-file "$KEY" "${NOMS[@]/%/.$DOMAINE}"
# Lisible par Traefik dans le conteneur, quel que soit l'uid projeté (Podman rootless, Podman machine).
chmod 644 "$CERT" "$KEY"

MOTIF=$(probleme)
[ -z "$MOTIF" ] || { echo "ÉCHEC : certificat généré mais invalide ($MOTIF)" >&2; exit 1; }
echo "Certificat d'entrée généré : $CERT"

# Traefik ne relit pas les fichiers de certificat modifiés : il faut le relancer.
if podman ps -q --filter name=^drp-traefik$ --filter status=running 2>/dev/null | grep -q .; then
  podman restart drp-traefik >/dev/null && echo "Traefik relancé"
fi
