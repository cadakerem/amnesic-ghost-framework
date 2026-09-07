# Amnesic Ghost Framework 👻

A privacy-focused Kali Linux Live environment designed to minimize persistent local artifacts, isolate sensitive data, and route network traffic securely through Tor.

> ⚠️ **Disclaimer:** This project is provided strictly for lawful, educational, and defensive security purposes only. It is intended for cybersecurity researchers, penetration testers, and privacy advocates. The provided scripts do not encourage, endorse, or facilitate any illegal activities. The author assumes no liability and is not responsible for any misuse, damage, or legal consequences caused by the use of this framework. All responsibility lies entirely with the user.

---

## 🛠️ Tech Stack & Core Technologies
- **Core OS & Automation:** Kali Linux (Debian), Bash Shell Scripting, `tmpfs` (RAM Disk)
- **Cryptography:** VeraCrypt (AES-256, Hidden Volumes), Ext4/exFAT Filesystems
- **Network Routing:** Tor Network, `iptables` (Transparent Proxying via Anonsurf)
- **Hardware/OpSec:** `macchanger`, IPv6/DNS Leak Prevention, UTC Time-Spoofing
- **Application Security:** Mullvad Browser (Anti-Fingerprinting), X11/Wayland Display Auth (`XAUTHORITY`)

---

## 1. System Architecture

The Amnesic Ghost Framework is designed with a layered approach to ensure maximum privacy and data isolation.

### The Amnesic Layer (RAM-Only OS)
The base operating system is Kali Linux running in Live Mode. 
- **No Persistence:** By default, the OS does not mount or write to any local hard drives.
- **Volatile Memory:** All system logs, temporary files, and browsing history exist strictly in RAM.
- **Wipe on Power-Off:** The moment power is lost or the system shuts down, all operational artifacts are destroyed.

### The Cryptographic Layer (VeraCrypt Vault)
To store necessary tools and sensitive information persistently without compromising the amnesic nature of the OS, an encrypted container is utilized.
- **Camouflage:** The container file is superficially named (e.g., `system_cache.dat`) and placed in the unencrypted USB partition to avoid casual suspicion.
- **Plausible Deniability:** To survive forced password disclosure (rubber-hose cryptanalysis), the framework mandates the use of VeraCrypt's true **Hidden Volume** feature (an inner volume nested inside a decoy outer volume).

### The Routing Layer (Anonsurf & Tor)
Once the system is active, all traffic must be routed through the Tor network.
- **Transparent Proxy:** Anonsurf modifies `iptables` to force all TCP traffic through the Tor network.
- **DNS Leak Prevention:** DNS requests are resolved through Tor's DNS resolver, preventing local ISP tracking.
- **IPv6 Disabling:** IPv6 is disabled system-wide to prevent accidental leaks.

### The Fingerprint Layer (Hardware & Browser)
- **MAC Spoofing:** `macchanger` alters the physical network interface's MAC address strictly **offline**, before any network interface is brought up or associated with an access point.
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
4. **Single-Source Time Sync:** The system synchronizes its hardware clock by fetching the HTTP Date header strictly from `check.torproject.org` over Tor. It does not use cross-referenced multi-source time synchronization (like Tails' `sdwdate`). If this endpoint is compromised, spoofed, or undergoing an MITM attack, the time synchronization could be manipulated.
5. **Flash Memory Wear-Leveling (Hardware Flaw):** Flash-based media (USB drives, SSDs) utilize a controller that physically remaps writes across different cells to extend lifespan. VeraCrypt explicitly warns against using Hidden Volumes on flash media. Deleting or overwriting data in the Outer Volume does NOT guarantee the physical flash block was overwritten, leaving traces of the old data in unallocated physical blocks that hardware-level forensics can recover, potentially exposing the Hidden Volume's existence.
6. **Entropy Analysis Detection:** Naming the vault `system_cache.dat` is merely superficial camouflage. Forensic tools (e.g., TCHunt) do not look at filenames; they look for large blocks of high entropy data lacking magic bytes and divisible by 512. The file will statistically stand out as an encrypted container during an audit.
7. **RAM Forensics (Cold Boot):** While the framework is designed to be amnesic, bash variables (like passwords typed during vault creation on the host prep machine) reside in RAM as plain text. Bash does not securely wipe memory. A cold-boot attack immediately after execution could extract these.

---

## 3. Prerequisites & Downloads
Since security tools should never be distributed via third-party repositories, you must download the offline binaries directly from their official vendors before setting up your USB drive.

1. **VeraCrypt (Linux Debian 12/13 - GUI):**
   Download the `.deb` installer from the official site: [https://veracrypt.fr/en/Downloads.html](https://veracrypt.fr/en/Downloads.html)
2. **Mullvad Browser (Linux x86_64):**
   Download the `.tar.xz` archive from the official site: [https://mullvad.net/en/download/browser/linux](https://mullvad.net/en/download/browser/linux)
3. **Kali Anonsurf (Source Code):**
   Download or clone the Anonsurf repository from GitHub: [https://github.com/Und3rf10w/kali-anonsurf](https://github.com/Und3rf10w/kali-anonsurf)

> [!IMPORTANT]
> **Supply-Chain Verification:** Never blindly trust downloaded binaries. You must verify the PGP/GPG signatures and SHA256 checksums of VeraCrypt and Mullvad Browser before moving them to your USB drive. If the signatures do not match the official developer keys, the binaries may be compromised.

---

## 4. Creating the Vault (Initial Setup)

To preserve strict **Plausible Deniability**, you must NEVER run vault creation scripts from the unencrypted partition of the USB drive, nor should the USB drive contain scripts with words like "hidden" or "vault" in plain sight.

For this reason, we provide a standalone `scripts/host-prep/` directory. **You must run these scripts on a secure, trusted host machine BEFORE deploying to the USB drive.**

> [!CAUTION]
> **Plausible Deniability (Rubber-Hose Cryptanalysis):** A forensic analyst will easily identify a large, high-entropy file as a cryptographic container, regardless of its superficial name (e.g., `system_cache.dat`). 
> To survive forced password disclosure, you **must** use VeraCrypt's **Hidden Volume** feature. If coerced, you surrender the password to the Outer Volume only.

**Step A: Create the Vault on a Trusted Host**
Run the automated creation script from your trusted host machine:
```bash
bash scripts/host-prep/create-vault.sh
```
- It will prompt securely for the outer and inner passwords (using `stdin` to prevent bash history leaks).
- It will enforce the creation of the Hidden Volume within the Outer Volume.

**Step B: Organically Populate the Decoy (Outer Volume)**
You MUST populate the Outer Volume with real, boring files over a period of time. Do NOT use automation scripts to generate "dummy data," as forensic analysts can easily detect uniform timestamps, fake entropy, and lack of organic file accumulation. 
Whenever you need to mount the Outer Volume to add files, ALWAYS use:
```bash
bash scripts/host-prep/mount-outer.sh
```
This helper script explicitly mounts it with `--protect-hidden=yes`. Without this flag, writing to the Outer Volume will physically overwrite and destroy your Ghost Framework (Hidden Volume).

**Step C: USB Directory Structure Requirements**
Once generated, copy the container to your USB. The unencrypted partition must look generic.

1. **On the unencrypted USB Partition** (`/run/media/kali/USB_DRIVE/`):
   - `system_cache.dat` *(Your renamed VeraCrypt container)*
   - `veracrypt-*.deb` and `libwx*.deb`
   - `scripts/setup.sh`
   - `scripts/fallback-setup.sh`
   *(Notice: No mention of "hidden" or "vault" here!)*

2. **Inside the mounted Hidden Volume**:
   - `scripts/ghost.sh`
   - `scripts/opsec-check.sh`
   - `scripts/lib/verify-tor.sh`
   - `repo/mullvad-browser-linux-x86_64-*.tar.xz`
   - `repo/kali-anonsurf/`

---

## 5. Operation Workflow

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
Once the vault is mounted, run the core script. The script performs MAC spoofing **offline** before associating with any network, ensuring your real hardware MAC is never broadcasted. It then deploys all privacy tools and prepares the browser in RAM:
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

> [!CAUTION]
> **Test Site Logging:** Keep in mind that third-party leak testing sites (`dnsleaktest`, `amiunique`, etc.) log your Tor exit IP and browser fingerprint. In an extreme paranoia threat model, visiting these sites before conducting sensitive operations provides correlation data to the exit node and the site operator. Use them for educational verification, but close the browser and restart the framework for real operations.

### ✅ Step 5 — Shutdown
When your work is done, shut down the computer. The moment the system powers off, all data in RAM is wiped, leaving only the encrypted VeraCrypt vault on the USB drive.
