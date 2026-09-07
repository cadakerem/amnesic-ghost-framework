#!/bin/bash
set -e

REPO="/media/veracrypt1/repo"
IFACE=${1:-"wlan0"}
REAL_USER=${SUDO_USER:-kali}
LOG_FILE="/var/log/ghost-setup.log"

# Clear previous log
sudo touch "$LOG_FILE"
sudo chmod 666 "$LOG_FILE"
echo "=== Ghost Mode Setup Log ===" > "$LOG_FILE"

echo "[1/6] Spoofing MAC Address randomly on $IFACE..."
if ! ip link show "$IFACE" > /dev/null 2>&1; then
    echo "? ERROR: Network interface '$IFACE' not found."
    echo "Pass your interface as an argument: sudo bash ghost.sh eth0"
    exit 1
fi

sudo ip link set "$IFACE" down
if ! sudo macchanger -r "$IFACE" >> "$LOG_FILE" 2>&1; then
    echo "? CRITICAL ERROR: macchanger failed to spoof MAC address!"
    echo "Aborting Ghost Mode immediately to prevent physical hardware tracking."
    exit 1
fi
sudo ip link set "$IFACE" up
echo "? MAC spoofing successful."

echo "[2/6] Disabling IPv6 and syncing Timezone to UTC..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >> "$LOG_FILE" 2>&1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 >> "$LOG_FILE" 2>&1
sudo timedatectl set-timezone UTC

echo "[3/6] Installing all privacy packages (Logs in $LOG_FILE)..."
if ! sudo dpkg -i "$REPO"/*.deb >> "$LOG_FILE" 2>&1; then
    echo "? ERROR: Failed to install privacy packages (.deb)."
    echo "Check $LOG_FILE for details."
    exit 1
fi

if ! (cd "$REPO/kali-anonsurf" && sudo bash installer.sh >> "$LOG_FILE" 2>&1); then
    echo "? ERROR: Failed to install Anonsurf."
    echo "Check $LOG_FILE for details."
    exit 1
fi

echo "[4/6] Extracting Mullvad Browser to volatile RAM (/tmp)..."
if [ ! -d "/tmp/mullvad-browser" ]; then
    sudo tar -xf "$REPO"/mullvad-browser-linux-x86_64-*.tar.xz -C /tmp/
    sudo chown -R "$REAL_USER":"$REAL_USER" /tmp/mullvad-browser
fi

# Create a convenient Desktop shortcut for the user
if [ -d "/home/$REAL_USER/Desktop" ]; then
    cat << DESKTOP_EOF | sudo -u "$REAL_USER" tee /home/$REAL_USER/Desktop/Mullvad-Ghost.desktop > /dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=Mullvad Browser (Ghost)
Comment=RAM-based Secure Browser
Exec=/tmp/mullvad-browser/Browser/start-mullvad-browser
Icon=/tmp/mullvad-browser/Browser/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;Security;
DESKTOP_EOF
    sudo chmod +x /home/$REAL_USER/Desktop/Mullvad-Ghost.desktop
fi

echo ""
echo "============================================="
echo "   ?? ATTENTION: WAITING FOR CONNECTION ??"
echo "============================================="
echo "MAC address is spoofed and setup is complete."
echo "Please connect to a WI-FI network now."
echo ""
read -r -p "Press ENTER after the connection is established..."

echo ""
echo "[5/6] Initializing Tor Tunnel (Anonsurf)..."
if ! sudo anonsurf start >> "$LOG_FILE" 2>&1; then
    echo "? CRITICAL ERROR: Anonsurf failed to start."
    echo "Aborting Ghost Mode. You are NOT anonymous."
    exit 1
fi

echo ""
echo "[6/6] Syncing Hardware Clock via Tor Network..."
REAL_TIME=$(curl -sI --max-time 15 https://check.torproject.org | grep -i '^Date:' | sed 's/^[Dd]ate: //g' | tr -d '')
if [ -n "$REAL_TIME" ]; then
    sudo date -s "$REAL_TIME" > /dev/null
    echo "--> System clock successfully synced to UTC!"
else
    echo "--> ? Warning: Could not fetch time via Tor. Tor connection might be dead."
    echo "Aborting."
    sudo anonsurf stop >> "$LOG_FILE" 2>&1
    exit 1
fi

echo ""
echo "[ TEST ] Verifying Tor Connectivity..."
TOR_RESP=$(curl -s --max-time 10 https://check.torproject.org/api/ip || true)
if echo "$TOR_RESP" | grep -q 'IsTor":true'; then
    TOR_IP=$(echo "$TOR_RESP" | grep -oP '"IP":"\K[^"]+')
    echo "? Success! Traffic is routed via Tor (IP: $TOR_IP)."
else
    echo "? CRITICAL ERROR: Tor verification failed!"
    echo "Either there is no internet connection, or traffic is leaking."
    sudo anonsurf stop >> "$LOG_FILE" 2>&1 || true
    exit 1
fi

echo ""
echo ""
echo "=== ?? GHOST MODE ACTIVE ?? ==="
echo "Your browser is ready in RAM. It will leave no trace upon shutdown."
echo "---------------------------------------------"
echo "Run opsec-check.sh for final visual leak verification."
