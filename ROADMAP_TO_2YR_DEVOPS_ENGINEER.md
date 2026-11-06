# 🚀 MASTER BLUEPRINT: Zero to 2-Year Production Cloud & DevOps Engineer
**Target Role:** Cloud & DevOps Engineer (Mid-Level / 2 Years Experience Equivalent)  
**Architect:** Saad Sayyed  
**Guiding Philosophy:** 100% Real-World Production Labs | $0 Cloud Cost Guarantee | Hands-On Incident Simulation

---

## 🔒 NON-NEGOTIABLE CORE POLICY: ZERO COST ($0.00) & LOCAL DOCKER FIRST
*(This policy is permanently locked into workspace configuration and automatically enforced in every session)*

1. **Zero Dollar ($0.00) Cost Guarantee:**
   - All labs, commands, and exercises must be **100% $0.00 cost**.
   - **MANDATORY PERMISSION RULE:** If ANY exercise or AWS service would ever incur even $0.01 (one cent) of cost, the agent MUST explicitly inform Saad and get explicit written permission FIRST before executing anything. If no free tier / local option exists, do NOT proceed without asking.
   - At the end of every session, all AWS resources provisioned via Terraform must be completely destroyed with `terraform destroy -auto-approve` and verified with `terraform state list` (must be completely empty).

2. **Local Docker Desktop Engine Priority:**
   - Saad has **Docker Desktop (Docker version 28.3.3)** installed locally on Windows.
   - All Docker containerization, `Dockerfile` creation, image building, container networking, and `docker-compose` multi-service labs will be run **LOCALLY on Docker Desktop** — ultra-fast, offline capable, and 100% $0.00 cost!

3. **The 4-Challenge Daily Production Rule:**
   - In every session, there are **4 challenges**:
     - **[CHALLENGE 1]** 🐧 **Mandatory Linux Deep Dive** (Linux is NEVER skipped!).
     - **[CHALLENGE 2]** 🐳 **Docker / Platform Core Engineering** (Local Docker).
     - **[CHALLENGE 3]** 🚨 **Production Incident & SRE Triage** (Breaking & fixing).
     - **[CHALLENGE 4]** ☁️ **Infrastructure as Code (Terraform) / Cloud Architecture** ($0 Free Tier).

---

## 🗺️ The 4-Phase Curriculum: From 38% ➡️ 100%

```
[CURRENT STATUS: 38%]
        ⬇️
[PHASE 1: DOCKER (LOCAL) + LINUX CONTAINER INTERNALS + IAC] ───► Reaches 55%
        ⬇️
[PHASE 2: CI/CD AUTOMATION + LINUX BASH SCRIPTING] ────────────► Reaches 70%
        ⬇️
[PHASE 3: ENTERPRISE AWS NETWORKING (VPC/ALB) + IAC] ──────────► Reaches 85%
        ⬇️
[PHASE 4: KUBERNETES (K8S) ORCHESTRATION + SRE] ───────────────► Reaches 100% 🏆
```

---

## 📅 Detailed Phase Breakdown

### 🐳 PHASE 1: Docker Containers, Linux Internals & IaC (Days 8 – 11)
*Platform: Local Docker Desktop (Engine v28.3.3) on Windows + Linux Containers ($0.00 Cost)*

- **Day 8: Docker 101 — Packaging Your First Microservice**
  - **Challenge 1 (Linux):** Linux Namespaces & cgroups — How Linux isolates processes without a virtual machine!
  - **Challenge 2 (Docker - Local):** Writing a production-grade `Dockerfile` for a Python/Node microservice.
  - **Challenge 3 (Incident):** "Works on my machine, crashes in Docker" — missing runtime dependencies & environment injection.
  - **Challenge 4 (Terraform):** Managing container configuration & environment variables via Terraform local modules ($0 Cost).

- **Day 9: Container Networking & Storage (Volumes & Bind Mounts)**
  - **Challenge 1 (Linux):** Linux Virtual Network Bridges (`docker0`, `veth` interfaces, packet forwarding).
  - **Challenge 2 (Docker - Local):** Port mapping (`-p 80:8080`) vs Container-to-Container network communication.
  - **Challenge 3 (Incident):** Data Loss Incident — Why container restarts wipe data and how Docker Volumes preserve state.
  - **Challenge 4 (Terraform):** Securing container host ports using AWS Security Groups (Free Tier).

- **Day 10: Multi-Container Architecture with `docker-compose`**
  - **Challenge 1 (Linux):** Linux IPC (Inter-Process Communication) & domain socket files (`/var/run/docker.sock`).
  - **Challenge 2 (Docker - Local):** Multi-tier app orchestration (Web App + PostgreSQL / Redis database).
  - **Challenge 3 (Incident):** "Database connection refused on startup" — race conditions & Docker health check dependencies (`depends_on: condition: service_healthy`).
  - **Challenge 4 (Terraform):** Managing multi-tier application environment variables in Terraform locals.

- **Day 11: Production Image Optimization & Vulnerability Scanning**
  - **Challenge 1 (Linux):** Exploring the Linux root filesystem layers (`overlay2` storage driver).
  - **Challenge 2 (Docker - Local):** Multi-stage builds: Shrinking image size from 1.2 GB down to 50 MB (Alpine / distroless).
  - **Challenge 3 (Incident):** High CVE Vulnerability Alert — scanning and stripping root privileges (`USER nonroot`).
  - **Challenge 4 (Terraform):** Pushing images to AWS Elastic Container Registry (ECR Free Tier).

---

### ⚙️ PHASE 2: CI/CD Pipelines & Linux Automation (Days 12 – 14)
*Goal: Stop deploying code by hand over SSH. Automate everything!*

- **Day 12: GitHub Actions Automated Build & Test Pipelines**
  - **Challenge 1 (Linux):** Writing automated Linux Bash verification scripts (`set -euo pipefail`).
  - **Challenge 2 (CI/CD):** Writing your first GitHub Actions workflow (`.github/workflows/deploy.yml`).
  - **Challenge 3 (Incident):** Breaking the Build: Simulated broken commit blocked automatically by the CI test runner.
  - **Challenge 4 (Terraform):** Setting up secure AWS IAM roles for GitHub Actions using OpenID Connect (OIDC - zero hardcoded AWS secret keys!).

- **Day 13: Continuous Deployment (CD) to Docker Host**
  - **Challenge 1 (Linux):** Linux SSH Automation: deploying non-interactively using deploy keys and remote commands.
  - **Challenge 2 (CI/CD):** Automated deployment trigger: merge to `main` builds, tags, and rolls out new Docker image.
  - **Challenge 3 (Incident):** Zero-Downtime Rollout: Replacing an old container with a new one without dropping ongoing user connections.
  - **Challenge 4 (Terraform):** Updating Terraform tags and version tracking automatically from CI/CD.

- **Day 14: Automated Rollback on Pipeline Failure**
  - **Challenge 1 (Linux):** Advanced log streaming and exit code propagation in Bash.
  - **Challenge 2 (CI/CD):** Automated health check verification step in pipeline (`curl --retry`).
  - **Challenge 3 (Incident):** Simulated faulty rollout triggers automated instant rollback in pipeline.
  - **Challenge 4 (Terraform):** Infrastructure drift detection: running `terraform plan -detailed-exitcode` in GitHub Actions.

---

### ☁️ PHASE 3: Enterprise AWS Cloud Architecture with Terraform (Days 15 – 17)
*Goal: Build the network infrastructure real enterprises use (100% Free Tier Only)!*

- **Day 15: Production Custom VPC (Virtual Private Cloud)**
  - **Challenge 1 (Linux):** Linux Routing Tables, Subnet masks (`/24`, `/16`), and default gateways (`ip route`).
  - **Challenge 2 (Terraform/AWS):** Building a custom VPC from scratch with Public and Private Subnets across 2 Availability Zones.
  - **Challenge 3 (Incident):** "Private instance cannot download packages" — diagnosing missing NAT Gateway or Route Table entry.
  - **Challenge 4 (Security):** Implementing AWS Network Access Control Lists (NACLs) vs Security Groups.

- **Day 16: Application Load Balancers (ALB) & High Availability**
  - **Challenge 1 (Linux):** Load balancing algorithms (Round Robin, Least Connections) & HTTP Header inspection (`X-Forwarded-For`).
  - **Challenge 2 (Terraform/AWS):** Provisioning an AWS Application Load Balancer (ALB) and Target Groups.
  - **Challenge 3 (Incident):** Target Group Unhealthy Alert (`502 Bad Gateway` vs `504 Gateway Timeout`) — fixing ALB health check paths.
  - **Challenge 4 (Terraform):** Blue/Green target group routing in Terraform.

- **Day 17: Auto Scaling Groups (ASG) & CloudWatch Alarms**
  - **Challenge 1 (Linux):** Stress-testing Linux CPU and memory to observe system behavior under load (`stress-ng`).
  - **Challenge 2 (Terraform/AWS):** Creating an Auto Scaling Group with dynamic scaling policies (Scale Out on 70% CPU).
  - **Challenge 3 (Incident):** Flapping / Threshing alert: Servers scaling up and down too fast (tuning Cooldown timers).
  - **Challenge 4 (Terraform):** CloudWatch metric alarms integrated with SNS alerts.

---

### ☸️ PHASE 4: Kubernetes (K8s) & Production SRE (Days 18 – 20)
*Platform: Local Kubernetes via Docker Desktop (Kubernetes enabled in Docker Desktop settings - 100% $0 Cost)*

- **Day 18: Kubernetes Core Architecture (Pods & Deployments)**
  - **Challenge 1 (Linux):** Kernel process namespaces vs K8s Pod network namespaces.
  - **Challenge 2 (K8s):** Writing Declarative YAML Manifests (Pods, Deployments, ReplicaSets).
  - **Challenge 3 (Incident):** Debugging `CrashLoopBackOff` & `ImagePullBackOff` like a senior SRE.
  - **Challenge 4 (Terraform):** Provisioning a local / cloud lightweight K8s cluster.

- **Day 19: K8s Networking, Services & Ingress**
  - **Challenge 1 (Linux):** Kube-proxy internals & Linux IPVS / iptables packet forwarding in Kubernetes.
  - **Challenge 2 (K8s):** ClusterIP, NodePort, and LoadBalancer Services.
  - **Challenge 3 (Incident):** "Frontend Pod cannot reach Backend Pod" — diagnosing K8s CoreDNS resolution failures.
  - **Challenge 4 (Terraform):** Automated DNS mapping via Terraform Route53.

- **Day 20: K8s ConfigMaps, Secrets & Rolling Updates**
  - **Challenge 1 (Linux):** Linux RAM tmpfs filesystems vs K8s mounted secret volumes.
  - **Challenge 2 (K8s):** Managing production secrets & ConfigMaps safely.
  - **Challenge 3 (Incident):** Zero-Downtime Rolling Update: Upgrading a deployment from v1 to v2 with zero dropped packets.
  - **Challenge 4 (Portfolio & Interview Defense):** Compiling your end-to-end multi-tier production architecture for interview presentations!

---

## 🏆 The 2-Year DevOps Competency Matrix (Your Checklist to 100%)

- [x] **Linux Deep Dive**: Systemd services, file permissions (`chmod`, `chattr +i`), SSH hardening, cron jobs.
- [x] **Linux SRE Incident Response**: OOM Killer & Swap, Deleted-yet-open file leaks (`lsof +L1`), Inode exhaustion (`df -i`), rogue port collisions.
- [x] **Host Firewalls**: Linux `iptables` packet dropping, logging, and AWS Security Group zero-downtime rules.
- [x] **Git Operations & RCA**: Production rollback (`git checkout tag`), post-mortem incident documentation.
- [ ] **Docker Mastery**: Production Dockerfiles, multi-stage builds, volume mounts, `docker-compose` (Local Docker Desktop).
- [ ] **CI/CD Automation**: GitHub Actions automated linting, testing, image build, and zero-downtime deployments.
- [ ] **Enterprise Cloud Architecture**: AWS Multi-AZ VPC, Public/Private Subnets, NAT Gateways, ALBs via Terraform.
- [ ] **Kubernetes Core**: Pods, Deployments, Services, ConfigMaps, Secrets, Ingress, `CrashLoopBackOff` debugging.

---
*Created for Saad Sayyed — Permanently locked to $0.00 cost and Local Docker Desktop.*
