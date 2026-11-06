# 🚀 Production Cloud, DevOps & MLOps Engineering Master Repository
**Engineer:** Saad Sayyed  
**Focus:** Cloud Infrastructure, Linux Systems & Kernel Internals, Containerization, Terraform IaC, SRE Incident Response, and MLOps  

---

## 📌 Architecture & Daily Production Labs
This repository contains real-world, hands-on production code, infrastructure configurations, and root-cause incident analyses from a structured daily engineering curriculum:

* **🐧 Linux Systems & Kernel Deep Dives:**
  * Network namespaces (`netns`), virtual ethernet cables (`veth` pairs), and virtual bridges (`brctl`/`ip`).
  * Process lifecycle, systemd custom unit daemons, and signals (`SIGTERM`, `SIGKILL`, `SIGHUP`).
  * Linux troubleshooting: Inode exhaustion (`df -i`), deleted-yet-open file leaks (`lsof +L1`), OOM Killer & swap tuning, file permissions (`chmod`, `chattr +i`).
* **🐳 Containerization (Docker):**
  * Production `Dockerfile` optimization, multi-container custom networks (`company-network`), internal DNS resolution.
  * Stateful data persistence using named Docker volumes vs ephemeral layers.
* **☁️ Infrastructure as Code (Terraform & AWS):**
  * Multi-resource provisioning with AWS Free Tier (EC2, Security Groups, TLS Key Pairs, locals, variables, and dynamic outputs).
  * Automated user-data bootstrapping and cloud hardening.
* **🚨 Production Incident Response (SRE):**
  * Hands-on triage of memory leaks, crash-looping services, port collisions (`EADDRINUSE`), broken dependencies, and security auditing.

---

## 🛡️ Security & Zero Credentials Standard
This repository strictly enforces an automated `.gitignore` policy:
* Zero credentials, zero private keys (`*.pem`, `*.key`), and zero `.env` files are ever committed.
* Terraform state files (`*.tfstate`) and provider binaries are strictly excluded.

