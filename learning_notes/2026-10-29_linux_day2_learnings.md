# Linux & DevOps Troubleshooting Learning Log - Day 2
**Date:** October 29, 2026  
**Student:** Saad Sayyed  
**Environment:** AWS EC2 (`t3.micro` - Free Tier $0), Region: `ap-south-1` (Mumbai)  
**OS:** Amazon Linux 2023 (Kernel 6.1)  
**Difficulty:** +5% Level Up (Real-World SysAdmin & DevOps Scenarios)

---

## 📑 Table of Contents
1. [Terraform Level-Up: Locals & Multi-Port Networking](#1-terraform-level-up-locals--multi-port-networking)
2. [Core Linux Concepts & Insights Learned Today](#2-core-linux-concepts--insights-learned-today)
3. [The 4 Day-2 Real-World Troubleshooting Labs Solved](#3-the-4-day-2-real-world-troubleshooting-labs-solved)
4. [Day 2 Master Command Cheat Sheet](#4-day-2-master-command-cheat-sheet)
5. [Tear Down & Zero-Cost Management](#5-tear-down--zero-cost-management)

---

## 1. Terraform Level-Up: Locals & Multi-Port Networking

### What We Upgraded in Terraform
- **`locals` Block:** Centralized reusable metadata (`Day = "2"`, `Cost = "Free-Tier-Eligible"`). In professional teams, this eliminates hardcoding and ensures tags are uniform across all resources.
- **Port 8080 Ingress:** Added Port 8080 to the Security Group alongside Port 22 (SSH) and Port 80 (Nginx), allowing us to route traffic to our custom Python microservice once fixed.
- **Enhanced Outputs:** Configured output variables that provide live browser links (`nginx_url` and `custom_webapp_url`) immediately after `terraform apply`.

---

## 2. Core Linux Concepts & Insights Learned Today

### A. Relative vs. Absolute Paths (Why `opt` didn't show on `ls`)
- **`~` (Tilde):** The shortcut for your personal home directory (`/home/ec2-user`).
- **`ls` (without arguments):** Only lists what is inside your current folder.
- **`/` (Root):** The very top level of the entire hard drive (equivalent to `C:\` in Windows).
- **The Solution:** 
  - `pwd` shows where you are right now.
  - `/opt` lives at root (`/`), so you must run `ls /` or `ls /opt` to view it from your home folder.

### B. Viewing vs. Listing vs. Editing Files
- **`ls`:** Lists file names only (does NOT open files).
- **`cat`:** Reads and prints text content to the terminal.
- **`nano`:** Opens the file in a text editor to make changes.

### C. Environment Variables Deep Dive (`printenv` vs. `~/.bashrc` vs. `.env`)
- **`printenv`:** A **command** that reads active variables currently residing in RAM.
- **`~/.bashrc`:** A **file on disk** that executes automatically every time you start an SSH session.
- **Where are variables stored in Linux?**
  - In active process memory (RAM).
  - System-wide on disk: `/etc/environment` and `/etc/profile.d/*.sh`.
  - User-specific on disk: `~/.bashrc` and `~/.bash_profile`.
- **What about `.env` files?**
  - Linux does *not* natively read `.env` files; application libraries (like Node's `dotenv` or Docker Compose) read them.
  - In production, systemd services load `.env` files securely using `EnvironmentFile=/path/to/.env`.

### D. Modern Linux Logging (`journald` vs. legacy `/var/log/cron`)
- **Why `/var/log/cron` was missing:** Amazon Linux 2023 retired legacy `rsyslog` plain text files.
- **Modern Method:** All system services write to the binary systemd journal.
- **How to view service logs:** `sudo journalctl -u crond -n 20` or `sudo journalctl -u <service> -f`.

### E. Process Architecture: Parent vs. Child Processes
- **The 3-Second Mystery:** `echo ... >> file` takes 0.001 seconds, then `sleep 3` runs. During sleep, the file is closed, so `lsof` momentarily shows no open handle.
- **Why `sudo kill 54485` failed with "No such process":** PID 54485 was the temporary `sleep 3` child command. It finished in 3 seconds before the kill command was executed.
- **The Golden Rule:** Always terminate the **Parent Process** (`mystery_logger.sh` PID 5281) to kill background infinite loops permanently.

---

## 3. The 4 Day-2 Real-World Troubleshooting Labs Solved

### 🎯 Lab 1: Custom Systemd Service Crash & Port Conflict
- **Problem:** `sudo systemctl start webapp` failed with an error.
- **Investigation:**
  - `journalctl -xeu webapp` revealed: `can't open file '/opt/webapp/servr.py': No such file or directory`.
  - `ls /opt/webapp` showed the actual file was named `server.py`.
- **Fix Part 1:** Corrected the typo in `/etc/systemd/system/webapp.service` and ran `sudo systemctl daemon-reload`.
- **Problem 2 (Port Collision):** Attempted start failed with `OSError: [Errno 98] Address already in use`.
- **Investigation:** Ran `sudo ss -tulnp | grep :80` and discovered Nginx was already using Port 80.
- **Fix Part 2:** Changed `server_address = ('', 8080)` inside `/opt/webapp/server.py`.
- **Result:** Service started successfully (`active (running)` in green) and rendered:
  `http://<PUBLIC_IP>:8080` live in the browser!

### 🎯 Lab 2: Missing Environment Variable in Deployment Script
- **Problem:** `/home/ec2-user/linux_lab/deploy_app.sh` crashed with `DATABASE_URL is not set`.
- **Investigation:** Tested with `printenv | grep DATABASE_URL` (empty).
- **Fix:**
  - Temporary: `export DATABASE_URL="postgresql://dbuser:SecretPass123@mydb.internal:5432/proddb"`
  - Permanent: Appended the export command to `~/.bashrc` and reloaded with `source ~/.bashrc`.
- **Result:** Deployment script passed with: `✅ Success! Connecting to database`.

### 🎯 Lab 3: The Silent Broken Cron Job
- **Problem:** Scheduled cron job in `crontab -l` was failing to generate reports in `/home/ec2-user/`.
- **Root Cause:**
  1. Cron runs in a minimal shell where relative paths fail (`generate_report.sh` not in `$PATH`).
  2. The script itself used relative output `>> daily_report.log`.
- **Fix:**
  - Edited crontab: `crontab -e` -> changed to absolute path `* * * * * /home/ec2-user/linux_lab/generate_report.sh`.
  - Edited script: changed output path to `/home/ec2-user/linux_lab/daily_report.log`.
- **Result:** Verified live automated writes every 60 seconds with:
  `System Health: OK at Thu Oct 29 08:56:50 UTC 2026`.

### 🎯 Lab 4: The Mystery Locked File & Process Hunting
- **Problem:** Continuous background stream writing to `/var/log/custom_audit/active_stream.log`.
- **Investigation:**
  - Tracked stream with `tail -f`.
  - Learned why instantaneous file append loops evade momentary `lsof` checks.
  - Used `ps aux | grep -E "mystery|sleep"` to reveal the parent/child process tree.
- **Fix:** Terminated the master parent loop: `sudo kill 5281` (or `sudo pkill -f mystery_logger.sh`).
- **Result:** Process tree terminated cleanly; stream writing halted.

---

## 4. Day 2 Master Command Cheat Sheet

| Command | Purpose |
| :--- | :--- |
| `pwd` | Print current working directory |
| `cd /` vs `cd ~` | Navigate to Hard Drive Root vs Personal User Home |
| `ls /` | List root system folders (`opt`, `etc`, `var`, `usr`) |
| `ss -tulnp` | Inspect active network sockets, listening ports, and PIDs (Modern netstat) |
| `systemctl daemon-reload` | Reload systemd service definitions after editing `/etc/systemd/system/` files |
| `printenv` | Query all environment variables currently loaded in RAM |
| `export VAR="value"` | Set a temporary environment variable in active shell session |
| `source ~/.bashrc` | Instantly reload user shell configuration without reconnecting SSH |
| `crontab -l` | List active user scheduled cron jobs |
| `crontab -e` | Edit user cron schedule |
| `journalctl -u <service> -n 20` | Read modern systemd service journal logs (replaces legacy `/var/log` files) |
| `lsof <file>` | List all processes and PIDs that have a file open |
| `pkill -f <pattern>` | Terminate processes matching a script or command name |

---

## 5. Tear Down & Zero-Cost Management

To guarantee **$0 (Zero Cost)** after completing your Day 2 practice:

1. **Exit the SSH session:**
   ```bash
   exit
   ```
2. **From your Windows terminal (`c:\Users\SaadSayyed\Desktop\terraform`), run:**
   ```powershell
   terraform destroy
   ```
3. Type **`yes`** when prompted.

Terraform will cleanly terminate the EC2 instance, delete the 8 GB EBS volume, remove the security group, and delete the key pair.
