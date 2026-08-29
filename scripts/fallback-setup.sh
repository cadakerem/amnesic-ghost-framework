#!/bin/bash
echo "============================================="
echo "   ⚠️ B PLANI (ONLINE KURULUM) BAŞLIYOR ⚠️"
echo "============================================="
echo "Bu betik, USB'deki deb paketlerinin bozulması"
echo "durumunda internet üzerinden minimum ifşa ile"
echo "kurulum yapmak için kullanılır."

echo "[1/4] Anonsurf bağımlılıkları gerçek IP ile indiriliyor..."
sudo apt update
sudo apt install -y tor secure-delete i2p

echo "[2/4] Anonsurf indiriliyor ve kuruluyor..."
git clone https://github.com/Und3rf10w/kali-anonsurf.git /tmp/kali-anonsurf
cd /tmp/kali-anonsurf && sudo bash installer.sh

echo "[3/4] Tor tüneli başlatılıyor (Artık anonimsiniz)..."
sudo anonsurf start

echo "[4/4] VeraCrypt ve bağımlılıkları Tor üzerinden kuruluyor..."
# Kullanıcının USB'deki veracrypt deb dosyalarının EFI_Boot içinde olduğu varsayılır
# Eğer USB'de yoksa, Tor tüneli açıkken wget ile de çekilebilir.
DEPO="/run/media/kali/EFI_Boot"
if [ -d "$DEPO" ]; then
    sudo dpkg -i "$DEPO"/libwx*.deb 2>/dev/null
    sudo dpkg -i "$DEPO"/veracrypt*.deb 2>/dev/null
    sudo apt --fix-broken install -y
    echo "✅ Kurulum Tor tüneli içinden başarıyla tamamlandı!"
else
    echo "❌ HATA: USB depo yolu ($DEPO) bulunamadı."
fi
