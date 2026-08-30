# Amnesic Ghost Framework 👻

A privacy-focused Kali Linux Live environment designed to minimize persistent local artifacts, isolate sensitive data, and route network traffic securely through Tor.

> ⚠️ **Disclaimer:** This framework is developed strictly for educational and experimental purposes, intended for cybersecurity researchers, penetration testers, and privacy advocates. The provided scripts do not encourage or endorse any illegal activities. All responsibility lies with the user.

---

## 1. System Architecture

The Amnesic Ghost Framework is designed with a layered approach to ensure maximum privacy and data isolation.

### The Amnesic Layer (RAM-Only OS)
The base operating system is Kali Linux running in Live Mode. 
- **No Persistence:** By default, the OS does not mount or write to any local hard drives.
- **Volatile Memory:** All system logs, temporary files, and browsing history exist strictly in RAM.
- **Wipe on Power-Off:** The moment power is lost or the system shuts down, all operational artifacts are destroyed.

### The Cryptographic Layer (VeraCrypt Vault)
To store necessary tools and sensitive information persistently without compromising the amnesic nature of the OS, a hidden volume is utilized.
- **Camouflage:** The vault is camouflaged (e.g., `hidden_vault.hc` or `swap_file.sys`) and placed in the unencrypted USB partition to avoid suspicion.
- **Encryption:** 256-bit encryption ensures that even if the USB is lost, the data remains inaccessible.

### The Routing Layer (Anonsurf & Tor)
Once the system is active, all traffic must be routed through the Tor network.
- **Transparent Proxy:** Anonsurf modifies `iptables` to force all TCP traffic through the Tor network.
- **DNS Leak Prevention:** DNS requests are resolved through Tor's DNS resolver, preventing local ISP tracking.
- **IPv6 Disabling:** IPv6 is disabled system-wide to prevent accidental leaks.

### The Fingerprint Layer (Hardware & Browser)
- **MAC Spoofing:** `macchanger` alters the physical network interface's MAC address before connecting to any network.
- **Timezone Alignment:** The system clock is synchronized to UTC using the Tor network to prevent timezone correlation.
- **Browser Hardening:** `privacy.resistFingerprinting` is enabled in Mullvad Browser to normalize the browser footprint.

---

## 2. Threat Model

This framework protects against specific threats but relies heavily on the user's operational discipline.

**In-Scope Threats (What this protects against):**
1. **Local Forensic Analysis (Post-Seizure):** If the USB drive is seized while powered off, the adversary will only find a standard Kali Live ISO and random encrypted data. No browsing history, IP logs, or system artifacts remain on the host machine.
2. **Network Interception (ISP/Local Admin):** The local network administrator will only see encrypted Tor traffic.
3. **Hardware Tracking:** The original MAC address of the host machine is spoofed, preventing network-level device tracking across sessions.
4. **Timezone/Locale Correlation:** By syncing the system clock to UTC over Tor, adversaries cannot correlate the user's physical timezone.

**Out-of-Scope Threats (Limitations):**
1. **Compromised Host Hardware:** Hardware keyloggers, compromised firmware (Intel ME, BIOS), or screen-capturing implants.
2. **OpSec Failures:** Logging into personal accounts (e.g., personal email, social media) while using this framework will instantly deanonymize the session.
3. **Advanced Global Adversaries:** Entities capable of monitoring a large percentage of the Tor network nodes.

---

## 3. Creating the Vault (Initial Setup)

Before using this framework, you need to create the encrypted vault (`hidden_vault.hc`) where your tools will reside on the persistent section of your USB drive (e.g., `/run/media/kali/USB_DRIVE/`).

**Method A: Using VeraCrypt GUI (Recommended)**
1. Launch VeraCrypt and click **Create Volume**.
2. Select **Create an encrypted file container**.
3. Select **Standard VeraCrypt volume** (or Hidden).
4. **Volume Location:** Navigate to your persistent USB partition and name the file `hidden_vault.hc`.
5. **Volume Size:** Enter the desired size (e.g., 2 GB).
6. **Volume Password:** Enter a strong, random password (20+ characters). Do NOT use keyfiles on a Live OS.
7. **Format:** Move your mouse randomly to increase cryptographic strength, select `ext4` or `exFAT`, and click Format.

**Method B: Command Line**
```bash
veracrypt -t -c --volume-type=normal "/run/media/kali/USB_DRIVE/hidden_vault.hc" --size=2G --encryption=aes --hash=sha-512 --filesystem=ext4 --pim=0 --keyfiles="" --random-source=/dev/urandom
```

After creation, copy the `scripts/` folder (including `ghost.sh` and `opsec-check.sh`) into the mounted vault.

---

## 4. Operation Workflow

To an external observer, the USB drive simply contains a standard Kali Linux installation. 

### ✅ Step 1 — Offline Installation (VeraCrypt)
After booting Kali Live, open a terminal **BEFORE connecting to the internet** and run the initial setup script to install VeraCrypt locally:
```bash
sudo bash /run/media/kali/USB_DRIVE/scripts/setup.sh
```

### ⚠️ Plan B — Online Installation (Fallback)
If the offline `.deb` packages on your USB become corrupted or lost, use the `fallback-setup.sh` script. This script operates on a **Minimum IP Disclosure** principle.
- It briefly uses your real IP address *only* to run `apt update` and install the base Tor dependencies.
- It immediately starts the Tor tunnel.
- It then securely installs the sensitive packages (like VeraCrypt) and downloads Mullvad Browser entirely through Tor without your real IP address pinging those servers.
```bash
sudo bash /run/media/kali/USB_DRIVE/scripts/fallback-setup.sh
```

### ✅ Step 2 — Opening the Vault
Open the VeraCrypt GUI, select the camouflaged vault file (`/run/media/kali/USB_DRIVE/hidden_vault.hc`), and click **Mount**.

### ✅ Step 3 — Entering Ghost Mode
Once the vault is mounted, run the core script to deploy all privacy tools, spoof the MAC address, sync the timezone to UTC, and prepare the browser in RAM:
```bash
sudo bash /media/veracrypt1/scripts/ghost.sh
```
> **Note:** The script will pause and prompt you to connect to Wi-Fi. Press ENTER after connecting. It will automatically initialize Tor (Anonsurf) and sync the system clock.

### ✅ Step 4 — Verification (Inspector)
To ensure the traffic is routed correctly, run the independent inspection script:
```bash
sudo bash /media/veracrypt1/scripts/opsec-check.sh
```
This script verifies your system state (MAC, IPv6, UTC) locally and automatically opens Mullvad Browser directly from volatile RAM with the following testing tabs to visually confirm the lack of leaks:
- `check.torproject.org`: Confirms this browser is using Tor.
- `dnsleaktest.com`: Confirms DNS requests do not leak your ISP.
- `browserleaks.com/webrtc`: Confirms WebRTC is disabled and not leaking local IP.
- `amiunique.org`: Confirms the browser blends in with the Tor anonymity set.

### ✅ Step 5 — Shutdown
When your work is done, shut down the computer. The moment the system powers off, all data in RAM is wiped, leaving only the encrypted VeraCrypt vault on the USB drive.
