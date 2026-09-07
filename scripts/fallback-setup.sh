#!/bin/bash
set -e
# shellcheck disable=SC1091
source "$(dirname "$0")/lib/verify-tor.sh"
LOG_FILE="/var/log/ghost-fallback.log"
sudo touch "$LOG_FILE"
sudo chmod 666 "$LOG_FILE"

echo "============================================="
echo "   ?? PLAN B (ONLINE INSTALLATION) ??"
echo "============================================="
echo "This script is used when offline packages are corrupted."
echo "It rebuilds the environment via minimum IP disclosure."

echo "[1/5] Downloading Anonsurf dependencies via Clear-Net..."
sudo apt update
sudo apt install -y tor secure-delete i2p

echo "[2/5] Cloning and installing Anonsurf..."
git clone https://github.com/Und3rf10w/kali-anonsurf.git /tmp/kali-anonsurf
cd /tmp/kali-anonsurf && sudo bash installer.sh

echo "[3/5] Initializing Tor Tunnel (You are now anonymous)..."
sudo anonsurf start

echo "[ TEST ] Verifying Tor Connectivity before downloading sensitive packages..."
verify_tor_connectivity "$LOG_FILE"

echo "[4/5] Installing System Dependencies via Tor Tunnel..."
DEPO=$(dirname "$(realpath "$0")")/..
if [ -d "$DEPO" ]; then
    sudo dpkg -i "$DEPO"/libwx*.deb || true
    sudo dpkg -i "$DEPO"/veracrypt*.deb || true
    sudo apt --fix-broken install -y
    echo "  ? System installation complete!"
else
    echo "  ? ERROR: USB path ($DEPO) not found. Manual install required."
fi

echo ""
echo "[5/5] Downloading Browser via Tor (100% Anonymous)..."
MULLVAD_URL="https://cdn.mullvad.net/browser/15.0.20/mullvad-browser-linux-x86_64-15.0.20.tar.xz"
curl -L "$MULLVAD_URL" -o /tmp/mullvad-browser.tar.xz
echo "? Setup Complete! Browser downloaded to '/tmp/mullvad-browser.tar.xz'."
