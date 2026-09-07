#!/bin/bash
# scripts/host-prep/create-vault.sh
# Run this on a secure HOST machine, NOT on the final USB drive.

set -e
set -o pipefail

echo "============================================="
echo "   ??? HIDDEN VAULT AUTOMATION ???"
echo "============================================="
echo "This script safely creates a VeraCrypt Hidden Volume."
echo "It must be executed on a trusted host machine."
echo ""

read -r -p "Enter path to create container (e.g., /run/media/user/USB/sys_cache.dat): " TARGET_PATH
read -r -p "Enter total Outer Volume size (e.g., 2G, 500M): " OUTER_SIZE
read -r -p "Enter Hidden Volume size (e.g., 1G, 200M): " INNER_SIZE

echo "??  NOTE: Ensure Hidden Volume is considerably smaller than Outer Volume."
echo ""

# Securely read passwords with confirmation
while true; do
    read -r -s -p "Enter OUTER Volume Password (Dummy/Decoy): " OUTER_PASS
    echo ""
    read -r -s -p "Confirm OUTER Volume Password: " OUTER_PASS2
    echo ""
    if [ "$OUTER_PASS" = "$OUTER_PASS2" ]; then
        break
    else
        echo "? Passwords do not match! Try again."
    fi
done

echo ""
while true; do
    read -r -s -p "Enter HIDDEN Volume Password (Ghost Framework): " INNER_PASS
    echo ""
    read -r -s -p "Confirm HIDDEN Volume Password: " INNER_PASS2
    echo ""
    if [ "$INNER_PASS" = "$INNER_PASS2" ]; then
        break
    else
        echo "? Passwords do not match! Try again."
    fi
done

if [ "$OUTER_PASS" = "$INNER_PASS" ]; then
    echo "? ERROR: Outer and Inner passwords MUST be different!"
    exit 1
fi

echo ""
echo "[1/2] Creating Outer Volume..."
# Use --stdin to prevent password leak in /proc and bash history
echo "$OUTER_PASS" | veracrypt -t -c --volume-type=normal "$TARGET_PATH" \
    --size="$OUTER_SIZE" --encryption=aes --hash=sha-512 --filesystem=exfat \
    --pim=0 --keyfiles="" --random-source=/dev/urandom --stdin

echo "[2/2] Creating Inner (Hidden) Volume..."
# For hidden volume, VeraCrypt requires both passwords via stdin separated by newline
# Format: OuterPassword\nInnerPassword
(echo "$OUTER_PASS"; echo "$INNER_PASS") | veracrypt -t -c --volume-type=hidden "$TARGET_PATH" \
    --size="$INNER_SIZE" --encryption=aes --hash=sha-512 --filesystem=ext4 \
    --pim=0 --keyfiles="" --random-source=/dev/urandom --stdin

echo ""
echo "? Vault created successfully at $TARGET_PATH"
echo ""
echo "??  CRITICAL PLAUSIBLE DENIABILITY REQUIREMENT ??"
echo "You MUST now organically populate the Outer Volume with real, boring files"
echo "over a period of time. Do NOT use automation scripts to generate dummy data."
