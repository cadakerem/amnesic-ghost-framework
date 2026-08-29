# Amnesic Ghost Framework 👻

Bu proje, USB üzerinden çalışan Kali Linux sistemlerinde tam anonimlik, operasyonel güvenlik (OpSec) ve şifreli veri izolasyonu sağlamak için geliştirilmiş **eğitim amaçlı** bir çerçevedir. 

> ⚠️ **Yasal Uyarı (Disclaimer):** Bu framework siber güvenlik araştırmacıları, sızma testi (penetration test) uzmanları ve mahremiyet savunucuları için deneysel amaçlarla hazırlanmıştır. Buradaki betikler hiçbir yasa dışı faaliyeti teşvik etmez. Oluşabilecek tüm sorumluluk kullanıcıya aittir.

## Özellikler (OpSec Level 99)

- **Amnesic Yapı:** İşletim sistemi RAM üzerinde çalışır; kapatıldığı an tüm veriler ve oturumlar silinir. Host makinede iz bırakmaz.
- **Kriptografik İzolasyon:** Tüm kişisel betikler, API anahtarları ve veriler VeraCrypt ile 256-bit şifrelenmiş, taklit edilemez bir kasa içerisinde muhafaza edilir.
- **Ağ Zırhı (Ghost Mode):** 
  - İnternete bağlandığı an tüm IPv6 trafiği bloke edilir.
  - Donanımsal MAC adresi rastgele değiştirilir.
  - Tarayıcı Anti-Fingerprinting (Anti-Parmak İzi) moduna geçirilir.
  - Tüm TCP/DNS trafiği Anonsurf aracılığıyla şeffaf olarak Tor ağına yönlendirilir.
- **Zaman Taklidi (Timezone Spoofing):** İşletim sisteminin saati yerel saatten bağımsız olarak Tor ağı üzerinden UTC'ye hizalanarak saat dilimi sızıntıları önlenir.

## Mimari: Çift Betik + Doğrulama (Inspector)

Sistem 3 temel aşamadan oluşur:

1. **`setup.sh` (Dış Kurulum):** Kali Live ortamı internete çıkmadan önce USB'deki deb paketleriyle temel şifreleme araçlarını (VeraCrypt) kurar. 
2. **`ghost.sh` (Hayalet Moda Geçiş):** Kasa açıldıktan sonra çalışan bu betik; MAC adresini değiştirir, IPv6'yı kapatır, internete bağlanıldıktan sonra Tor tünelini açar ve saati eşitler. (Bkz: `scripts/ghost.sh`)
3. **`opsec-check.sh` (Kontrol Merkezi):** `ghost.sh` görevini bitirdikten sonra bağımsız bir denetçi olarak çalışır. Sistemin mevcut durumunu (IP, IPv6, Timezone, DNS Leak) analiz eder ve sonuçları göstermek üzere test araçlarını tarayıcıda otomatik başlatır.

## Kurulum ve Kullanım 

*(Scriptler ve çevrimdışı bağımlılıkların USB diskinizdeki `EFI_Boot` veya benzeri açık alanlara kopyalanmış olduğu varsayılır.)*

1. Kali Linux USB üzerinden **Live System** olarak başlatılır.
2. Terminal açılarak `setup.sh` çalıştırılır ve kasa mount edilir.
3. Kasanın içinden `ghost.sh` çalıştırılır. Ağ bağdaştırıcısı hazır olunca Wi-Fi'ye bağlanılır ve Tor tüneli başlatılır.
4. Anonimlik durumunu denetlemek için `opsec-check.sh` çalıştırılır. Ekranınızda beliren 5 sekmede (check.torproject, dnsleaktest, amiunique vs.) sızıntı olup olmadığı bağımsız olarak doğrulanır.
