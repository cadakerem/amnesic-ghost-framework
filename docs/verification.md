# Verification & Testing

The effectiveness of this framework is not based on assumptions. It is verified through the `opsec-check.sh` (Inspector) script, which runs a series of automated local checks and opens web-based validation tools.

## 1. Local Terminal Checks
When `opsec-check.sh` is executed, it first verifies the system state locally:
- **MAC Address:** Confirms the `wlan0` interface is using a randomized MAC address.
- **IPv6 State:** Confirms `net.ipv6.conf.all.disable_ipv6` is set to `1`.
- **System Time:** Confirms the active timezone is `UTC`.
- **Tor Exit Node:** Queries the Tor project API via `curl` to confirm the active external IP belongs to the Tor network.

## 2. Browser Verification Sites
The script automatically launches Firefox ESR with the following tabs to visually confirm the lack of leaks:

### A. IP & Tor Check
- **Site:** `https://check.torproject.org/`
- **Expected Result:** A green message confirming "Congratulations. This browser is configured to use Tor."

### B. DNS Leak Test
- **Site:** `https://dnsleaktest.com/`
- **Expected Result:** Running the extended test should only show DNS servers belonging to the Tor network or untraceable open resolvers. Your ISP's DNS should NOT appear.

### C. WebRTC Leak Test
- **Site:** `https://browserleaks.com/webrtc`
- **Expected Result:** WebRTC should be disabled or unable to leak your true local IP (e.g., `192.168.x.x`) or true public IP.

### D. Browser Fingerprinting
- **Site:** `https://amiunique.org/` or `https://browserleaks.com/javascript`
- **Expected Result:** Due to `privacy.resistFingerprinting = true`, the browser should blend in with generic Firefox Tor bundles, mitigating unique canvas or font tracking.

