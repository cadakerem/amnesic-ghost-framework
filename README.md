# Amnesic Ghost Framework 👻

This project is an **educational framework** designed to provide complete anonymity, operational security (OpSec), and cryptographically isolated data storage for Kali Linux running via a live USB environment.

> ⚠️ **Disclaimer:** This framework is developed strictly for educational and experimental purposes, intended for cybersecurity researchers, penetration testers, and privacy advocates. The provided scripts do not encourage or endorse any illegal activities. All responsibility lies with the user.

## 1. Why Not Use Standard "Persistence"?
The standard `Live (persistence)` mode integrates the allocated USB space with the operating system. While working in this mode, **everything** you do—browser history, downloaded files, background logs—is permanently recorded on the drive.

Our goal is an **Amnesic** environment: the operating system completely resets and wipes itself upon every shutdown. Only specific sensitive tasks and tools are persistently stored within a cryptographically isolated, hidden vault (VeraCrypt).

## 2. OpSec Level 99: The Golden Rules
To maintain true privacy, this framework relies on 3 core OpSec principles:

- **Burner Accounts:** **Never** use your personal accounts (e.g., Gmail, personal phone-verified accounts) to log into any services. Always use anonymous "Burner" accounts registered over Tor/VPN (e.g., using virtual numbers).
- **Absolute Isolation:** Store your API keys, passwords, and sensitive data **only** within the encrypted VeraCrypt vault on your USB drive. Never leave them in the live system's home directory.
- **Strict Tor Routing:** **Never** launch any tools or browsers inside the vault without first routing your entire system traffic through the Tor network (`anonsurf`).

## 3. System Architecture & Workflow

To an external observer, the USB drive simply contains a standard Kali Linux installation and a VeraCrypt installer. All privacy tools (Tor, I2P, Anonsurf, Browser fingerprint mitigations) and personal scripts are locked inside a 256-bit encrypted vault.

### ✅ Step 1 — Offline Installation (VeraCrypt)
After booting Kali Live, open a terminal **BEFORE connecting to the internet** and run the initial setup script to install VeraCrypt locally:
```bash
sudo bash /run/media/kali/EFI_Boot/scripts/setup.sh
```

### ⚠️ Plan B — Online Installation (Fallback)
If the offline `.deb` packages on your USB become corrupted or lost, use the `fallback-setup.sh` script. This script operates on a **Minimum IP Disclosure** principle to rebuild your environment from scratch securely.

**How it works under the hood:**
1. **Initial Clear-Net Connection:** It briefly uses your real IP address *only* to run `apt update` and install the base `tor`, `i2p`, and `secure-delete` dependencies.
2. **Tor Deployment:** It clones the Anonsurf repository from GitHub and installs it locally.
3. **Tunnel Activation:** Immediately starts `anonsurf`, forcing all subsequent TCP and DNS traffic through the Tor network.
4. **Anonymous Payload Delivery:** Once the Tor tunnel is active, it securely installs the sensitive packages (like VeraCrypt) without your real IP address ever pinging those servers.
```bash
sudo bash /run/media/kali/EFI_Boot/scripts/fallback-setup.sh
```

### ✅ Step 2 — Opening the Vault
Open the VeraCrypt GUI:
1. Select an empty slot.
2. **Select File:** `/run/media/kali/EFI_Boot/swap_file.sys` (The camouflaged vault file).
3. Click **Mount** and enter your password.

### ✅ Step 3 — Entering Ghost Mode
Once the vault is mounted, run the core script to deploy all privacy tools, spoof your MAC address, stealthily sync your timezone to UTC, and armor your browser:
```bash
sudo bash /media/veracrypt1/scripts/ghost.sh
```
> **Note:** The script will pause and prompt you to connect to Wi-Fi. Press ENTER after connecting. It will automatically initialize Tor (Anonsurf) and sync the system clock.

### ✅ Step 4 — Verification (Inspector)
To ensure everything is working flawlessly without leaks, run the independent inspection script:
```bash
sudo bash /media/veracrypt1/scripts/opsec-check.sh
```
This script verifies your system state (MAC, IPv6, UTC) in the terminal and automatically opens Firefox with IP, DNS Leak, and Browser Fingerprint testing tabs.

### ✅ Step 5 — Shutdown & Disappearance
When your work is done, simply shut down the computer.
- The moment the system powers off, all data in RAM is wiped.
- Any websites visited or traces left in the operating system disappear forever.
- Only your unbreakable, encrypted VeraCrypt vault remains on the USB drive.
