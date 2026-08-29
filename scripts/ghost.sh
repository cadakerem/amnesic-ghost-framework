#!/bin/bash
REPO="/media/veracrypt_vault/repo"

echo "[1/6] Spoofing MAC Address randomly..."
sudo ip link set wlan0 down 2>/dev/null
sudo macchanger -r wlan0 2>/dev/null
sudo ip link set wlan0 up 2>/dev/null

echo "[2/6] Disabling IPv6 and setting Timezone to UTC..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 > /dev/null
sudo timedatectl set-timezone UTC

echo "[3/6] Installing all privacy packages from vault repository..."
sudo dpkg -i "$REPO"/*.deb > /dev/null 2>&1
cd "$REPO/kali-anonsurf" && sudo bash installer.sh > /dev/null 2>&1

echo "[4/6] Hardening Firefox into 'Tor Mode' (Anti-Fingerprint)..."
sudo mkdir -p /etc/firefox-esr
echo 'pref("privacy.resistFingerprinting", true);' | sudo tee /etc/firefox-esr/syspref.js > /dev/null

echo ""
echo "============================================="
echo "   ⚠️ ATTENTION: WAITING FOR CONNECTION ⚠️"
echo "============================================="
echo "Your MAC address has been spoofed and installations are complete."
echo "Please connect to a WI-FI network from the top right corner now."
echo ""
read -p "Press ENTER after the connection is established..."

echo ""
echo "[5/6] Starting Tor Tunnel (Anonsurf)..."
sudo anonsurf start

echo ""
echo "[6/6] Syncing UTC Time securely via Tor network..."
# Fetch the real UTC time from the Tor network and sync the system
REAL_TIME=$(curl -sI https://check.torproject.org | grep -i '^Date:' | sed 's/^[Dd]ate: //g' | tr -d '\r')
if [ -n "$REAL_TIME" ]; then
    sudo date -s "$REAL_TIME" > /dev/null
    echo "--> System time perfectly synced to real UTC time!"
else
    echo "--> Warning: Could not fetch time from the internet."
fi

echo ""
echo "[ TEST ] Verifying Tor connection..."
curl -s https://check.torproject.org/api/ip

echo ""
echo ""
echo "=== 👻 GHOST MODE ACTIVE 👻 ==="
echo "You can now open the standard Kali Firefox (it will act entirely like Tor Browser)."
echo "Visual Verification Sites:"
echo " 1. check.torproject.org (IP Test)"
echo " 2. dnsleaktest.com (DNS Leak Test)"
echo " 3. browserleaks.com/javascript (Time & Fingerprint Test)"
echo "---------------------------------------------"
echo "Your vault is ready for use."