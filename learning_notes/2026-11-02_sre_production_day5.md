# SRE & Production Troubleshooting Learning Log - Day 5
**Date:** November 2, 2026 (Day 5 Session)  
**Student:** Saad Sayyed  
**Environment:** AWS EC2 (`t3.micro` - Free Tier $0), Region: `ap-south-1` (Mumbai)  
**Topics:** Linux Swap & OOM Killer, Deleted-Yet-Open Ghost Files (`lsof +L1`), Microservice Automated Health Checks, Automated Log Rotation (`logrotate`)

---

## 📑 Table of Contents
1. [Challenge 1: The OOM Killer & Linux Swap Memory](#1-challenge-1-the-oom-killer--linux-swap-memory)
2. [Challenge 2: The Deleted-Yet-Open Disk Ghost Mystery](#2-challenge-2-the-deleted-yet-open-disk-ghost-mystery)
3. [Challenge 3: Automated Microservice Health Checks](#3-challenge-3-automated-microservice-health-checks)
4. [Challenge 4: Automated Production Log Rotation (`logrotate`)](#4-challenge-4-automated-production-log-rotation-logrotate)
5. [SRE Production Commands Quick Cheat Sheet](#5-sre-production-commands-quick-cheat-sheet)

---

## 1. Challenge 1: The OOM Killer & Linux Swap Memory

### 🧒 The 10-Year-Old Concept
- **RAM (Desk Space):** Fast, but limited (e.g., 916 MB). When apps open, they take space on the desk.
- **OOM Killer (Angry Teacher):** If your desk is full and you try to put another book, Linux forcefully kills a running process to prevent kernel freeze.
- **Swap (The Locker):** Extra overflow storage on the hard drive. Slower than RAM, but prevents crashes when memory spikes.

### Why AWS EC2 Has 0 MB Swap by Default
AWS images intentionally ship with 0 MB Swap to encourage autoscaling or upgrading to larger instances. In real-world small servers or burst workloads, having 1–2 GB of swap prevents midnight outages.

### Step-by-Step Swap Allocation
```bash
# 1. Allocate a 1GB file on disk
sudo fallocate -l 1G /swapfile

# 2. Restrict permissions (Root only - security critical!)
sudo chmod 600 /swapfile

# 3. Format the file as Linux Swap
sudo mkswap /swapfile

# 4. Activate swap immediately
sudo swapon /swapfile

# 5. Make it permanent across reboots
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 6. Verify active swap
free -m
swapon --show
```

---

## 2. Challenge 2: The Deleted-Yet-Open Disk Ghost Mystery

### 🧒 The 10-Year-Old Concept (The Juice Box Analogy)
- If you drink juice with a straw, and someone rips off the label and throws it in the trash (`rm file.log`), the juice box is **still in your hands holding space** until you let go of the straw!
- In Linux, `rm` only deletes the **directory entry** (unlinks the name). If a running process still has the file open via an active **File Descriptor (FD)**, Linux keeps the disk blocks allocated.

### Symptom in Production
- `df -h` shows disk space is 90%+ full.
- `du -sh /*` or `ls` cannot find where the large files are!

### Investigation & Resolution
```bash
# 1. Catch deleted-yet-open files holding disk space
sudo lsof +L1

# Look for rows marked with (deleted):
# COMMAND     PID USER   FD   TYPE DEVICE  SIZE/OFF NLINK NODE NAME
# ghost_pro  3400 root    3w   REG  259,1 125829120     0 ... phantom.log (deleted)

# 2. Terminate the process holding the descriptor
# IMPORTANT: 'kill' takes a PID (number); 'pkill' takes a name (text)!
sudo kill -9 3400
# OR: sudo pkill -f ghost_producer

# 3. Verify disk blocks are immediately released
sudo lsof +L1
df -h /
```

---

## 3. Challenge 3: Automated Microservice Health Checks

### 🧒 The 10-Year-Old Concept (The Doorbell)
- **Ring Doorbell & Someone Answers:** HTTP Status `200 OK` (Healthy).
- **Ring Doorbell & Nobody Answers / Empty House:** HTTP Status `000` (Process dead or port closed).

### DevOps Monitoring Automation
Instead of manual browser checks, SREs write automated health check monitors:

```bash
# Silent check that extracts ONLY the HTTP status code
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/health)

# curl flags breakdown:
# -s              : Silent mode (no progress bar)
# -o /dev/null    : Discard the body content
# -w "%{http_code}": Print only the 3-digit HTTP response code
```

### Starting the Microservice in the Background
```bash
# Run in background with &
python3 /home/ec2-user/day5_lab/health_app.py &

# Verify process is listening on port 8080
ss -tulpn | grep 8080

# Execute health check
bash /home/ec2-user/day5_lab/health_monitor.sh
# Output: ✅ Service is HEALTHY (Status: 200)
```

---

## 4. Challenge 4: Automated Production Log Rotation (`logrotate`)

### 🧒 The 10-Year-Old Concept (The Never-Ending Diary)
If an application keeps writing log lines forever, the file grows to 10 GB, 50 GB, and crashes the server.  
`logrotate` is an automated robot that:
1. Renames current log to `app.log.1`.
2. Compresses it to `app.log.1.gz` to save 90% disk space.
3. Automatically deletes logs older than N days.

### Production Logrotate Configuration
File location: `/etc/logrotate.d/saad_app`

```text
/var/log/saad_apps/app.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
```

| Directive | Meaning |
| :--- | :--- |
| `daily` | Check and rotate once per day |
| `rotate 7` | Keep the last 7 rotated logs, delete older ones |
| `compress` | Gzip older logs (`.gz`) |
| `missingok` | Do not error if the log file is missing |
| `notifempty` | Do not rotate if the file is empty (0 bytes) |

### Testing & Verification
```bash
# Force an immediate dry-run or execution with verbose output
sudo logrotate -vf /etc/logrotate.d/saad_app

# Check directory contents
ls -la /var/log/saad_apps/
# Result: app.log.1.gz is created and compressed!
```

---

## 5. SRE Production Commands Quick Cheat Sheet

| Task | Command |
| :--- | :--- |
| **Check RAM & Swap** | `free -m` |
| **Active Swap List** | `swapon --show` |
| **Check Disk Free** | `df -h /` |
| **Find Ghost / Open Deleted Files** | `sudo lsof +L1` |
| **Kill Process by PID** | `sudo kill -9 <PID>` |
| **Kill Process by Name** | `sudo pkill -f <ProcessName>` |
| **Inspect Open Ports & Listeners** | `ss -tulpn` |
| **Curl HTTP Status Only** | `curl -s -o /dev/null -w "%{http_code}" <URL>` |
| **Force Test Logrotate Rule** | `sudo logrotate -vf /etc/logrotate.d/<rule_file>` |

---
*Created by Saad Sayyed during DevOps & SRE Production Hands-on Lab.*
