# 🚨 CRITICAL WORKSPACE POLICY: ZERO COST ($0.00) & LOCAL DOCKER FIRST
**Enforcement Level:** MANDATORY / ABSOLUTE (User Directive)

## 1. Zero Dollar ($0.00) Cost Policy
- **Absolute Rule:** The user requires **100% $0.00 cost** across all activities.
- **Explicit Approval Required:** If ANY task, service, or resource would incur even $0.01 (one cent) of cost, the agent MUST explicitly inform the user and request written approval BEFORE running any commands or creating infrastructure.
- **AWS Free Tier Only:** When using AWS, ONLY use resources covered under the 12-Month AWS Free Tier (`t3.micro`/`t2.micro`, 8GB `gp3` storage, standard security groups).
- **Mandatory End-of-Session Teardown:** At the end of every practice session, ALL cloud resources provisioned via Terraform must be completely destroyed with `terraform destroy -auto-approve`, and verified with `terraform state list` (must be completely empty) and AWS CLI.

## 2. Local Docker Desktop First
- The user has **Docker Desktop (Engine v28.3.3)** installed locally on Windows.
- For all containerization, microservice packaging, Dockerfile testing, and `docker-compose` learning, **USE LOCAL DOCKER DESKTOP** instead of spawning cloud VMs.
- Local Docker runs 100% free ($0 cost) directly on the user's machine with zero cloud footprint.

## 3. The 4-Challenge Daily Structure
Every day's production lab must feature 4 challenges:
1. **Challenge 1:** 🐧 Mandatory Linux Deep Dive & SRE Troubleshooting (Kernel, networking, permissions, inodes, systemd, logs).
2. **Challenge 2:** 🐳 Docker / Platform Core Engineering.
3. **Challenge 3:** 🚨 Production Incident & SRE Triage.
4. **Challenge 4:** ☁️ Infrastructure as Code (Terraform) & Cloud Automation (Free Tier / Local).
