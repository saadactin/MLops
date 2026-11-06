# Linux Networking Foundations - Day 3 (Part 1)
**Date:** October 29, 2026 (Evening Session)  
**Student:** Saad Sayyed  
**Environment:** AWS EC2 (`t3.micro` - Free Tier $0), Region: `ap-south-1` (Mumbai)  
**Topic:** Linux Networking Basics & Troubleshooting

---

## 📑 Table of Contents
1. [Core Networking Concepts Mastered](#1-core-networking-concepts-mastered)
2. [Challenge 1: The Broken DNS Mystery](#2-challenge-1-the-broken-dns-mystery)
3. [Challenge 2: Local Speed-Dial (`/etc/hosts`) & `tee -a`](#3-challenge-2-local-speed-dial-etchosts--tee--a)
4. [Tear Down Instructions for Tonight](#4-tear-down-instructions-for-tonight)
5. [Agenda for Tomorrow (Day 3 Part 2)](#5-agenda-for-tomorrow-day-3-part-2)

---

## 1. Core Networking Concepts Mastered

### A. Names vs. Numbers (The Core Rule)
- **Humans use names:** `google.com`, `github.com`.
- **Computers and routers ONLY use numbers:** IP addresses like `142.250.193.110` or `1.1.1.1`.
- **DNS (Domain Name System):** The global "Phonebook" of the internet that translates names into IP numbers.
- **Why Google has multiple addresses in `nslookup`:** Google handles billions of users; providing 4–5 IP addresses allows incoming traffic to be distributed across servers.

### B. The Secret Phonebook File: `/etc/resolv.conf`
- When you type a domain name, Linux checks `/etc/resolv.conf`.
- The `nameserver` line (e.g. `nameserver 172.31.0.2` in AWS) tells Linux which DNS server to query.

---

## 2. Challenge 1: The Broken DNS Mystery

### The Experiment
- **Direct IP Ping:** `ping -c 3 1.1.1.1` succeeded (no phonebook needed because the number is known).
- **Simulated DNS Failure:** Wiped `/etc/resolv.conf` using `sudo truncate -s 0 /etc/resolv.conf`.
- **Result:**
  - `ping 1.1.1.1` **SUCCEEDED** (the network card, wire, and gateway were working).
  - `google.com` **FAILED** with `Could not resolve host`.

> 💡 **Golden Rule of Network Troubleshooting:**  
> If you can reach numbers (`1.1.1.1`), but NOT names (`google.com`), your Internet cable is NOT broken — **only your DNS phonebook is broken!**

---

## 3. Challenge 2: Local Speed-Dial (`/etc/hosts`) & `tee -a`

### Local Domain Mapping
- **What is `/etc/hosts`?** A local text file on disk that acts as a personal speed-dial list.
- **Priority Rule:** Linux **always checks `/etc/hosts` before** querying the public internet DNS!
- **Fix:** Added `127.0.0.1  backend.corp.internal` to `/etc/hosts`, allowing `ping_backend.sh` to resolve the private corporate microservice.

### Deep Dive: Why `sudo echo ... >> file` Fails vs. `sudo tee -a`
- **The Trap:** `sudo echo "text" >> /etc/hosts` fails with `Permission denied` because `sudo` applies only to `echo`, while `>>` is handled by the unprivileged user shell.
- **What is `tee`?** Named after a plumber's **T-junction pipe**. It takes input from standard input and splits it in two directions:
  1. Displays it on the terminal screen.
  2. Writes it into the file on disk.
- **The `-a` Flag:** Stands for **Append** (adds to the bottom without overwriting).
- **The Command:**
  ```bash
  echo "127.0.0.1 backend.corp.internal" | sudo tee -a /etc/hosts
  ```

---

## 4. Tear Down Instructions for Tonight

To guarantee **$0 (Zero Cost)** while you rest:

1. **Exit the SSH session:**
   ```bash
   exit
   ```
2. **From your Windows terminal (`c:\Users\SaadSayyed\Desktop\terraform`), destroy the resources:**
   ```powershell
   terraform destroy
   ```
3. Type **`yes`** when prompted.

---

## 5. Agenda for Tomorrow (Day 3 Part 2)

Tomorrow when you run `terraform apply`, we will jump straight into:
- **Challenge 3: Port Probing & Service Discovery**
  - How ports work (Ports 80, 8080, 5000, 22).
  - Probing open ports using `ss -tulnp`, `nc -zv` (Netcat), and `curl -i`.
- **Challenge 4: The 127.0.0.1 (Loopback) vs 0.0.0.0 (Wildcard) Trap**
  - Why developers say *"It works on my machine, but no one on the internet can see it!"*
  - Fixing interface bindings so external traffic can reach your app.
