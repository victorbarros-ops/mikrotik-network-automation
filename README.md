# MikroTik Network Automation & NetOps Scripts 📡

This repository contains advanced **RouterOS scripts** developed for high-availability ISP environments and corporate networks.

## 📂 Featured Scripts

### 1. Dual WAN Recursive Failover (`dual-wan-failover-recursive.rsc`)
* **Problem:** Standard check-gateway only checks the immediate gateway, failing to detect ISP outages further upstream.
* **Solution:** Implements recursive routing (pinging 1.1.1.1 and 8.8.8.8) to verify end-to-end connectivity. Automatically switches WAN interfaces upon packet loss.

### 2. Telegram Blacklist Alert (`telegram-blacklist-alert.rsc`)
* **Function:** Integrates MikroTik with the **Telegram API**.
* **Usage:** Automatically fetches the firewall address-list "blacklist" and sends a formatted report to the admin's smartphone. Vital for real-time security monitoring.

### 3. Automated Firmware Downloader (`auto-firmware-update.rsc`)
* **Function:** Automates the lifecycle management of network devices.
* **Logic:** Checks for new `stable` channel updates and downloads the `.npk` packages for multiple architectures (ARM, MIPS, x86, TILE) to a central server.

### 4. Advanced QoS Traffic Shaping (`qos-traffic-shaping-pcq.rsc`)
* **Function:** Bandwidth management using **PCQ (Per Connection Queuing)**.
* **Logic:** Prioritizes real-time traffic (VoIP, DNS, Gaming) over bulk downloads, ensuring low latency even during network saturation.

### 5. Port Scanner Protection (`firewall-port-scanner-protection.rsc`)
* **Function:** Intrusion Detection System (IDS) at the router level.
* **Logic:** Analyzes invalid TCP Flag combinations (Xmas scan, Null scan, SYN/FIN) to detect Nmap scans and automatically blacklists the attacker's IP for 2 weeks.

---
**Author:** Victor Augusto  
*Senior Network Infrastructure Engineer*
