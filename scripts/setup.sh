#!/bin/bash
DEPO="/run/media/kali/EFI_Boot"

echo "[1/2] Sadece VeraCrypt ve bagimliliklari kuruluyor..."
sudo dpkg -i "$DEPO"/libwx*.deb
sudo dpkg -i "$DEPO"/veracrypt*.deb

echo "[2/2] Kurulum tamamlandi. Lutfen kasanizi acin."
echo "Terminal ile acmak icin: sudo veracrypt --text $DEPO/swap_file.sys /mnt/kasa --pim=0 --keyfiles="" --protect-hidden=no"