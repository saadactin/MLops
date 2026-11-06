# Linux Networking & Service Architecture - Day 3 (Part 2)
**Date:** October 30, 2026  
**Student:** Saad Sayyed  
**Environment:** AWS EC2 (`t3.micro` - Free Tier $0), Region: `ap-south-1` (Mumbai)  
**Topic:** Ports, Network Sockets, Loopback vs. Wildcard, and Systemd Service Creation

---

## 📑 Table of Contents
1. [Core Networking Concepts Mastered Today](#1-core-networking-concepts-mastered-today)
2. [Challenge 3: Port Probing & Service Discovery (`ss`, `nc`, `curl`)](#2-challenge-3-port-probing--service-discovery-ss-nc-curl)
3. [Challenge 4: The 127.0.0.1 (Loopback) vs 0.0.0.0 (Wildcard) Trap](#3-challenge-4-the-127001-loopback-vs-00000-wildcard-trap)
4. [Masterclass: How System Services Get Their Names & Who Runs Them](#4-masterclass-how-system-services-get-their-names--who-runs-them)
5. [Master Command Cheat Sheet](#5-master-command-cheat-sheet)

---

## 1. Core Networking Concepts Mastered Today

### A. The Apartment Building Analogy
- **IP Address (`15.252.173.38`):** The **Street Address** of the whole building (server).
- **Port Number (`22`, `80`, `5000`, `8080`):** The individual **Room Numbers** inside the building.
- A connection always requires both: **`IP:Port`** (e.g. `15.252.173.38:5000`).

---

## 2. Challenge 3: Port Probing & Service Discovery (`ss`, `nc`, `curl`)

### The 3 Essential Diagnostic Tools:
1. **`sudo ss -tulnp` (Socket Statistics):**
   - Displays all open doors in the operating system.
   - Letters: `-t` (TCP), `-u` (UDP), `-l` (Listening), `-n` (Numeric port), `-p` (Process name & PID).
   - *Observation:* When Port 8080 was dead, `ss -tulnp | grep :8080` returned completely blank.
2. **`nc -zv <host> <port>` (Netcat Knock):**
   - Knocks on a port in 0.1 seconds without sending data.
   - *Observation:* When no program was listening, it reported `Ncat: Connection refused`.
3. **`curl http://<host>:<port>`:**
   - Fetches the actual HTTP payload once the port is open and alive.

---

## 3. Challenge 4: The 127.0.0.1 (Loopback) vs 0.0.0.0 (Wildcard) Trap

### The #1 Developer Mystery:
> *"Why does `curl http://localhost:5000` work in the terminal, but my Windows PC browser says 'Site can't be reached'?"*

### The Root Cause: Interface Binding
| Binding IP | Name | Who Can Connect? |
| :--- | :--- | :--- |
| **`127.0.0.1`** | **Loopback (Localhost)** | **ONLY programs running inside this same computer.** The network card discards all external traffic coming from the internet! |
| **`0.0.0.0`** | **Wildcard (All Interfaces)** | **EVERYONE.** Listens on every network adapter, allowing internet traffic through AWS to reach the app. |

### The Fix:
- Edited `/opt/loopback_service.py` to change `127.0.0.1` to `0.0.0.0`.
- Ran `sudo systemctl restart api5000` to apply changes.
- Verified in `ss -tulnp`: Changed from `127.0.0.1:5000` to `0.0.0.0:5000`.
- Successfully loaded `http://15.252.173.38:5000` live in the Windows browser!

---

## 4. Masterclass: How System Services Get Their Names & Who Runs Them

### "Who gives the service its name?"
👉 **YOU DO!** The name of any service is literally just the file name you give it inside `/etc/systemd/system/`:
- `/etc/systemd/system/`**`saad-logger`**`.service` ➡️ Service name: **`saad-logger`**
- `/etc/systemd/system/`**`api5000`**`.service` ➡️ Service name: **`api5000`**

### When to use Cron vs. Systemd:
- **Use Cron (`crond`):** If a script runs quickly (e.g. takes 3 seconds to log) and exits every 5 minutes:
  ```text
  */5 * * * * /usr/bin/python3 /home/ec2-user/my_logger.py
  ```
- **Use Systemd (`systemctl`):** If a script runs 24/7 (like a web server or infinite loop). Systemd keeps it alive, restarts it on crash, and launches it on server boot.

### The Service Template:
```ini
[Unit]
Description=My Custom Application Service
After=network.target

[Service]
Type=simple
User=ec2-user
ExecStart=/usr/bin/python3 /path/to/app.py
Restart=always

[Install]
WantedBy=multi-user.target
```
Commands to manage it:
- `sudo systemctl daemon-reload`
- `sudo systemctl start <name>`
- `sudo systemctl status <name>`
- `sudo systemctl enable <name>` (starts automatically on boot)

---

## 5. Master Command Cheat Sheet

| Command | Purpose |
| :--- | :--- |
| `sudo ss -tulnp` | Show all listening ports, protocols, and owning PIDs |
| `sudo ss -tulnp \| grep :<port>` | Check if a specific port is actively listening |
| `nc -zv <host> <port>` | Knock on a port to verify if connection succeeds or is refused |
| `curl http://localhost:<port>` | Test a web endpoint locally from terminal |
| `sudo systemctl restart <service>` | Restart a background service to reload modified code from disk |
| `sudo systemctl daemon-reload` | Refresh systemd after creating or modifying a `.service` file |
