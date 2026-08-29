#!/bin/bash

echo "============================================="
echo "   🛡️ OPSEC INSPECTION CENTER (VALIDATOR) 🛡️"
echo "============================================="
echo "This script verifies the privacy settings"
echo "configured by ghost.sh and launches test sites."
echo "---------------------------------------------"

echo "[1/4] Network Adapters & MAC Address"
ip link show | grep -E "link/ether" | awk '{print "  " $2}'
echo "(Verify if your MAC address differs from the original hardware MAC)"
echo ""

echo "[2/4] IPv6 Status (Should be Disabled)"
IPV6_STATE=$(sysctl -n net.ipv6.conf.all.disable_ipv6)
if [ "$IPV6_STATE" -eq 1 ]; then
    echo "  ✅ IPv6 successfully disabled."
else
    echo "  ❌ WARNING: IPv6 is still active and may cause leaks!"
fi
echo ""

echo "[3/4] System Clock & Timezone (Should be UTC)"
timedatectl | grep -E "Time zone|Local time"
echo ""

echo "[4/4] Tor Network Exit Node Check"
TOR_IP=$(curl -s --max-time 10 https://check.torproject.org/api/ip | grep -oP '"IP":"\K[^"]+')
if [ -n "$TOR_IP" ]; then
    echo "  ✅ Your Tor Exit IP Address: $TOR_IP"
else
    echo "  ❌ WARNING: Tor Network unreachable or leaking!"
fi
echo "============================================="
echo "Launching Firefox for visual verification..."
echo "Please review the test results in the newly opened tabs."

# Start Firefox in the background with validation sites
firefox-esr \
    "https://check.torproject.org/" \
    "https://dnsleaktest.com/" \
    "https://browserleaks.com/webrtc" \
    "https://browserleaks.com/javascript" \
    "https://amiunique.org/" > /dev/null 2>&1 &

echo "Operation complete. Check your browser."
