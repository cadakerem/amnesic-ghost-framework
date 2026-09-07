#!/bin/bash
# scripts/lib/verify-tor.sh

function verify_tor_connectivity() {
    local LOG_FILE="${1:?LOG_FILE argument is required to prevent silent failures}"
    
    echo "[ TEST ] Verifying Tor Connectivity..."
    local TOR_RESP
    TOR_RESP=$(curl -s --max-time 10 https://check.torproject.org/api/ip)
    local CURL_EXIT=$?
    
    if [ $CURL_EXIT -eq 60 ]; then
        echo "? CRITICAL ERROR: TLS Certificate verification failed (curl exit 60)!"
        echo "Possible causes:"
        echo " 1. ACTIVE MITM ATTACK: An adversary is intercepting your HTTPS traffic."
        echo " 2. BROKEN CLOCK: Your hardware RTC is wildly incorrect (e.g., years behind)."
        echo " 3. NETWORK CENSORSHIP: DPI or firewall is interfering with certificates."
        echo "Aborting Ghost Mode immediately. You are NOT safe."
        sudo anonsurf stop 2>&1 | tee -a "$LOG_FILE" > /dev/null || true
        exit 1
    elif [ $CURL_EXIT -ne 0 ] || [ -z "$TOR_RESP" ]; then
        echo "? CRITICAL ERROR: Unreachable Tor Network (curl exit $CURL_EXIT)! (No Internet or Tor blocked)"
        echo "Aborting. You are NOT anonymous."
        sudo anonsurf stop 2>&1 | tee -a "$LOG_FILE" > /dev/null || true
        exit 1
    elif ! echo "$TOR_RESP" | grep -q 'IsTor":true'; then
        echo "? CRITICAL LEAK: Traffic is NOT routed through Tor!"
        echo "Aborting to prevent real IP exposure."
        sudo anonsurf stop 2>&1 | tee -a "$LOG_FILE" > /dev/null || true
        exit 1
    else
        local TOR_IP
        TOR_IP=$(echo "$TOR_RESP" | grep -oP '"IP":"\K[^"]+')
        echo "? Success! Traffic is routed via Tor (IP: $TOR_IP)."
    fi
}

function sync_clock_via_tor() {
    local LOG_FILE="${1:?LOG_FILE argument is required to prevent silent failures}"
    
    echo "[ TIME ] Syncing System Clock via Tor Network..."
    local REAL_TIME
    REAL_TIME=$(curl -sI --max-time 15 https://check.torproject.org | grep -i '^Date:' | sed 's/^[Dd]ate: //g' | tr -d '\r')
    
    if [ -n "$REAL_TIME" ]; then
        sudo date -s "$REAL_TIME" > /dev/null
        echo "--> System clock successfully synced to UTC via Tor!"
    else
        echo "--> ? Warning: Could not fetch HTTP Date via Tor."
        echo "Hardware RTC time might leak your local timezone. Aborting."
        sudo anonsurf stop 2>&1 | tee -a "$LOG_FILE" > /dev/null || true
        exit 1
    fi
}
