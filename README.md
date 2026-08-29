# Amnesic Ghost Framework 👻

Bu proje, USB üzerinden çalışan Kali Linux sistemlerinde tam anonimlik, operasyonel güvenlik (OpSec) ve şifreli veri izolasyonu sağlamak için geliştirilmiş **eğitim amaçlı** bir çerçevedir. 

> ⚠️ **Yasal Uyarı (Disclaimer):** Bu framework siber güvenlik araştırmacıları, sızma testi (penetration test) uzmanları ve mahremiyet savunucuları için deneysel amaçlarla hazırlanmıştır. Buradaki betikler hiçbir yasa dışı faaliyeti teşvik etmez. Oluşabilecek tüm sorumluluk kullanıcıya aittir.

## 1. Neden Standart "Kalıcılık (Persistence)" Kullanmıyoruz?
Normal `Live (persistence)` modu, USB'deki ayrılmış alanı işletim sistemine entegre eder. Bu modda çalışırken yapılan **her şey** (tarayıcı geçmişi, indirilen dosyalar, arka plan logları) kaydedilir. 

Bizim amacımız ise işletim sisteminin her kapanışta **kendini tamamen sıfırlaması (Amnesic)**, sadece belirlediğimiz hassas görevlerin ve araçların kalıcı, kriptografik olarak izole edilmiş bir depoda (VeraCrypt Kasası) saklanmasıdır.

## 2. OpSec Level 99: Altın Kurallar
Gizliliğinizi korurken dikkat etmeniz gereken 3 temel OpSec kuralı:

- **Gölge (Burner) Hesap:** Sisteme giriş yaparken **asla** şahsi hesaplarınızı kullanmayın. Tor/VPN üzerinden açılmış (örn: kafeden alınmış sanal numarayla doğrulanmış) anonim bir "Gölge" hesap kullanın.
- **Tam İzolasyon:** Anahtarlarınızı, şifrelerinizi ve hassas verilerinizi sadece USB'nizdeki şifreli VeraCrypt kasasında saklayın.
- **Tor Yönlendirmesi:** Kasa içindeki hiçbir aracı veya tarayıcıyı, trafiğinizi Tor ağına (`anonsurf`) yönlendirmeden **asla** çalıştırmayın.

## 3. Sistem Mimarisi ve Kullanım Adımları

Bu mimaride dışarıdan bakan biri USB'de sadece Kali Linux ve VeraCrypt kurulum dosyası görür. Tüm gizlilik araçları (Tor, I2P, Anonsurf, Tarayıcı verileri) ve kişisel projeleriniz 256-bit şifreli kasanın içine kilitlenmiştir.

### ✅ Adım 1 — Dış Kurulum (VeraCrypt)
Bilgisayarı Kali Live olarak başlattıktan sonra, **İnternete BAĞLANMADAN** terminali açın ve sadece VeraCrypt'i kuracak olan ilk scripti çalıştırın:
```bash
sudo bash /run/media/kali/EFI_Boot/scripts/setup.sh
```

### ⚠️ B Planı — Online Kurulum (Fallback)
Eğer USB'deki çevrimdışı `.deb` paketleri bozulursa, **Minimum IP İfşası** prensibiyle çalışan `fallback-setup.sh` betiğini kullanın. Bu betik, gerçek IP'nizle sadece Tor'u kurar; geri kalan her şeyi (VeraCrypt dahil) Tor tüneli içinden anonim olarak indirir:
```bash
sudo bash /run/media/kali/EFI_Boot/scripts/fallback-setup.sh
```

### ✅ Adım 2 — Kasa Açılışı
VeraCrypt arayüzünü açın:
1. Boş bir Slot seçin.
2. **Select File:** `/run/media/kali/EFI_Boot/swap_file.sys` (Kamuflaj kasa dosyası)
3. **Mount** diyerek parolanızı girin.

### ✅ Adım 3 — Hayalet Moda Geçiş (Ghost Mode)
Kasa açıldıktan sonra, kasanın içindeki tüm gizlilik araçlarını kuracak, MAC adresini değiştirecek, saati gizlice internetten UTC'ye senkronize edecek ve tarayıcıyı zırhlayacak ana scripti çalıştırın:
```bash
sudo bash /media/veracrypt1/scripts/ghost.sh
```
> **Önemli:** Script çalışırken duraklayacak ve sizden Wi-Fi'ye bağlanmanızı isteyecektir. Bağlandıktan sonra ENTER'a basarsanız Tor (Anonsurf) otomatik başlayacak ve saat eşitlemesi yapılacaktır.

### ✅ Adım 4 — Doğrulama (Inspector)
Her şeyin kusursuz çalıştığından emin olmak için bağımsız denetim betiğini çalıştırın:
```bash
sudo bash /media/veracrypt1/scripts/opsec-check.sh
```
Bu betik sistem durumunu (MAC, IPv6, UTC) terminalde doğrular ve ardından Firefox'u otomatik olarak IP, DNS Leak ve Browser Fingerprint test sekmeleriyle açar.

### ✅ Adım 5 — Kapanış ve Yok Oluş
İşiniz bittiğinde bilgisayarı kapatın (Shut down).
- Kapanış anında RAM'deki tüm veriler silinir.
- İşletim sisteminde girilen siteler veya bırakılan izler sonsuza dek kaybolur.
- Geriye sadece USB diskinizdeki kırılması imkansız şifreli VeraCrypt kasası kalır.
