# Linux & Terraform Hands-On Learning Log
**Date:** October 28, 2026  
**Student:** Saad Sayyed  
**Environment:** AWS EC2 (`t3.micro` - Free Tier eligible), Region: `ap-south-1` (Mumbai)  
**OS:** Amazon Linux 2023 (Kernel 6.1)

---

## 📑 Table of Contents
1. [Terraform & AWS Infrastructure Automation](#1-terraform--aws-infrastructure-automation)
2. [Core Linux Architecture & Concepts Learned](#2-core-linux-architecture--concepts-learned)
3. [The 4 Real-World Troubleshooting Labs Solved](#3-the-4-real-world-troubleshooting-labs-solved)
4. [Master Command Cheat Sheet](#4-master-command-cheat-sheet)
5. [Tear Down & Zero-Cost Management](#5-tear-down--zero-cost-management)

---

## 1. Terraform & AWS Infrastructure Automation

### Key Files Created
- **`main.tf`**: Defined AWS provider, automated 4096-bit RSA SSH key pair creation, Security Group (Ports 22 & 80), and an EC2 instance bootstrapped with the practice labs.
- **`variables.tf`**: Managed region (`ap-south-1`) and instance type (`t3.micro`).
- **`outputs.tf`**: Exported public IP and the exact copy-paste `ssh` command.

### Key Takeaways
- **Free Tier Discovery:** In `ap-south-1`, AWS upgraded Free Tier instances from `t2.micro` to **`t3.micro`**.
- **Automated Key Pair:** Instead of manually downloading keys from AWS Console, Terraform's `tls_private_key` and `local_file` generated and saved `linux_lab_key.pem` directly in the project folder with `0400` permissions.
- **Connection Command:**
  ```powershell
  ssh -i linux_lab_key.pem ec2-user@<PUBLIC_IP>
  ```

---

## 2. Core Linux Architecture & Concepts Learned

### A. User Levels (`root` vs Normal User)
- **`root` (User ID `0`)**: The superuser/administrator. Can modify any file, stop any process, and alter system settings. Prompt ends with **`#`**.
- **Normal User (e.g. `ec2-user`, UID `>= 1000`)**: Restricted user. Can only write to their own home folder (`/home/ec2-user`). Prompt ends with **`$`**.

### B. `sudo` and the Security Gatekeeper (`/etc/sudoers`)
- **What is `sudo`?** *"SuperUser DO"* — allows approved normal users to execute commands with root privileges.
- **Why can `ec2-user` run `sudo`?** Because `/etc/sudoers` grants members of the **`wheel`** group root execution:
  ```text
  %wheel ALL=(ALL) ALL
  ```
- **Security Rule:** Never run `chmod 777` on `/etc/sudoers`. If the sudoers file becomes world-writable, Linux security locks everyone out of `sudo`.
- **Drop-in Configuration:** Managed user rules live in `/etc/sudoers.d/` (e.g., `90-cloud-init-users`).

### C. Permissions Breakdown (`chmod`)
Every file has 3 sets of permissions: **User (Owner)**, **Group**, and **Others (World)**.
```text
 -    rwx       r-x       r--      1   ec2-user  ec2-user   98   Oct 28 06:47   run_backup.sh
 │     │         │         │       │      │         │        │         │              │
Type  Owner     Group    Others  Links  Owner     Group    Size    Timestamp       Filename
```
- **Permission Weights:** Read `r = 4`, Write `w = 2`, Execute `x = 1`.
  - `755` = Owner has `rwx` (7), Group has `r-x` (5), Others have `r-x` (5).
  - `644` = Owner has `rw-` (6), Group has `r--` (4), Others have `r--` (4).
  - `000` = Zero permissions (no one can read/write/run).

### D. File Ownership (`chown`)
- Used to change who owns the file:
  ```bash
  sudo chown ec2-user:ec2-user filename
  ```

### E. Output Redirection & The "Rule of Silence"
- **`>` Operator:** Redirects standard output into a file instead of displaying it on the screen:
  ```bash
  echo "Backup finished" > backup.log
  ```
- **Rule of Silence:** If a Linux command succeeds without errors, it produces no output and quietly exits.

---

## 3. The 4 Real-World Troubleshooting Labs Solved

### 🎯 Challenge 1: Broken Web Server (Nginx)
- **Problem:** `sudo systemctl start nginx` failed with an exit code.
- **Investigation:**
  - Checked status: `sudo systemctl status nginx`
  - Tested syntax: `sudo nginx -t` (identified `unexpected "}"` on line 15 due to missing semicolon on line 14).
- **Fix:** Fixed line 14 (`worker_connections 1024;`) and removed the invalid `/etc/nginx/conf.d/broken_site.conf`.
- **Result:** Nginx started successfully (`active (running)` in green) and served the live web page on port 80 at `http://<PUBLIC_IP>`.

### 🎯 Challenge 2: Permission Denied on Backup Script
- **Problem:** Running `/home/ec2-user/linux_lab/run_backup.sh` returned `bash: Permission denied`.
- **Investigation:** `ls -l` revealed permissions were set to `----------` (000) and owned by `root`.
- **Fix:** 
  - Granted execute rights: `chmod +x run_backup.sh` (or `chmod 755`).
  - Changed ownership: `sudo chown ec2-user:ec2-user run_backup.sh`.
- **Result:** Successfully ran the script, modified its content using `nano`, and verified the generated `backup.log`.

### 🎯 Challenge 3: Disk Space Investigation
- **Problem:** Simulated heavy disk usage alert.
- **Investigation:**
  - Inspected disk partitions: `df -h`
  - Learned why `/var/log` is the standard location for logs and growth.
  - Learned the whole-system search: `sudo find / -type f -size +100M 2>/dev/null`
  - Discovered `/var/log/app_dump/huge_old_temp_file.log` taking 150 MB.
- **Fix:** Deleted the old dump with `sudo rm -f` and freed disk space.
- **Concept Learned:** `ls -l` displays raw bytes (`157286400`), while `ls -lh` converts them into human-readable format (`150M`).

### 🎯 Challenge 4: Process Hunting & Killing Runaway Tasks
- **Problem:** An unauthorized script `rogue_worker.sh` was running quietly in the background.
- **Investigation:**
  - Listed active processes: `ps aux | grep rogue` (or `pgrep -a rogue`).
  - Identified the **PID (Process ID)** in column 2.
- **Fix:** Terminated the process using `sudo kill <PID>` (and learned about `kill -9` for stubborn processes).
- **Result:** Verified termination with `pgrep -a rogue` (returned empty).

---

## 4. Master Command Cheat Sheet

| Command | Purpose |
| :--- | :--- |
| `pwd` | Print current working directory |
| `ls -lh` | List files with permissions and human-readable sizes (MB/GB) |
| `df -h` | Show disk space usage across partitions |
| `du -sh /* 2>/dev/null \| sort -hr \| head -n 5` | Show top 5 largest folders on system |
| `find / -type f -size +100M 2>/dev/null` | Find all files over 100 MB anywhere on disk |
| `systemctl status <service>` | Check if a system service is running or failed |
| `systemctl start/restart <service>` | Start or restart a system service |
| `journalctl -xeu <service>` | View detailed error logs of a failed service |
| `chmod +x <file>` | Make a script runnable |
| `chown <user>:<group> <file>` | Change owner and group of a file |
| `ps aux \| grep <name>` | Find running processes by name |
| `kill <PID>` | Politely stop a process (SIGTERM 15) |
| `kill -9 <PID>` | Forcefully stop a process immediately (SIGKILL 9) |
| `nano <file>` | Easy command-line text editor (`Ctrl+O` save, `Ctrl+X` exit) |

---

## 5. Tear Down & Zero-Cost Management

To guarantee **$0 (Zero Cost)** after completing your practice:

1. **Exit the SSH session:**
   ```bash
   exit
   ```
2. **From your local Windows terminal (`c:\Users\SaadSayyed\Desktop\terraform`), destroy all AWS resources:**
   ```powershell
   terraform destroy
   ```
3. Type **`yes`** when prompted.

Terraform will terminate the EC2 instance, release the EBS storage volume, delete the security group, and unregister the AWS key pair.
