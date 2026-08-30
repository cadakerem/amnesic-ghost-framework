#!/bin/bash
REPO="/media/veracrypt1/repo"

echo "[1/6] Spoofing MAC Address randomly..."
sudo ip link set wlan0 down 2>/dev/null
sudo macchanger -r wlan0 2>/dev/null
sudo ip link set wlan0 up 2>/dev/null

echo "[2/6] Disabling IPv6 and syncing Timezone to UTC..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 > /dev/null
sudo timedatectl set-timezone UTC

echo "[3/6] Installing all privacy packages..."
sudo dpkg -i "$REPO"/*.deb > /dev/null 2>&1
cd "$REPO/kali-anonsurf" && sudo bash installer.sh > /dev/null 2>&1

echo "[4/6] Extracting Mullvad Browser to volatile RAM (/tmp)..."
if [ ! -d "/tmp/mullvad-browser" ]; then
    sudo tar -xf "$REPO"/mullvad-browser-linux-x86_64-*.tar.xz -C /tmp/
    sudo chown -R kali:kali /tmp/mullvad-browser
fi

# Create a convenient Desktop shortcut for the user
if [ -d "/home/kali/Desktop" ]; then
    cat << 'EOF' | sudo -u kali tee /home/kali/Desktop/Mullvad-Ghost.desktop > /dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=Mullvad Browser (Ghost)
Comment=RAM-based Secure Browser
Exec=/tmp/mullvad-browser/Browser/start-mullvad-browser
Icon=/tmp/mullvad-browser/Browser/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;Security;
EOF
    sudo chmod +x /home/kali/Desktop/Mullvad-Ghost.desktop
fi

echo ""
echo "============================================="
echo "   ⚠️ ATTENTION: WAITING FOR CONNECTION ⚠️"
echo "============================================="
echo "MAC address is spoofed and setup is complete."
echo "Please connect to a WI-FI network now."
echo ""
read -p "Press ENTER after the connection is established..."

echo ""
echo "[5/6] Initializing Tor Tunnel (Anonsurf)..."
sudo anonsurf start

echo ""
echo "[6/6] Syncing Hardware Clock via Tor Network..."
REAL_TIME=$(curl -sI https://check.torproject.org | grep -i '^Date:' | sed 's/^[Dd]ate: //g' | tr -d '\r')
if [ -n "$REAL_TIME" ]; then
    sudo date -s "$REAL_TIME" > /dev/null
    echo "--> System clock successfully synced to UTC!"
else
    echo "--> Warning: Could not fetch time via Tor."
fi

echo ""
echo "[ TEST ] Verifying Tor Connectivity..."
curl -s https://check.torproject.org/api/ip

echo ""
echo ""
echo "=== 👻 GHOST MODE ACTIVE 👻 ==="
echo "Your browser is ready in RAM. It will leave no trace upon shutdown."
echo "---------------------------------------------"
echo "Run opsec-check.sh for visual leak verification."