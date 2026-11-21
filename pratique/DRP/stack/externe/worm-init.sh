#!/bin/sh
# Crée les buckets WORM (Object Lock, mode compliance). Idempotent : un bucket existant est conservé.
set -eu
S3="aws --endpoint-url http://worm:9000"

# Attendre que le stockage réponde.
i=0
until $S3 s3api list-buckets >/dev/null 2>&1; do
  i=$((i + 1)); [ "$i" -gt 30 ] && { echo "worm injoignable"; exit 1; }
  sleep 1
done

for B in logs sauvegardes; do
  if $S3 s3api head-bucket --bucket "$B" >/dev/null 2>&1; then
    echo "bucket $B : déjà présent"
  else
    $S3 s3api create-bucket --bucket "$B" --object-lock-enabled-for-bucket >/dev/null
    echo "bucket $B : créé"
  fi
  # Rétention par défaut, appliquée à chaque nouvel objet. Labo : 1 jour ; production : 365 jours.
  $S3 s3api put-object-lock-configuration --bucket "$B" --object-lock-configuration \
    "{\"ObjectLockEnabled\":\"Enabled\",\"Rule\":{\"DefaultRetention\":{\"Mode\":\"COMPLIANCE\",\"Days\":${RETENTION_JOURS}}}}"
done
$S3 s3api get-object-lock-configuration --bucket sauvegardes
