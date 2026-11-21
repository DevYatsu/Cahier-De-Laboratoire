#!/usr/bin/env bash
# Génère tous les secrets du stack dans secrets/ (ignoré par git). Idempotent : un secret existant est conservé.
# Prérequis sur le poste (macOS ou Linux) : mkcert, OpenSSL 3, age, podman ; vérifiés au démarrage.
#
#   secrets/edge/        certificat TLS de Traefik (scripts/cert-entree.sh, mkcert, *.drp.localhost)
#   secrets/ca/          clés des trois CA internes : gate (serveur), ingest (écriture), reader (lecture). Jamais montées.
#   secrets/gate/        certificat serveur de loki-gate + certificats (publics) des CA ingest et reader
#   secrets/ingest/      certificat client d'Alloy (CA ingest)
#   secrets/reader/      certificat client de Grafana (CA reader)
#   secrets/authelia/    secrets de session, clé de chiffrement de la base, compte SSO (argon2id)
#   secrets/grafana/     compte administrateur Grafana (même nom que le compte SSO)
#   secrets/worm-*/      comptes du stockage WORM (hors du stack)
#   ~/.config/drp/age-identity.txt   clé privée de déchiffrement des sauvegardes, HORS du dossier du stack
set -euo pipefail
cd "$(dirname "$0")"
source scripts/prerequis.sh
exiger mkcert openssl age age-keygen podman

S=secrets
AGE_ID="${AGE_IDENTITY:-$HOME/.config/drp/age-identity.txt}"
MD=identifiants.md
mkdir -p $S/{edge,ca,gate,ingest,reader,authelia,grafana,worm-root,worm-alloy}

rnd() { $OPENSSL rand -base64 "$1" | tr '+/' '-_' | tr -d '=\n'; }
new() { [ ! -s "$1" ]; }

# --- TLS de l'entrée (navigateur) ---------------------------------------------------------------
scripts/cert-entree.sh

# --- CA internes ----------------------------------------------------------------------------------
ca() {  # nom
  if new $S/ca/$1-ca.pem; then
    $OPENSSL ecparam -name prime256v1 -genkey -noout -out $S/ca/$1-ca-key.pem
    $OPENSSL req -x509 -new -key $S/ca/$1-ca-key.pem -sha256 -days 825 -subj "/CN=drp $1 CA" \
      -addext "basicConstraints=critical,CA:TRUE" -addext "keyUsage=critical,keyCertSign,cRLSign" \
      -out $S/ca/$1-ca.pem
  fi
}
leaf() {  # ca, dossier, nom, usage (serverAuth|clientAuth), SAN
  if new $S/$2/$3-cert.pem; then
    $OPENSSL ecparam -name prime256v1 -genkey -noout -out $S/$2/$3-key.pem
    $OPENSSL req -new -key $S/$2/$3-key.pem -subj "/CN=$3" \
      -addext "subjectAltName=$5" -addext "extendedKeyUsage=$4" -out $S/$2/$3.csr
    $OPENSSL x509 -req -in $S/$2/$3.csr -CA $S/ca/$1-ca.pem -CAkey $S/ca/$1-ca-key.pem -CAcreateserial \
      -copy_extensions copy -days 825 -sha256 -out $S/$2/$3-cert.pem 2>/dev/null
    rm -f $S/$2/$3.csr
  fi
}
ca gate; ca ingest; ca reader
leaf gate   gate   gate    serverAuth "DNS:loki-push,DNS:loki-query,DNS:loki-gate"
leaf ingest ingest alloy   clientAuth "DNS:alloy"
leaf reader reader grafana clientAuth "DNS:grafana"
cp $S/ca/ingest-ca.pem $S/ca/reader-ca.pem $S/gate/
cp $S/ca/gate-ca.pem $S/ingest/
cp $S/ca/gate-ca.pem $S/reader/

# --- Authelia : secrets et compte SSO -------------------------------------------------------------
for F in session storage jwt; do new $S/authelia/$F && rnd 48 > $S/authelia/$F; done
if new $S/authelia/users.yml; then
  U="admin-$(rnd 4 | tr 'A-Z_-' 'a-zxy')"; P="$(rnd 18)"
  H=$(podman run --rm docker.io/authelia/authelia:4.39 authelia crypto hash generate argon2 --password "$P" | sed 's/^Digest: //')
  cat > $S/authelia/users.yml <<EOF
users:
  $U:
    displayname: "Administrateur DRP"
    email: $U@drp.localhost
    password: "$H"
    groups: [admins]
EOF
  printf '%s' "$U" > $S/grafana/admin-user
  rnd 18 > $S/grafana/admin-password
  { echo "# Identifiants générés (à mettre dans un gestionnaire de mots de passe, puis supprimer ce fichier)"; echo;
    echo "- SSO Authelia (https://auth.drp.localhost) : \`$U\` / \`$P\`"; } >> $MD
fi

# --- Stockage WORM (hors du stack) ----------------------------------------------------------------
if new $S/worm-root/root-user; then
  printf 'worm-%s' "$(rnd 6)" > $S/worm-root/root-user
  rnd 24 > $S/worm-root/root-password
  printf '[default]\naws_access_key_id = %s\naws_secret_access_key = %s\n' \
    "$(cat $S/worm-root/root-user)" "$(cat $S/worm-root/root-password)" > $S/worm-root/credentials
  cp $S/worm-root/credentials $S/worm-alloy/credentials
fi

# --- Clé de chiffrement des sauvegardes (age) -----------------------------------------------------
# La clé privée vit hors du dossier du stack : en production, hors ligne (coffre, papier, gestionnaire).
if [ ! -s "$AGE_ID" ]; then
  mkdir -p "$(dirname "$AGE_ID")"; age-keygen -o "$AGE_ID" 2>/dev/null; chmod 600 "$AGE_ID"
fi
age-keygen -y "$AGE_ID" > $S/age-recipient.txt
# Accès au WORM, rangé avec la clé : sans lui, impossible de relire les sauvegardes après un sinistre complet.
cp $S/worm-root/credentials "$(dirname "$AGE_ID")/worm-credentials"; chmod 600 "$(dirname "$AGE_ID")/worm-credentials"

# Lisibles par les services (uid non root dans les conteneurs) ; les clés des CA restent privées.
find $S -type f -not -path "$S/ca/*" -exec chmod 644 {} +
chmod 600 $S/ca/*-key.pem
[ -f $MD ] && chmod 600 $MD
echo "Secrets prêts dans $S/ ; clé de déchiffrement des sauvegardes : $AGE_ID"
