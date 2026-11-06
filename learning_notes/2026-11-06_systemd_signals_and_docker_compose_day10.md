# Day 10 SRE & DevOps Production Learning Notes
**Date:** 2026-11-06  
**Topic:** Linux Systemd Services, Process Signals (SIGTERM/SIGKILL/SIGHUP), Flapping Service SRE Triage, Systemd Timers, and Docker Compose Healthchecks  
**Engineer:** Saad Sayyed  

---

## 1. Linux `systemd` Services & Daemons from Scratch

In production Linux, background processes should NEVER be run with `nohup` or `&`. SREs write systemd service unit files to guarantee auto-healing, boot startup, and centralized logging.

### A. The Anatomy of a Unit File (`/etc/systemd/system/saad-api.service`)
```ini
[Unit]
Description=Saad Production API Service
After=network.target                  # Wait for network stack to be UP

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/day10_systemd_lab
ExecStart=/usr/bin/python3 /home/ec2-user/day10_systemd_lab/api.py
Restart=always                        # Auto-restart on crash or kill!
RestartSec=10                         # Wait 10 seconds before resurrecting

[Install]
WantedBy=multi-user.target             # Enable auto-start on server boot
```

### B. Core Systemd Management Commands
```bash
sudo systemctl daemon-reload           # Tell systemd to re-read files from disk into RAM
sudo systemctl enable --now <name>     # Enable on boot AND start immediately
sudo systemctl status <name>           # Check status (active / failed / activating)
sudo systemctl restart <name>          # Restart the service
sudo journalctl -u <name> -n 20 --no-pager  # Read the last 20 log lines without locking terminal
sudo journalctl -u <name> -f           # Follow logs live in real time
```

### C. The `daemon-reload` Rule (Interview Gold!)
* `systemd` keeps its active unit configurations cached in RAM.
* If you edit a `.service` file with `nano` or `vim`, `systemd` gives a warning: `Unit file changed on disk. Run systemctl daemon-reload`.
* You MUST run `sudo systemctl daemon-reload` before changes take effect!

---

## 2. Linux Process Signals: Graceful Shutdown vs Forced Murder

Signals are asynchronous software interrupts sent to processes via the `kill` command (`kill = send_signal`).

### The 4 Crucial Signals:
1. **`SIGTERM` (Signal 15):** The Polite Request.
   * Default signal when running `kill <PID>`.
   * The app catches it, finishes active database writes, flushes buffers, and exits cleanly with **Exit Code 0** (`Deactivated successfully`).
2. **`SIGKILL` (Signal 9):** The Executioner.
   * Hard-wired into the Linux kernel. **CANNOT be caught, blocked, or ignored!**
   * The kernel instantly deletes the process from RAM (`status=9/KILL`, `Failed with result 'signal'`).
   * Risk: Database corruption and lost in-flight transactions.
3. **`SIGHUP` (Signal 1):** The Live Reload.
   * Tells the app: "Re-read configuration from disk without dropping user connections or stopping the process!"
4. **`SIGINT` (Signal 2):** Terminal Interrupt (`Ctrl+C`).

---

## 3. Production Incident Triage: "The Flapping Service Disaster"
* **Symptom:** Service stuck in `activating (auto-restart)` / flapping loop (restarted 2,500+ times).
* **Investigation:** 
  ```bash
  sudo journalctl -u payment-processor.service -n 20 --no-pager
  ```
* **Root Cause:** App code expected `/etc/payment_processor/config.env` to exist. Deployment pipeline never created the directory.
* **Resolution:**
  ```bash
  sudo mkdir -p /etc/payment_processor
  sudo bash -c 'echo "BANK_API_KEY=secret" > /etc/payment_processor/config.env'
  ```
  The daemon automatically found the configuration on its next 2-second cycle and achieved `active (running)`.

---

## 4. Systemd Timers (`systemd.timer`) vs Legacy Cron Jobs
* **Why replace `cron`?** Cron fails silently, has no status, and misses jobs if the server is off.
* **Systemd Timers:**
  * Two files: `saad-backup.service` (WHAT to do) + `saad-backup.timer` (WHEN to do it).
  * `systemctl list-timers` shows the live countdown clock to the next execution!
  * `Persistent=true` catches up on missed runs upon system boot.

---

## 5. Docker Compose & The Startup Race Condition

### A. Declarative Multi-Tier Orchestration
* Stop running manual `docker run` commands with dozens of flags.
* `docker-compose.yml` declaratively defines services, ports, environment variables, networks, and persistent volumes in a single source of truth.
* `docker compose up -d` boots the entire stack; `docker compose down` cleans it up.

### B. The Race Condition Trap:
* `depends_on: [db]` **ONLY waits for the container process to start**, NOT for PostgreSQL/MySQL to be ready to accept SQL queries!
* The web app boots in 0.1s, tries to connect to port 5432, and crashes with `Connection refused (exit code 1)` while PostgreSQL is still initializing.

### C. The Production Fix: Docker Healthchecks
```yaml
services:
  web:
    image: saad-healthcheck-web:v1
    depends_on:
      db:
        condition: service_healthy  # 🛡️ Holds web app until db passes healthcheck!

  db:
    image: postgres:15-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 2s
      timeout: 3s
      retries: 5
      start_period: 3s
```
* Result: Docker holds the web container until `Container saad-postgres-db Healthy`, guaranteeing zero startup crashes!

