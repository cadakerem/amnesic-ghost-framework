#!/bin/bash
DEPO="/media/usb_drive"

echo "[1/2] Installing VeraCrypt and dependencies (Offline)..."
sudo dpkg -i "$DEPO"/libwx*.deb
sudo dpkg -i "$DEPO"/veracrypt*.deb

echo "[2/2] Installation complete. Please mount your vault."
echo "To mount via terminal: sudo veracrypt --text $DEPO/hidden_vault.hc /mnt/vault --pim=0 --keyfiles=\"\" --protect-hidden=no"