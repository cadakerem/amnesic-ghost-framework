#!/bin/bash
set -e

DEPO="/run/media/kali/USB_DRIVE"

echo "[1/2] Installing VeraCrypt and dependencies (Offline)..."

if ls "$DEPO"/libwx*.deb 1> /dev/null 2>&1 && ls "$DEPO"/veracrypt*.deb 1> /dev/null 2>&1; then
    sudo dpkg -i "$DEPO"/libwx*.deb
    sudo dpkg -i "$DEPO"/veracrypt*.deb
else
    echo "❌ ERROR: VeraCrypt packages not found in $DEPO!"
    echo "Please download them manually or run fallback-setup.sh."
    exit 1
fi

echo "[2/2] Installation complete. Please mount your vault."
echo "To mount via terminal: sudo veracrypt --text $DEPO/hidden_vault.hc /mnt/vault --pim=0 --keyfiles=\"\" --protect-hidden=no"