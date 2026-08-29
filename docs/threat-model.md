# Threat Model

This document outlines the threat model for the Amnesic Ghost Framework, detailing what it protects against and its inherent limitations.

## In-Scope Threats (What this protects against)
1. **Local Forensic Analysis (Post-Seizure):** 
   - If the USB drive is seized while powered off, the adversary will only find a standard Kali Live ISO and random encrypted data (`swap_file.sys`).
   - No browsing history, IP logs, or system artifacts remain on the host machine.
2. **Network Interception (ISP/Local Admin):**
   - The local ISP or network administrator will only see encrypted Tor traffic. They cannot see the destination websites or the content of the traffic.
3. **Hardware Tracking:**
   - The original MAC address of the host machine is spoofed, preventing the local network from tracking the specific device across different sessions.
4. **Timezone/Locale Correlation:**
   - By syncing the system clock to UTC over the Tor network, adversaries cannot correlate the user's physical timezone based on system time leaks.

## Out-of-Scope Threats (Limitations)
1. **Compromised Host Hardware:**
   - If the host machine has hardware keyloggers, compromised firmware (e.g., Intel ME, malicious BIOS), or screen-capturing implants, this framework cannot guarantee privacy.
2. **Operational Security (OpSec) Failures:**
   - Logging into personal accounts (e.g., personal email, social media) while using this framework will instantly deanonymize the session.
   - Downloading and executing malicious payloads outside the Tor network before the tunnel is established.
3. **Advanced Global Adversaries:**
   - Entities capable of monitoring a large percentage of the Tor network nodes might theoretically perform traffic correlation attacks.
4. **Live RAM Extraction (Cold Boot Attack):**
   - If an adversary gains physical access to the machine *while it is running or immediately after power loss*, they might extract encryption keys from RAM.

## Conclusion
This framework is a robust defense against local forensics and network surveillance, but it relies heavily on the user maintaining strict operational discipline.
