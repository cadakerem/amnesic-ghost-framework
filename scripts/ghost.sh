#!/bin/bash
REPO="/media/veracrypt1/repo"

echo "[1/6] MAC Adresi Rastgele Degistiriliyor..."
sudo ip link set wlan0 down 2>/dev/null
sudo macchanger -r wlan0 2>/dev/null
sudo ip link set wlan0 up 2>/dev/null

echo "[2/6] IPv6 Kapatiliyor ve Saat Bölgesi UTC'ye Aliniyor..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 > /dev/null
sudo timedatectl set-timezone UTC

echo "[3/6] Tum Gizlilik Paketleri (repo) Kuruluyor..."
sudo dpkg -i "$REPO"/*.deb > /dev/null 2>&1
cd "$REPO/kali-anonsurf" && sudo bash installer.sh > /dev/null 2>&1

echo "[4/6] Firefox Tarayicisi 'Tor Moduna' (Zirhli) Geciriliyor..."
sudo mkdir -p /etc/firefox-esr
echo 'pref("privacy.resistFingerprinting", true);' | sudo tee /etc/firefox-esr/syspref.js > /dev/null

echo ""
echo "============================================="
echo "   ⚠️ DIKKAT: BAGLANTI BEKLENIYOR ⚠️"
echo "============================================="
echo "MAC adresin degisti ve kurulumlar bitti."
echo "Lutfen simdi sag ust koseden WI-FI'YE BAGLAN."
echo ""
read -p "Baglantiyi sagladiktan sonra ENTER tusuna bas..."

echo ""
echo "[5/6] Tor Tüneli Baslatiliyor (Anonsurf)..."
sudo anonsurf start

echo ""
echo "[6/6] Saat Internetten (Tor uzerinden) Duzeltiliyor..."
# Tor agi uzerinden gercek UTC saatini cek ve sistemi esitle
REAL_TIME=$(curl -sI https://check.torproject.org | grep -i '^Date:' | sed 's/^[Dd]ate: //g' | tr -d '\r')
if [ -n "$REAL_TIME" ]; then
    sudo date -s "$REAL_TIME" > /dev/null
    echo "--> Sistem saati gercek Londra (UTC) saatine kusursuz hizalandi!"
else
    echo "--> Uyari: Saat internetten cekilemedi."
fi

echo ""
echo "[ TEST ] Tor Baglantisi Dogrulaniyor..."
curl -s https://check.torproject.org/api/ip

echo ""
echo ""
echo "=== 👻 GHOST MODU AKTIF 👻 ==="
echo "Kali'deki standart Firefox'u acabilirsin (Tamamen Tor gibi davranacaktir)."
echo "Gorsel Dogrulama Siteleri:"
echo " 1. check.torproject.org (IP Testi)"
echo " 2. dnsleaktest.com (DNS Sızıntı Testi)"
echo " 3. browserleaks.com/javascript (Saat ve Parmak Izi Testi)"
echo "---------------------------------------------"
echo "AGY icin : cd /media/veracrypt1/AI-log && ./agy"