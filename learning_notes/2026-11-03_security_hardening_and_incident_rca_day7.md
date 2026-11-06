# Day 7: Cloud & Linux Security Hardening, Inode Management & Production Incident RCA
**Date:** November 3, 2026 (Day 7 Session)  
**Student:** Saad Sayyed  
**Environment:** AWS EC2 (`t3.micro` - Free Tier $0), Region: `ap-south-1` (Mumbai)  
**Topics:** SSH Hardening, File Permissions & `chattr +i`, Login Auditing, AWS Security Groups vs `iptables`, Inode Exhaustion (`df -i`), Environment Variables, Git Production Rollback & Formal Root Cause Analysis (RCA)

---

## 📑 Table of Contents
1. [Cost Assurance: 100% Free Tier ($0.00 Cost)](#1-cost-assurance-100-free-tier-000-cost)
2. [Challenge 1: SSH Hardening (Key-Only Authentication)](#2-challenge-1-ssh-hardening-key-only-authentication)
3. [Challenge 2: The World-Writable 777 Hazard & The Immutable Lock (`chattr +i`)](#3-challenge-2-the-world-writable-777-hazard--the-immutable-lock-chattr-i)
4. [Challenge 3: The Intrusion Detective (`who`, `last`, `journalctl`)](#4-challenge-3-the-intrusion-detective-who-last-journalctl)
5. [Challenge 4: Cloud Firewall Gatekeeper (AWS Security Groups vs. `iptables`)](#5-challenge-4-cloud-firewall-gatekeeper-aws-security-groups-vs-iptables)
6. [Challenge 5: Inode Exhaustion (`df -i` vs `df -h`) & High-Speed Purging](#6-challenge-5-inode-exhaustion-df--i-vs-df--h--high-speed-purging)
7. [Challenge 6: Production Secrets & Environment Variables](#7-challenge-6-production-secrets--environment-variables)
8. [Challenge 7: P1 Outage Response, Emergency Git Rollback & Formal RCA](#8-challenge-7-p1-outage-response-emergency-git-rollback--formal-rca)
9. [Official Root Cause Analysis (RCA) Report Template](#9-official-root-cause-analysis-rca-report-template)
10. [Day 7 Master Commands Quick Reference](#10-day-7-master-commands-quick-reference)

---

## 1. Cost Assurance: 100% Free Tier ($0.00 Cost)
- **EC2 Instance:** `t3.micro` (Within 750 free hours/month limit)
- **EBS Storage:** 8 GB `gp3` (Within 30 GB free storage limit)
- **Total Incurred Cost:** **$0.00**
- Running `terraform destroy` completely releases all cloud assets.

---

## 2. Challenge 1: SSH Hardening (Key-Only Authentication)

### The Security Risk
Default cloud images or misconfigured servers that allow passwords invite automated internet bot attacks (brute-force dictionary scans).

### Hardening Actions
In modern Linux, snippet files in `/etc/ssh/sshd_config.d/*.conf` override `/etc/ssh/sshd_config`.  
Because SSH is the master entrance, this directory has permissions `700` (`drwx------ root root`), requiring `sudo`.

```bash
# 1. Inspect configuration override
sudo cat /etc/ssh/sshd_config.d/50-cloud-init.conf

# 2. Enforce key-only authentication and disable root login
PasswordAuthentication no
PermitRootLogin no

# 3. Always test SSH syntax before restarting
sudo sshd -t

# 4. Reload service with zero connection drop
sudo systemctl reload sshd

# 5. Verify live active settings
sudo sshd -T | grep -E "passwordauthentication|permitrootlogin"
```

---

## 3. Challenge 2: The World-Writable 777 Hazard & The Immutable Lock (`chattr +i`)

### Why `chmod 777` is a Fatal Mistake
- Permission layout: **Owner (User) | Group | Others (World)**
- Setting `777` (`-rwxrwxrwx`) grants full read, write, and execute permissions to any untrusted local account or compromised service on the host.

### Who Has Authority to Run `chmod`?
In Linux, **only two entities** can run `chmod` on a file:
1. The **File Owner** (`chown user:group`).
2. The **Superuser (`root`)**.

### Restricting Access
```bash
# 1. Lock down confidential secrets (API keys, DB credentials) to Owner Read/Write only
sudo chmod 600 /etc/company_secrets/stripe_payment_keys.env

# 2. The Ultimate SRE Lock: Immutable Flag (chattr +i)
# Freezes the file: cannot be modified, deleted, renamed, or chmod-ed even by root!
sudo chattr +i /etc/company_secrets/stripe_payment_keys.env

# 3. Verify attributes
lsattr /etc/company_secrets/stripe_payment_keys.env
# Shows: ----i---------

# 4. To unfreeze when legitimately updating
sudo chattr -i /etc/company_secrets/stripe_payment_keys.env
```

---

## 4. Challenge 3: The Intrusion Detective (`who`, `last`, `journalctl`)

### Security Auditing Commands
```bash
# See active interactive users logged in right now
who

# Inspect login history, login source IPs, and session duration
last -n 10

# Scan SSH daemon logs for incoming brute-force attempts and bot probes
sudo journalctl -u sshd -n 25 --no-pager
```

---

## 5. Challenge 4: Cloud Firewall Gatekeeper (AWS Security Groups vs. `iptables`)

### Defense-in-Depth Comparison

| Layer | Technology | Location | Behavior |
| :--- | :--- | :--- | :--- |
| **Outer Wall** | **AWS Security Group** | AWS Nitro / VPC Virtual Router | Blocks packets outside the VM. **Zero CPU/RAM impact**. Modifying via Terraform takes 1–2s with **zero server reboot**! |
| **Inner Guard** | **Linux `iptables` / `nftables`** | Linux OS Kernel | Filters traffic inside the OS. Allows granular host-level rules (e.g., banning a specific attacker IP). |

### Real-World IP Banning vs. Port Shutdown
- **Port 80 Drop (`0.0.0.0/0`):** Shuts down the website for all paying customers worldwide.
- **Source IP Drop (`-s <attacker_ip>`):** Keeps the website open for legitimate customers while blacklisting the single abusive IP.

### `iptables` Workflow
```bash
# Install iptables on Amazon Linux 2023
sudo dnf install -y iptables

# Drop incoming traffic targeting Port 80
sudo iptables -A INPUT -p tcp --dport 80 -j DROP

# Ban a single attacker IP
sudo iptables -A INPUT -s 198.51.100.42 -j DROP

# Add a kernel logging camera before dropping
sudo iptables -I INPUT 1 -p tcp --dport 80 -j LOG --log-prefix "🚨 BLOCKED_TRAFFIC: "

# View rules with packet and byte counters
sudo iptables -L INPUT -v -n

# Check kernel logs for caught attacker IPs
sudo dmesg | grep "BLOCKED_TRAFFIC" | tail -n 5

# Flush / restore all iptables rules
sudo iptables -F
```

---

## 6. Challenge 5: Inode Exhaustion (`df -i` vs `df -h`) & High-Speed Purging

### The Inode Mystery
- `df -h` measures **Disk Space (Gigabytes/Megabytes)**.
- `df -i` measures **Inodes (File Key Tags / Total Number of Allowed Files)**.
- Every file requires 1 Inode. If a runaway script creates millions of 0-byte or 1-byte files, `df -h` shows gigabytes free, but Linux throws `No space left on device` because **Inodes are 100% exhausted**.

### High-Speed Purge: `rm` vs `find -delete`
- `rm *.tmp`: Bash expands all filenames into the command line buffer (`ARG_MAX`). On thousands of files, it crashes with:  
  `-bash: /bin/rm: Argument list too long`
- `find /dir -type f -name "*.tmp" -delete`: Bypasses shell argument expansion and executes atomic kernel-level deletions.

```bash
# Check Inode utilization
df -i /

# Count files in a bloated directory
find /home/ec2-user/day7_security_lab/session_storage -type f | wc -l

# Purge thousands of files safely in seconds
find /home/ec2-user/day7_security_lab/session_storage -type f -name "*.tmp" -delete
```

---

## 7. Challenge 6: Production Secrets & Environment Variables

### Security Best Practice
Never commit database credentials or API tokens into source code repositories. Applications must extract credentials dynamically from the operating system environment.

### Syntax Rule
In Bash, **never put spaces around `=`**!
- `VAR = val` ❌ (Throws: `-bash: export: '=': not a valid identifier`)
- `VAR=val` ✅

```bash
# 1. Export variable to child processes
export PROD_DB_PASSWORD="SuperSecretPassword123"

# 2. Verify variable in environment memory
echo $PROD_DB_PASSWORD
printenv | grep PROD_DB_PASSWORD

# 3. Python reads it via:
# os.getenv("PROD_DB_PASSWORD")
```

---

## 8. Challenge 7: P1 Outage Response, Emergency Git Rollback & Formal RCA

### The Anti-Pattern: "Never Hot-Edit Production with `nano`"
1. Editing production code directly creates uncommitted drift (`git status: modified`).
2. Subsequent automated CI/CD deployments will overwrite manual hotfixes.
3. Patching one line may overlook deeper logic flaws (as seen when `v2.0` returned `broken`).
4. **SRE Rule:** Restore service first via **clean Git Rollback**, then investigate offline.

### The Emergency Git Rollback Workflow
```bash
# 1. Diagnose crash logs
sudo journalctl -u payment-api.service -n 15 --no-pager
# Root Cause: ModuleNotFoundError: No module named 'non_existent_crypto_module_xyz'

# 2. Enter project repository
cd /home/ec2-user/production_app

# 3. Inspect commit log
git log --oneline

# 4. Roll back cleanly to the stable release tag
git checkout -f v1.0.0-stable

# 5. Restart application service
sudo systemctl restart payment-api.service

# 6. Verify service health
sudo systemctl status payment-api.service
curl http://127.0.0.1:8080/
# Output: {"status": "ONLINE", "version": "1.0.0", "message": "Payments Processing Normal"}
```

---

## 9. Official Root Cause Analysis (RCA) Report Template

```text
================================================================================
                    INCIDENT ROOT CAUSE ANALYSIS (RCA)
================================================================================
Incident ID:          INC-20261103-01
Severity:             P1 (Critical - Payment Gateway Down)
Date & Time:          November 3, 2026 - 07:44 UTC
Service Affected:     Payment Processing Gateway (payment-api.service)
Lead SRE:             Saad Sayyed
Status:               RESOLVED

1. EXECUTIVE SUMMARY:
At 07:44 UTC, a new software release (v2.0.0) was deployed to the production
payment microservice. Immediately following the deployment, the application
crashed and entered an infinite crash loop, resulting in a complete outage of
customer checkout capabilities. SRE on-call executed an emergency Git rollback
to stable release v1.0.0-stable at 07:54 UTC, restoring full service. Total
downtime: 10 minutes.

2. ROOT CAUSE:
The developer's commit (cdfb773) introduced an unvetted import dependency
('non_existent_crypto_module_xyz') in app.py without packaging the dependency
or testing application startup. Upon execution by systemd, Python threw an
unhandled 'ModuleNotFoundError', causing process termination with exit code 1.

3. TIMELINE:
- 07:44 UTC: Release v2.0.0 deployed by development team.
- 07:45 UTC: PagerDuty alert triggered; systemd reporting exit-code 1/FAILURE.
- 07:47 UTC: SRE inspected journalctl logs and identified missing module.
- 07:51 UTC: Decision made to execute immediate git rollback rather than hot-fixing.
- 07:53 UTC: 'git checkout -f v1.0.0-stable' executed; systemd service restarted.
- 07:54 UTC: Health check verified (HTTP 200 OK); payment processing restored.

4. PREVENTATIVE & CORRECTIVE ACTIONS (CAPA):
[Action 1] CI/CD Smoke Testing: Implement mandatory automated unit tests and
           container startup tests in the deployment pipeline to block builds
           containing unresolvable imports.
[Action 2] Canary / Blue-Green Deployments: Deploy updates to 5% of traffic
           first with automated health check validation before full rollout.
[Action 3] Least Privilege Policy: Restrict direct production SSH deployments;
           all releases must flow through versioned pipeline stages.
================================================================================
```

---

## 10. Day 7 Master Commands Quick Reference

| Action | Command |
| :--- | :--- |
| **Test SSH Configuration** | `sudo sshd -t` |
| **Check Active SSH Options** | `sudo sshd -T \| grep <setting>` |
| **Freeze File Immutability** | `sudo chattr +i <filename>` |
| **Unfreeze File Immutability** | `sudo chattr -i <filename>` |
| **View Active Logged-in Users** | `who` |
| **View Historical Logins** | `last -n 5` |
| **Check Inodes Availability** | `df -i /` |
| **Check Disk Bytes Availability** | `df -h /` |
| **Fast Inode Purge** | `find <dir> -type f -name "<pattern>" -delete` |
| **Export Environment Variable** | `export KEY="value"` |
| **Check Service Crash Logs** | `sudo journalctl -u <service> -n 20 --no-pager` |
| **Emergency Git Rollback** | `git checkout -f <stable_tag_or_hash>` |

---
*Created by Saad Sayyed during DevOps, Cloud Security & SRE Production Incident Response Lab.*
