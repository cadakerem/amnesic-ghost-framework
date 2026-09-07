#!/bin/bash
set -e
set -o pipefail

DEPO=$(dirname "$(realpath "$0")")/..

echo "[1/2] Installing System Dependencies (Offline)..."

if ls "$DEPO"/libwx*.deb 1> /dev/null 2>&1 && ls "$DEPO"/veracrypt*.deb 1> /dev/null 2>&1; then
    sudo dpkg -i "$DEPO"/libwx*.deb
    sudo dpkg -i "$DEPO"/veracrypt*.deb
else
    echo "? ERROR: System packages not found in $DEPO!"
    echo "Please download them manually or run fallback-setup.sh."
    exit 1
fi

echo "[2/2] Installation complete. You may now load your storage container."
echo "Command hint: sudo veracrypt -t /path/to/container /mnt/vault"
