# Amnesic Ghost Framework 👻

A privacy-focused Kali Linux Live environment designed to minimize persistent local artifacts, isolate sensitive data, and route network traffic securely through Tor.

> ⚠️ **Disclaimer:** This framework is developed strictly for educational and experimental purposes, intended for cybersecurity researchers, penetration testers, and privacy advocates. The provided scripts do not encourage or endorse any illegal activities. All responsibility lies with the user.

## 1. Why Not Use Standard "Persistence"?
The standard `Live (persistence)` mode integrates the allocated USB space with the operating system. While working in this mode, local artifacts such as browser history, downloaded files, and background logs are persistently recorded on the drive.

The goal of this project is to create an **Amnesic** environment: the operating system resets and wipes its state upon every shutdown. Only specific sensitive tasks and tools are persistently stored within a cryptographically isolated, hidden vault (VeraCrypt).

## 2. Core Principles
To maintain a high level of operational security, this framework relies on 3 core principles:

- **Identity Compartmentalization:** Avoid using personal accounts (e.g., primary emails, phone-verified accounts) within this environment. Utilize compartmentalized accounts registered over Tor/VPN.
- **Absolute Isolation:** Store sensitive data only within the encrypted VeraCrypt vault on the USB drive. Avoid leaving data in the live system's home directory.
- **Strict Traffic Routing:** Ensure that sensitive tools and browsers are not launched without first routing the entire system traffic through the Tor network (`anonsurf`).

## 3. System Architecture & Workflow

To an external observer, the USB drive simply contains a standard Kali Linux installation and a VeraCrypt installer. All privacy tools (Tor, I2P, Anonsurf, Browser fingerprint mitigations) and personal scripts are locked inside a 256-bit encrypted vault.

### ✅ Step 1 — Offline Installation (VeraCrypt)
After booting Kali Live, open a terminal **BEFORE connecting to the internet** and run the initial setup script to install VeraCrypt locally:
```bash
sudo bash /media/usb_drive/scripts/setup.sh
```
> **New Users:** If you haven't created your encrypted vault yet, please read the [Vault Creation Guide](docs/vault-creation.md) to set up your `hidden_vault.hc` container before proceeding to Step 2.

### ⚠️ Plan B — Online Installation (Fallback)
If the offline `.deb` packages on your USB become corrupted or lost, use the `fallback-setup.sh` script. This script operates on a **Minimum IP Disclosure** principle to rebuild your environment from scratch securely.

**How it works under the hood:**
1. **Initial Clear-Net Connection:** It briefly uses your real IP address *only* to run `apt update` and install the base `tor`, `i2p`, and `secure-delete` dependencies.
2. **Tor Deployment:** It clones the Anonsurf repository from GitHub and installs it locally.
3. **Tunnel Activation:** Immediately starts `anonsurf`, forcing all subsequent TCP and DNS traffic through the Tor network.
4. **Anonymous Payload Delivery:** Once the Tor tunnel is active, it securely installs the sensitive packages (like VeraCrypt) without your real IP address ever pinging those servers.

### ✅ Step 2 — Opening the Vault
Open the VeraCrypt GUI:
1. Select an empty slot.
2. **Select File:** /media/usb_drive/hidden_vault.hc (The camouflaged vault file).
3. Click **Mount** and enter your password.

### ✅ Step 3 — Entering Ghost Mode
Once the vault is mounted, run the core script to deploy all privacy tools, spoof the MAC address, sync the timezone to UTC, and armor the browser:
```bash
sudo bash /media/veracrypt_vault/scripts/ghost.sh
```
> **Note:** The script will pause and prompt you to connect to Wi-Fi. Press ENTER after connecting. It will automatically initialize Tor (Anonsurf) and sync the system clock.

### ✅ Step 4 — Verification (Inspector)
To ensure the traffic is routed correctly, run the independent inspection script:
```bash
sudo bash /media/veracrypt_vault/scripts/opsec-check.sh
```
This script verifies your system state (MAC, IPv6, UTC) in the terminal and automatically opens Firefox with IP, DNS Leak, and Browser Fingerprint testing tabs.

### ✅ Step 5 — Shutdown
When your work is done, shut down the computer. The moment the system powers off, all data in RAM is wiped, leaving only the encrypted VeraCrypt vault on the USB drive.
