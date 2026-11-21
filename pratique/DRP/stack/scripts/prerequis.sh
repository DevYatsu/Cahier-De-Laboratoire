#!/usr/bin/env bash
# Vérification des outils du poste (macOS ou Linux). À sourcer.

# Commande d'installation selon le système, pour un message d'erreur directement utilisable.
paquet() {  # outil
  local p=$1
  case "$(uname -s)" in
    Darwin) [ "$p" = openssl ] && p=openssl@3; echo "Installer : brew install $p" ;;
    Linux)
      [ "$p" = certutil ] && { echo "Installer : sudo apt install libnss3-tools  (ou sudo dnf install nss-tools)"; return; }
      [ "$p" = age ] && { echo "Installer : sudo apt install age  (ou sudo dnf install age)"; return; }
      echo "Installer : sudo apt install $p  (ou sudo dnf install $p)" ;;
    *) echo "Système non pris en charge : $(uname -s)" ;;
  esac
}

# OpenSSL 3 ou plus : `-copy_extensions` et `-addext` n'existent pas dans LibreSSL, l'openssl de macOS.
choisir_openssl() {
  local c
  for c in openssl /opt/homebrew/opt/openssl@3/bin/openssl /usr/local/opt/openssl@3/bin/openssl; do
    command -v "$c" >/dev/null 2>&1 || continue
    "$c" version | grep -qE '^OpenSSL ([3-9]|[1-9][0-9])\.' && { echo "$c"; return; }
  done
  return 1
}

exiger() {  # outils…
  local t manque=0
  for t in "$@"; do
    if [ "$t" = openssl ]; then
      OPENSSL=$(choisir_openssl) || { echo "MANQUANT : OpenSSL 3 ou plus (LibreSSL ne convient pas). $(paquet openssl)" >&2; manque=1; }
    elif ! command -v "$t" >/dev/null 2>&1; then
      echo "MANQUANT : $t. $(paquet "$t")" >&2; manque=1
    fi
  done
  [ "$manque" -eq 0 ] || exit 1
}
