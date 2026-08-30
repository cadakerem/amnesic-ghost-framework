#!/bin/bash

echo "============================================="
echo "   🛡️ OPSEC INSPECTOR (VERIFICATION) 🛡️"
echo "============================================="
echo "This script verifies the privacy constraints"
echo "and launches test sites for visual confirmation."
echo "---------------------------------------------"

echo "[1/4] Network Interfaces and MAC Address"
ip link show | grep -E "link/ether" | awk '{print "  " $2}'
echo "(Ensure this MAC differs from your hardware MAC)"
echo ""

echo "[2/4] IPv6 Status (Must be disabled)"
IPV6_STATE=$(sysctl -n net.ipv6.conf.all.disable_ipv6)
if [ "$IPV6_STATE" -eq 1 ]; then
    echo "  ✅ IPv6 is successfully disabled."
else
    echo "  ❌ WARNING: IPv6 is still active! Potential leak."
fi
echo ""

echo "[3/4] System Clock and Timezone (Must be UTC)"
timedatectl | grep -E "Time zone|Local time"
echo ""

echo "[4/4] Tor Network Exit Node Verification"
TOR_IP=$(curl -s --max-time 10 https://check.torproject.org/api/ip | grep -oP '"IP":"\K[^"]+')
if [ -n "$TOR_IP" ]; then
    echo "  ✅ Active Tor IP Address: $TOR_IP"
else
    echo "  ❌ WARNING: Unreachable Tor Network or Leaking!"
fi
echo "============================================="
echo "Launching Mullvad Browser from RAM for visual verification..."
echo "Please review the test results in the newly opened tabs."

if [ -n "$SUDO_USER" ]; then
    NORMAL_USER="$SUDO_USER"
else
    NORMAL_USER="kali"
fi

sudo -u "$NORMAL_USER" env DISPLAY="${DISPLAY:-:0}" XAUTHORITY="${XAUTHORITY:-/home/$NORMAL_USER/.Xauthority}" /tmp/mullvad-browser/Browser/start-mullvad-browser \
    "https://check.torproject.org/" \
    "https://dnsleaktest.com/" \
    "https://browserleaks.com/webrtc" \
    "https://browserleaks.com/javascript" \
    "https://amiunique.org/" > /dev/null 2>&1 &

echo "Verification complete. Check your browser."
