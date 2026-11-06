# Cloud & DevOps Architecture Learning Log - Day 4
**Date:** October 30, 2026 (Day 4 Session)  
**Student:** Saad Sayyed  
**Environment:** AWS EC2 (`t3.micro` - Free Tier $0), Region: `ap-south-1` (Mumbai)  
**Topics:** AWS Metadata Service (IMDSv2), Custom Systemd Service Creation, Nginx Reverse Proxy (502 Bad Gateway), Tarball Archiving & SHA-256 Cryptographic Checksums

---

## 📑 Table of Contents
1. [Core Concepts Mastered Today](#1-core-concepts-mastered-today)
2. [Challenge 1: Cloud Self-Awareness (AWS Metadata IMDSv2)](#2-challenge-1-cloud-self-awareness-aws-metadata-imdsv2)
3. [Challenge 2: Writing Systemd Service Units From Scratch](#3-challenge-2-writing-systemd-service-units-from-scratch)
4. [Challenge 3: The Nginx Reverse Proxy & 502 Bad Gateway](#4-challenge-3-the-nginx-reverse-proxy--502-bad-gateway)
5. [Challenge 4: DevOps Archiving (`tar`) & Checksums (`sha256sum`)](#5-challenge-4-devops-archiving-tar--checksums-sha256sum)
6. [Private vs. Public IP Retrieval Cheat Sheet](#6-private-vs-public-ip-retrieval-cheat-sheet)

---

## 1. Core Concepts Mastered Today

### A. Private vs. Public IP in AWS
- **Private IP (`172.31.x.x`):** Internal to AWS data center; unroutable from your laptop browser.
- **Public IP (`13.233.17.37`):** Globally reachable over the internet. Web applications must be accessed via Public IP from outside AWS.

---

## 2. Challenge 1: Cloud Self-Awareness (AWS Metadata IMDSv2)

### The Magic IP: `169.254.169.254`
- Every AWS EC2 instance can query its own identity through this link-local address without needing IAM credentials or web console access.
- **IMDSv2 Security Handshake:**
  1. **Get Session Token:**
     ```bash
     TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
     ```
  2. **Query Metadata:**
     - Instance ID: `curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id`
     - Availability Zone: `curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone`
     - Private IP: `curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4`
     - Public IP: `curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4`

---

## 3. Challenge 2: Writing Systemd Service Units From Scratch

### Who Names the Service?
👉 **YOU DO!** The name of the service is the filename placed inside `/etc/systemd/system/<name>.service`.

### Deep Dive: Breakdown of the Service Unit
```ini
[Unit]
Description=Saad Custom Web App on Port 3000
After=network.target

[Service]
Type=simple
User=ec2-user
ExecStart=/usr/bin/python3 /home/ec2-user/devops_lab/app.py
Restart=always

[Install]
WantedBy=multi-user.target
```
- **`After=network.target`:** Waits until network interfaces are initialized before launching the app.
- **`User=ec2-user`:** Principle of Least Privilege. Running web apps as `root` is dangerous; running as an unprivileged user contains potential vulnerabilities.
- **`ExecStart`:** Full absolute path to the executable and script.
- **`Restart=always`:** Immortality switch — automatically restarts the process if it crashes.
- **`WantedBy=multi-user.target`:** Connects the service to standard multi-user boot targets for `systemctl enable`.

---

## 4. Challenge 3: The Nginx Reverse Proxy & 502 Bad Gateway

### Why Use a Reverse Proxy?
- Users access websites via standard HTTP (Port 80) or HTTPS (Port 443) without specifying custom ports like `:3000` or `:8080`.
- Nginx acts as the front receptionist, receiving requests on Port 80 and quietly forwarding them to the internal service on Port 3000.

### Diagnosing 502 Bad Gateway
- **Definition:** Nginx is running and answering requests, but the upstream backend service it is attempting to contact is dead, unreachable, or misconfigured.
- **The Bug:** `/etc/nginx/conf.d/reverse_proxy.conf` pointed to dead port `9999` (`proxy_pass http://127.0.0.1:9999;`).
- **The Fix:** Changed target to `http://127.0.0.1:3000;`, tested with `sudo nginx -t`, and reloaded with `sudo systemctl reload nginx`.
- **Result:** Successfully accessed the Python backend directly on Port 80!

---

## 5. Challenge 4: DevOps Archiving (`tar`) & Checksums (`sha256sum`)

### The Concept of Tarballs (`.tar.gz`)
- **`c` (Create)**: Create a new archive.
- **`z` (Zip)**: Compress with gzip.
- **`v` (Verbose)**: Print progress to terminal.
- **`f` (Filename)**: Designate the target file.
- **Create:** `tar -czvf my_backup.tar.gz raw_logs`
- **Extract (Unzip):** `tar -xzvf my_backup.tar.gz`

### Cryptographic Hashing with `sha256sum`
- **Purpose:** Generates a unique 64-character digital fingerprint of a file.
- **Core Truth:**
  - Before = After ➡️ File was **NOT modified** and **NOT corrupted** during transit.
  - Before ≠ After ➡️ File was **tampered with or damaged** (even modifying a single character completely alters the hash).
- **Command:** `sha256sum my_backup.tar.gz`

---

## 6. Private vs. Public IP Retrieval Cheat Sheet

| Requirement | Fastest Command |
| :--- | :--- |
| **Private IP (Internal)** | `hostname -I` |
| **Public IP (Internet)** | `curl -s ifconfig.me` |
| **AWS Cloud Identity** | Query `http://169.254.169.254/latest/meta-data/` |
