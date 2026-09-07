#!/bin/bash
set -e
source "$(dirname "$0")/lib/verify-tor.sh"

echo "============================================="
echo "   ??? OPSEC INSPECTOR (VERIFICATION) ???"
echo "============================================="

echo "[1/4] Network Interfaces and MAC Address"
ip link show | grep -E "link/ether" | awk '{print "  " $2}'
echo "(Ensure this MAC differs from your hardware MAC)"
echo ""

echo "[2/4] IPv6 Status (Must be disabled)"
IPV6_STATE=$(sysctl -n net.ipv6.conf.all.disable_ipv6)
if [ "$IPV6_STATE" -eq 1 ]; then
    echo "  ? IPv6 is successfully disabled."
else
    echo "  ? CRITICAL LEAK: IPv6 is still active!"
    exit 1
fi
echo ""

echo "[3/4] System Clock and Timezone"
timedatectl | grep -E "Time zone|Local time"
echo ""

echo "[4/4] Tor Network Exit Node Verification"
verify_tor_connectivity

echo "============================================="
echo "All OpSec constraints verified. Launching Mullvad Browser from RAM..."

REAL_USER=${SUDO_USER:-kali}
sudo -u "$REAL_USER" env DISPLAY="${DISPLAY:-:0}" XAUTHORITY="${XAUTHORITY:-/home/$REAL_USER/.Xauthority}" /tmp/mullvad-browser/Browser/start-mullvad-browser \
    "https://check.torproject.org/" \
    "https://dnsleaktest.com/" \
    "https://browserleaks.com/webrtc" \
    "https://amiunique.org/" > /dev/null 2>&1 &
