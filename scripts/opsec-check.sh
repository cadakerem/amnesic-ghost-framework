#!/bin/bash

echo "============================================="
echo "   🛡️ OPSEC KONTROL MERKEZİ (INSPECTOR) 🛡️"
echo "============================================="
echo "Bu betik, ghost.sh tarafindan yapilan gizlilik"
echo "ayarlarini denetler ve test sitelerini acar."
echo "---------------------------------------------"

echo "[1/4] Ağ Bağdaştırıcıları ve MAC Adresi"
ip link show | grep -E "link/ether" | awk '{print "  " $2}'
echo "(MAC adresinin orijinalinden farklı olup olmadığını kontrol et)"
echo ""

echo "[2/4] IPv6 Durumu (Kapalı Olmalı)"
IPV6_STATE=$(sysctl -n net.ipv6.conf.all.disable_ipv6)
if [ "$IPV6_STATE" -eq 1 ]; then
    echo "  ✅ IPv6 Başarıyla Kapatılmış."
else
    echo "  ❌ UYARI: IPv6 Halen Aktif Sızıntı Yapabilir!"
fi
echo ""

echo "[3/4] Sistem Saati ve Timezone (UTC Olmalı)"
timedatectl | grep -E "Time zone|Local time"
echo ""

echo "[4/4] Tor Ağı Çıkış Düğümü (Exit Node) Kontrolü"
TOR_IP=$(curl -s --max-time 10 https://check.torproject.org/api/ip | grep -oP '"IP":"\K[^"]+')
if [ -n "$TOR_IP" ]; then
    echo "  ✅ Tor IP Adresiniz: $TOR_IP"
else
    echo "  ❌ UYARI: Tor Ağına Ulaşılamadı veya Sızıntı Var!"
fi
echo "============================================="
echo "Görsel doğrulama için Firefox açılıyor..."
echo "Lütfen sekmelerdeki test sonuçlarını inceleyin."

# Arka planda Firefox'u ilgili test siteleriyle başlat
firefox-esr \
    "https://check.torproject.org/" \
    "https://dnsleaktest.com/" \
    "https://browserleaks.com/webrtc" \
    "https://browserleaks.com/javascript" \
    "https://amiunique.org/" > /dev/null 2>&1 &

echo "İşlem tamamlandı. Tarayıcıyı kontrol edin."
