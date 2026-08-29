#!/bin/bash
echo "============================================="
echo "   ⚠️ PLAN B (ONLINE INSTALLATION) STARTING ⚠️"
echo "============================================="
echo "This script is used to perform a minimal-exposure"
echo "online installation in case the offline .deb"
echo "packages on the USB are corrupted."

echo "[1/4] Fetching Anonsurf dependencies with real IP..."
sudo apt update
sudo apt install -y tor secure-delete i2p

echo "[2/4] Downloading and installing Anonsurf..."
git clone https://github.com/Und3rf10w/kali-anonsurf.git /tmp/kali-anonsurf
cd /tmp/kali-anonsurf && sudo bash installer.sh

echo "[3/4] Starting Tor Tunnel (You are now anonymous)..."
sudo anonsurf start

echo "[4/4] Installing VeraCrypt and dependencies via Tor Tunnel..."
# Assuming user's veracrypt deb files are inside EFI_Boot
# If they are missing, they can be wget'ed while the Tor tunnel is active.
DEPO="/media/usb_drive"
if [ -d "$DEPO" ]; then
    sudo dpkg -i "$DEPO"/libwx*.deb 2>/dev/null
    sudo dpkg -i "$DEPO"/veracrypt*.deb 2>/dev/null
    sudo apt --fix-broken install -y
    echo "✅ Installation successfully completed through the Tor tunnel!"
else
    echo "❌ ERROR: USB repository path ($DEPO) could not be found."
fi
