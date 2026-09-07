#!/bin/bash
# scripts/host-prep/mount-outer.sh
# Helper to safely mount the Outer Volume without destroying the Hidden Volume.

set -e
set -o pipefail

echo "============================================="
echo "   ??? SAFE MOUNT (OUTER VOLUME) ???"
echo "============================================="
read -p "Enter path to container (e.g., /run/media/user/USB/sys_cache.dat): " TARGET_PATH

read -s -p "Enter OUTER Volume Password: " OUTER_PASS
echo ""
read -s -p "Enter HIDDEN Volume Password (Required to protect it): " INNER_PASS
echo ""

echo "Mounting Outer Volume safely (--protect-hidden=yes)..."

# Pass OuterPassword\nInnerPassword to stdin
(echo "$OUTER_PASS"; echo "$INNER_PASS") | sudo veracrypt -t --mount "$TARGET_PATH" /mnt/outer_vault \
    --pim=0 --keyfiles="" --protect-hidden=yes --stdin

echo "? Outer Volume mounted at /mnt/outer_vault"
echo "You can now safely add decoy files without overwriting the Ghost framework."
