# System Architecture

The Amnesic Ghost Framework is designed with a layered approach to ensure maximum privacy and data isolation.

## 1. The Amnesic Layer (RAM-Only OS)
The base operating system is Kali Linux running in Live Mode. 
- **No Persistence:** By default, the OS does not mount or write to any local hard drives.
- **Volatile Memory:** All system logs, temporary files, and browsing history exist strictly in RAM.
- **Wipe on Power-Off:** The moment power is lost or the system shuts down, all operational artifacts are destroyed.

## 2. The Cryptographic Layer (VeraCrypt Vault)
To store necessary tools and sensitive information persistently without compromising the amnesic nature of the OS, a hidden volume is utilized.
- **Camouflage:** The vault is named `swap_file.sys` and placed in the unencrypted `EFI_Boot` partition to avoid suspicion.
- **Encryption:** 256-bit encryption ensures that even if the USB is lost, the data remains inaccessible.

## 3. The Routing Layer (Anonsurf & Tor)
Once the system is active, all traffic must be routed through the Tor network.
- **Transparent Proxy:** Anonsurf modifies `iptables` to force all TCP traffic through the Tor network.
- **DNS Leak Prevention:** DNS requests are resolved through Tor's DNS resolver, preventing local ISP tracking.
- **IPv6 Disabling:** IPv6 is disabled system-wide to prevent accidental leaks.

## 4. The Fingerprint Layer (Hardware & Browser)
- **MAC Spoofing:** `macchanger` alters the physical network interface's MAC address before connecting to any network.
- **Timezone Alignment:** The system clock is synchronized to UTC using the Tor network to prevent timezone correlation.
- **Browser Hardening:** `privacy.resistFingerprinting` is enabled in Firefox ESR to normalize the browser footprint.
