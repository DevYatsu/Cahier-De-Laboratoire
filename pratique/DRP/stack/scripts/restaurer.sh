#!/usr/bin/env bash
# Restauration du stack depuis la copie WORM (DRP, CSF RC.RP).
# Prérequis : le dépôt (configurations), le kit hors ligne ($KIT : clé age + accès WORM), le projet « hors-stack » en marche.
# Usage : scripts/restaurer.sh [ID]     (sans ID : la sauvegarde la plus récente du WORM)
cd "$(dirname "$0")/.."
source scripts/commun.sh

log "=== RESTAURATION : début du chronomètre (RTO) ==="

# 1. La copie WORM est joignable, et on choisit la sauvegarde.
ID="${1:-$(s3 s3 ls s3://sauvegardes/ | awk '{print $2}' | tr -d / | sort | tail -1)}"
[ -n "$ID" ] || { ko "aucune sauvegarde dans le WORM"; exit 1; }
ok "sauvegarde choisie : $ID"

# 2. Téléchargement depuis le WORM (pas depuis le disque local : il peut être perdu ou compromis).
DIR="restauration/$ID"
rm -rf "$DIR"; mkdir -p "$DIR"
s3 s3 cp "s3://sauvegardes/$ID/" "$DIR/" --recursive --only-show-errors
ok "téléchargée : $(ls "$DIR" | wc -l | tr -d ' ') fichiers, $(du -sh "$DIR" | cut -f1)"

# 3. Vérifier la sauvegarde AVANT de s'en servir (CSF RC.RP-03) : intégrité, puis déchiffrement.
( cd "$DIR" && sha256 -c SHA256SUMS --quiet ) && ok "empreintes SHA-256 conformes" || { ko "empreintes : sauvegarde corrompue, ARRÊT"; exit 1; }
age -d -i "$AGE_ID" "$DIR/secrets.tar.gz.age" | tar tzf - >/dev/null && ok "déchiffrement age vérifié" || { ko "clé age invalide, ARRÊT"; exit 1; }

# 4. Secrets : restaurés seulement s'ils manquent (poste neuf ou dossier effacé).
if [ ! -s secrets/grafana/admin-user ]; then
  age -d -i "$AGE_ID" "$DIR/secrets.tar.gz.age" | tar xzf -
  ok "secrets et .env restaurés depuis l'archive chiffrée"
else
  ok "secrets présents sur le poste : conservés"
fi
# Le certificat d'entrée de l'archive est signé par la CA mkcert de l'ancien poste : régénéré si besoin.
scripts/cert-entree.sh >/dev/null && ok "certificat d'entrée valable pour ce poste" || { ko "certificat d'entrée, ARRÊT"; exit 1; }

# 5. Le piège : démarrer une fois, pour que Podman crée les volumes avec les bons propriétaires.
compose up -d >/dev/null
attendre 120 sh -c "podman ps --filter name=drp-grafana --filter status=running -q | grep -q ."
compose stop >/dev/null
ok "volumes recréés par un premier démarrage, stack arrêté"

# 6. Import. « volume import » fusionne : on vide d'abord le volume (sans toucher à sa racine),
#    sinon les fichiers écrits au premier démarrage (WAL Prometheus, index Loki) se mêlent aux données restaurées.
for V in "${VOLUMES[@]}"; do
  podman run --rm -v "${PROJET}_$V:/v" docker.io/library/alpine:latest \
    sh -c 'find /v -mindepth 1 -delete'
  age -d -i "$AGE_ID" "$DIR/$V.tar.gz.age" | gunzip | podman volume import "${PROJET}_$V" -
  ok "$V importé"
done

# 7. Redémarrage et vérification de bout en bout (CSF RC.RP-05).
compose start >/dev/null
ok "stack redémarré"
cp "$DIR/temoins.env" "$DEPOT_LOCAL/temoins-restauration.env" 2>/dev/null || true
T_RESTAURE=$(( $(date +%s) - T0 ))

if scripts/verifier.sh "$DIR/temoins.env"; then
  log "=== SERVICE RÉTABLI ET VÉRIFIÉ : RTO mesuré = $(( $(date +%s) - T0 )) s (dont restauration $T_RESTAURE s) ==="
else
  log "=== ÉCHEC DES VÉRIFICATIONS après $(( $(date +%s) - T0 )) s : la restauration n'est PAS réussie ==="
  exit 1
fi
