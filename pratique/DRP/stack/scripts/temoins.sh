#!/usr/bin/env bash
# Crée un témoin dans chaque volume, juste avant la sauvegarde. Après restauration, verifier.sh
# les retrouve : c'est la preuve que les données (et pas seulement les conteneurs) sont revenues.
cd "$(dirname "$0")/.."
source scripts/commun.sh

ID="temoin-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$DEPOT_LOCAL"
sso_login || { ko "connexion SSO"; exit 1; }

# grafana-data : un dashboard créé dans l'interface (non provisionné, absent du dépôt).
via_sso grafana /api/dashboards/db -X POST -H 'Content-Type: application/json' \
  -d "{\"dashboard\":{\"uid\":\"drp-temoin\",\"title\":\"Témoin DRP $ID\",\"panels\":[]},\"overwrite\":true}" \
  | grep -q "\"status\":\"success\"" && ok "grafana-data : dashboard « Témoin DRP $ID »" || ko "grafana-data : dashboard témoin"

# loki-data : une requête marquée sur Juice Shop, journalisée par Traefik puis stockée dans Loki.
curl -s -o /dev/null "https://juiceshop.drp.localhost:$HTTPS_PORT/$ID"
loki_contient() {
  local q; q=$(jq -rn --arg q "{container=\"traefik\"} |= \"$1\"" '$q|@uri')
  via_sso grafana "/api/datasources/proxy/uid/loki/loki/api/v1/query_range?since=10m&limit=5&query=$q" | grep -q "$1"
}
attendre 60 loki_contient "$ID" \
  && ok "loki-data : log d'accès contenant $ID"

# prometheus-data : l'instant T, pour relire up{job=\"juice-shop\"} à ce moment-là après restauration.
T_PROM=$(date +%s)
ok "prometheus-data : instant de référence $T_PROM"

# alertmanager-data : un silence (créé par l'astreinte pendant un incident).
# Fin du silence dans 7 jours : `date -d` (GNU, Linux), sinon `date -v` (BSD, macOS).
FIN_SILENCE=$(date -u -d '+7 days' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+7d +%Y-%m-%dT%H:%M:%SZ)
podman exec drp-alertmanager wget -qO- --header 'Content-Type: application/json' --post-data \
  "{\"matchers\":[{\"name\":\"alertname\",\"value\":\"CibleInjoignable\",\"isRegex\":false}],\"startsAt\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"endsAt\":\"$FIN_SILENCE\",\"createdBy\":\"drp\",\"comment\":\"$ID\"}" \
  http://localhost:9093/api/v2/silences >/dev/null && ok "alertmanager-data : silence $ID"

# authelia-data : empreinte des configurations TOTP (le secret n'est jamais affiché).
TOTP=$(podman exec drp-authelia authelia storage user totp export uri --config /config/configuration.yml 2>/dev/null \
  | grep otpauth | sha256 | cut -c1-16)
ok "authelia-data : empreinte TOTP $TOTP"

printf 'ID=%s\nT_PROM=%s\nTOTP=%s\n' "$ID" "$T_PROM" "$TOTP" > "$DEPOT_LOCAL/temoins.env"
log "témoins enregistrés dans $DEPOT_LOCAL/temoins.env"
