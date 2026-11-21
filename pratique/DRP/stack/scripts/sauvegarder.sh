#!/usr/bin/env bash
# Sauvegarde du stack (DRP, stratégie 3-2-1) :
#   1. arrêt du stack (sauvegarde cohérente : bases SQLite et TSDB fermées) ;
#   2. export de chaque volume, compressé (gzip) puis chiffré (age, clé publique) ;
#   3. archive chiffrée des secrets (certificats, clés des CA, comptes) ;
#   4. empreintes SHA-256, redémarrage ;
#   5. copie dans le bucket WORM « sauvegardes » (Object Lock, compliance), puis vérification de la copie.
# Usage : scripts/sauvegarder.sh            (depuis n'importe où)
cd "$(dirname "$0")/.."
source scripts/commun.sh

ID=$(date -u +%Y%m%dT%H%M%SZ)
DIR="$DEPOT_LOCAL/$ID"
RCPT=$(cat secrets/age-recipient.txt)
mkdir -p "$DIR"
log "sauvegarde $ID -> $DIR"

compose stop >/dev/null
T_ARRET=$(date +%s)
ok "stack arrêté (début de l'interruption de service)"

for V in "${VOLUMES[@]}"; do
  podman volume export "${PROJET}_$V" | gzip -6 | age -r "$RCPT" > "$DIR/$V.tar.gz.age"
  [ -s "$DIR/$V.tar.gz.age" ] && ok "$V : $(du -h "$DIR/$V.tar.gz.age" | cut -f1)" || ko "$V : archive vide"
done

compose start >/dev/null
ok "stack redémarré (interruption : $(( $(date +%s) - T_ARRET )) s)"

# Secrets : hors du dépôt git, indispensables pour reconstruire sur un poste neuf.
tar czf - secrets .env | age -r "$RCPT" > "$DIR/secrets.tar.gz.age"
ok "secrets : $(du -h "$DIR/secrets.tar.gz.age" | cut -f1)"
[ -f "$DEPOT_LOCAL/temoins.env" ] && cp "$DEPOT_LOCAL/temoins.env" "$DIR/"

# Empreintes : vérifiées AVANT toute restauration (CSF RC.RP-03).
( cd "$DIR" && sha256 *.age > SHA256SUMS )
ok "empreintes SHA-256 : $DIR/SHA256SUMS"

# Copie hors du stack, immuable : même un administrateur du stack compromis ne peut pas l'effacer.
s3 s3 cp "$DIR" "s3://sauvegardes/$ID/" --recursive --only-show-errors
N_LOCAL=$(ls "$DIR" | wc -l | tr -d ' ')
N_WORM=$(s3 s3 ls "s3://sauvegardes/$ID/" | wc -l | tr -d ' ')
[ "$N_LOCAL" = "$N_WORM" ] && ok "WORM : $N_WORM/$N_LOCAL fichiers dans s3://sauvegardes/$ID/" || ko "WORM : $N_WORM/$N_LOCAL fichiers"
RET=$(s3 s3api get-object-retention --bucket sauvegardes --key "$ID/SHA256SUMS" --query 'Retention.[Mode,RetainUntilDate]' --output text)
ok "WORM : rétention $RET"

log "taille totale : $(du -sh "$DIR" | cut -f1) ; échecs : $ECHECS"
exit "$ECHECS"
