
# SRE & Production Incident Response Learning Log - Day 6
**Date:** November 2, 2026 (Evening Session - Day 6)  
**Student:** Saad Sayyed  
**Environment:** AWS EC2 (`t3.micro` - Free Tier $0), Region: `ap-south-1` (Mumbai)  
**Topics:** Linux Cron Jobs (Silent Failures), Network Port Squatting (`EADDRINUSE`), Least Privilege SRE Security (`/etc/sudoers.d/`)

---

## 📑 Table of Contents
1. [Cost Assurance: 100% Free Tier ($0 Cost)](#1-cost-assurance-100-free-tier-0-cost)
2. [Incident 1: The Broken Backup Cron Job (Silent Failure)](#2-incident-1-the-broken-backup-cron-job-silent-failure)
3. [Incident 2: The Rogue Port Squatter (`Address already in use: Port 80`)](#3-incident-2-the-rogue-port-squatter-address-already-in-use-port-80)
4. [Incident 3: SRE Security & Granular Sudo Privilege (Least Privilege)](#4-incident-3-sre-security--granular-sudo-privilege-least-privilege)
5. [The Great Sudoers Trap: "Never Overwrite Vendor Files"](#5-the-great-sudoers-trap-never-overwrite-vendor-files)
6. [Day 6 SRE Commands Quick Cheat Sheet](#6-day-6-sre-commands-quick-cheat-sheet)

---

## 1. Cost Assurance: 100% Free Tier ($0 Cost)
- **Instance Type:** `t3.micro` (750 hours/month free under AWS Free Tier)
- **Disk:** 8 GB `gp3` (up to 30 GB EBS free tier)
- **Total Incurred Cost:** **$0.00**
- Running `terraform destroy` cleanly tears down all infrastructure so no background compute is retained.

---

## 2. Incident 1: The Broken Backup Cron Job (Silent Failure)

### The Production Scenario
- The company's automated database backup script (`/opt/finance_app/backup_database.sh`) was scheduled in `/etc/cron.d/finance_db_backup` to run every minute (`* * * * *`).
- **Symptom:** `/var/backups/daily_db/` was 100% empty!

### Root Cause
- The script had permissions `-rw-r--r--` (`644`).
- In Linux, files without the `x` (execute) bit cannot be run as programs.
- Because `cron` runs headless in the background without an interactive terminal, it failed silently with:  
  `CMDOUT (/bin/sh: line 1: /opt/finance_app/backup_database.sh: Permission denied)`

### The Fix
```bash
# 1. Inspect file permissions
ls -la /opt/finance_app/backup_database.sh

# 2. Add execute permission
sudo chmod +x /opt/finance_app/backup_database.sh

# 3. Verify in cron logs
sudo systemctl status crond
# Look for: (root) CMD (/opt/finance_app/backup_database.sh)

# 4. Verify output files
ls -lh /var/backups/daily_db/
```

---

## 3. Incident 2: The Rogue Port Squatter (`Address already in use: Port 80`)

### The Production Scenario
- Nginx web server failed to start: `Job for nginx.service failed because the control process exited with error code.`
- Systemd log reported: `bind() to 0.0.0.0:80 failed (98: Address already in use)`

### The Networking Concept (Parking Spot Analogy)
- Each port (e.g., Port `80`) is like a single parking spot.
- Only **one** process can bind to a network port at a time.
- A hidden background Python script was squatting on `0.0.0.0:80`.

### Diagnostic & Resolution Workflow
```bash
# 1. Investigate who is holding port 80
sudo ss -tulnp | grep :80
# Output revealed:
# tcp LISTEN 0.0.0.0:80 users:(("python3",pid=3811,fd=3))

# 2. Terminate the rogue squatter process
sudo kill -9 3811

# 3. Verify port 80 is clear
sudo ss -tulnp | grep :80

# 4. Start Nginx cleanly
sudo systemctl start nginx
sudo systemctl status nginx
# Result: Active: active (running)
```

---

## 4. Incident 3: SRE Security & Granular Sudo Privilege (Least Privilege)

### The Production Scenario
- A junior developer (`saad-dev`) needs to restart Nginx during code deployments.
- Default attempt failed: `saad-dev is not in the sudoers file. This incident will be reported.`
- **Security Requirement:** Under the Principle of Least Privilege, NEVER give developers full root access (`ALL=(ALL) ALL`). Give access ONLY to the specific required command.

### The Correct Granular Rule Syntax
```text
<USERNAME> ALL=(ALL) NOPASSWD: <FULL_COMMAND_PATH>
```
Saad's exact rule:
```text
saad-dev ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx, /bin/systemctl reload nginx, /bin/systemctl status nginx
```

---

## 5. The Great Sudoers Trap: "Never Overwrite Vendor Files"

### What Happened During the Lab
- Saad placed the rule inside `/etc/sudoers.d/90-cloud-init-users`, overwriting the existing `ec2-user` rule.
- **The Impact:** `ec2-user` immediately lost its administrative sudo privileges!

### The Production Best Practice
1. **Never edit vendor files** (`90-cloud-init-users`, `/etc/sudoers`).
2. **Create a dedicated file per user or team:**
   ```bash
   # Create a separate file specifically for saad-dev
   sudo cat << "EOF" > /etc/sudoers.d/saad-dev
   saad-dev ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx, /bin/systemctl reload nginx, /bin/systemctl status nginx
   EOF

   # Sudoers security requirement: permissions must be 0440 (read-only)
   sudo chmod 440 /etc/sudoers.d/saad-dev
   ```
3. **Verify Least Privilege:**
   - Allowed command works: `sudo systemctl restart nginx` ✅
   - Forbidden command blocked: `sudo cat /etc/shadow` ❌ (`Sorry, user saad-dev is not allowed to execute '/bin/cat /etc/shadow' as root`)

---

## 6. Day 6 SRE Commands Quick Cheat Sheet

| Task | Command |
| :--- | :--- |
| **Check Cron Service & Logs** | `systemctl status crond` |
| **Add Script Execute Bit** | `sudo chmod +x /path/to/script.sh` |
| **Find Who Owns a Port** | `sudo ss -tulnp \| grep :<PORT>` |
| **Evict Process by PID** | `sudo kill -9 <PID>` |
| **Exit Pager (`lines 1-10`)** | Press `q` |
| **Switch User** | `su - <username>` |
| **Exit User Session** | `exit` |
| **Set Sudoers File Permissions** | `sudo chmod 440 /etc/sudoers.d/<filename>` |

---
*Created by Saad Sayyed during DevOps & SRE Production Hands-on Lab.*
