#!/bin/bash
echo "============================================="
echo "   ⚠️ PLAN B (ONLINE INSTALLATION) ⚠️"
echo "============================================="
echo "This script is used when offline deb packages"
echo "are corrupted. It rebuilds the environment"
echo "via minimum IP disclosure."

echo "[1/4] Downloading Anonsurf dependencies via Clear-Net..."
sudo apt update
sudo apt install -y tor secure-delete i2p

echo "[2/4] Cloning and installing Anonsurf..."
git clone https://github.com/Und3rf10w/kali-anonsurf.git /tmp/kali-anonsurf
cd /tmp/kali-anonsurf && sudo bash installer.sh

echo "[3/4] Initializing Tor Tunnel (You are now anonymous)..."
sudo anonsurf start

echo "[4/5] Installing VeraCrypt and dependencies via Tor Tunnel..."
DEPO="/run/media/kali/EFI_Boot"
if [ -d "$DEPO" ]; then
    sudo dpkg -i "$DEPO"/libwx*.deb 2>/dev/null
    sudo dpkg -i "$DEPO"/veracrypt*.deb 2>/dev/null
    sudo apt --fix-broken install -y
    echo "  ✅ VeraCrypt installation complete!"
else
    echo "  ❌ ERROR: USB path ($DEPO) not found. Manual install required."
fi

echo ""
echo "[5/5] Downloading Mullvad Browser via Tor (100% Anonymous)..."
MULLVAD_URL="https://cdn.mullvad.net/browser/15.0.20/mullvad-browser-linux-x86_64-15.0.20.tar.xz"
curl -L "$MULLVAD_URL" -o /tmp/mullvad-browser.tar.xz
echo "✅ Setup Complete! Mullvad Browser downloaded to '/tmp/mullvad-browser.tar.xz'."
echo "Extract this archive into your new encrypted vault."
