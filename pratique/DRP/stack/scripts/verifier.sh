#!/usr/bin/env bash
# Vérifications après restauration (CSF RC.RP-05) : le service répond ET les données sont revenues.
# Une restauration est réussie quand le service répond, pas quand l'import a réussi.
# Usage : scripts/verifier.sh [fichier temoins.env]
cd "$(dirname "$0")/.."
source scripts/commun.sh
TEMOINS="${1:-$DEPOT_LOCAL/temoins.env}"
# shellcheck disable=SC1090
source "$TEMOINS"

# 1. Conteneurs : tous « Up », aucun en redémarrage (le piège Grafana se voit ici).
N_UP=$(podman ps --filter "label=com.docker.compose.project=$PROJET" --filter status=running --format '{{.Names}}' | wc -l | tr -d ' ')
[ "$N_UP" -eq 11 ] && ok "11/11 conteneurs en marche" || ko "$N_UP/11 conteneurs en marche"

# 2. Entrée et SSO.
attendre 90 sso_login && ok "SSO : connexion Authelia" || ko "SSO : connexion Authelia"
grafana_ok() { via_sso grafana /api/health | grep -q ok; }
attendre 60 grafana_ok \
  && ok "Grafana répond derrière Traefik + Authelia" || ko "Grafana ne répond pas"

# 3. grafana-data : le dashboard témoin, créé dans l'interface.
via_sso grafana /api/dashboards/uid/drp-temoin | grep -q "$ID" \
  && ok "grafana-data : dashboard « Témoin DRP $ID »" || ko "grafana-data : dashboard témoin absent"
# Le compte SSO est retrouvé (pas recréé) : même identifiant interne qu'avant.
via_sso grafana /api/user | grep -q '"isGrafanaAdmin":true' && ok "grafana-data : compte administrateur" || ko "grafana-data : compte"

# 4. loki-data : le log témoin, écrit AVANT la sauvegarde, par la chaîne de lecture mTLS (CA reader).
# Le marqueur est cherché dans les logs d'accès de Traefik (label container="traefik").
loki_contient() {
  local q; q=$(jq -rn --arg q "{container=\"traefik\"} |= \"$1\"" '$q|@uri')
  via_sso grafana "/api/datasources/proxy/uid/loki/loki/api/v1/query_range?since=24h&limit=5&query=$q" | grep -q "$1"
}
attendre 120 loki_contient "$ID" \
  && ok "loki-data : log témoin $ID retrouvé" || ko "loki-data : log témoin absent"
# Règles LogQL rechargées (ruler).
via_sso grafana /api/datasources/proxy/uid/loki/loki/api/v1/rules | grep -q BruteForceLogin \
  && ok "Loki : règle BruteForceLogin chargée" || ko "Loki : règles absentes"

# 5. Collecte reprise : un nouveau log, écrit APRÈS la restauration, arrive dans Loki (Alloy, mTLS ingest).
APRES="apres-restauration-$(date +%s)"
curl -s -o /dev/null "https://juiceshop.drp.localhost:$HTTPS_PORT/$APRES"
attendre 90 loki_contient "$APRES" \
  && ok "collecte : nouveau log reçu par Loki" || ko "collecte : aucun nouveau log"

# 6. prometheus-data : la série up{job="juice-shop"} existe à l'instant témoin (historique conservé).
V=$(podman exec drp-prometheus wget -qO- "http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22juice-shop%22%7D&time=$T_PROM" | jq -r '.data.result[0].value[1] // "absent"')
[ "$V" = "1" ] && ok "prometheus-data : up{job=juice-shop} = 1 à l'instant témoin" || ko "prometheus-data : historique absent ($V)"
cibles_up() { podman exec drp-prometheus wget -qO- 'http://localhost:9090/api/v1/targets?state=active' | jq -e '[.data.activeTargets[] | select(.health=="up")] | length == 9'; }
attendre 60 cibles_up \
  && ok "Prometheus : 9/9 cibles up" || ko "Prometheus : cibles en échec"

# 7. alertmanager-data : le silence témoin.
podman exec drp-alertmanager wget -qO- http://localhost:9093/api/v2/silences | grep -q "$ID" \
  && ok "alertmanager-data : silence $ID" || ko "alertmanager-data : silence absent"

# 8. authelia-data : base lisible avec la clé de chiffrement, TOTP identiques.
podman exec drp-authelia authelia storage encryption check --config /config/configuration.yml 2>&1 | grep -q SUCCESS \
  && ok "authelia-data : clé de chiffrement valide" || ko "authelia-data : clé de chiffrement"
T=$(podman exec drp-authelia authelia storage user totp export uri --config /config/configuration.yml 2>/dev/null | grep otpauth | sha256 | cut -c1-16)
[ "$T" = "$TOTP" ] && ok "authelia-data : TOTP identiques ($T)" || ko "authelia-data : TOTP ($T != $TOTP)"

# 9. Chaîne d'alerte : le Watchdog repart vers le heartbeat externe.
heartbeat_recu() { podman logs --since 90s heartbeat 2>&1 | grep -q 'POST /ping'; }
attendre 120 heartbeat_recu \
  && ok "alerte : Watchdog reçu par le heartbeat externe" || ko "alerte : heartbeat silencieux"

log "vérifications terminées : $ECHECS échec(s)"
exit "$ECHECS"
