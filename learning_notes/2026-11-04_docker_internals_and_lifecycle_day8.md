# Day 8: Docker 101, Linux Container Internals & Lifecycle Management
**Date:** November 4, 2026 (Day 8 Session)  
**Student:** Saad Sayyed  
**Environment:** Local Docker Desktop Engine (v28.3.3) on Windows / WSL2 ($0.00 Cost)  
**Topics:** Linux Namespaces vs cgroups, Dockerfile Keywords (`FROM`, `WORKDIR`, `COPY`, `RUN`, `EXPOSE`, `CMD`), Image Versioning & Tags, Container Lifecycle Management, SRE Incident Triage (`docker logs`), and Resource Quotas (`--memory`, `--cpus`).

---

## 📑 Table of Contents
1. [Linux Deep Dive: What is a Container Under the Hood?](#1-linux-deep-dive-what-is-a-container-under-the-hood)
2. [The 3 Core Building Blocks of Docker](#2-the-3-core-building-blocks-of-docker)
3. [Top 10 Dockerfile Keywords Reference](#3-top-10-dockerfile-keywords-reference)
4. [Inside the Container: Real Filesystem vs. Virtual Namespaces](#4-inside-the-container-real-filesystem-vs-virtual-namespaces)
5. [Docker Lifecycle & Management Cheat Sheet](#5-docker-lifecycle--management-cheat-sheet)
6. [Image Versioning: Repositories vs. Tags](#6-image-versioning-repositories-vs-tags)
7. [Incident Triage: Diagnosing Crashed Containers (`docker logs`)](#7-incident-triage-diagnosing-crashed-containers-docker-logs)
8. [Resource Quotas & cgroups in Action (`docker stats`)](#8-resource-quotas--cgroups-in-action-docker-stats)

---

## 1. Linux Deep Dive: What is a Container Under the Hood?

### The Myth vs. The Truth
- **Myth:** "A container is a mini Virtual Machine." ❌
- **Truth:** Containers **share the host Linux Kernel directly**. There is no guest hypervisor or virtual BIOS. A container is a regular Linux process running with kernel isolation.

### The Container Formula
$$\text{Normal Linux Process} + \text{Namespaces (Isolation)} + \text{cgroups (Resource Limits)} = \text{Docker Container}$$

### Linux Namespaces (What a process can SEE)
- **PID Namespace:** Gives the process an isolated process tree. The containerized application thinks it is **PID 1 (King of the OS)** and cannot see host processes.
- **NET Namespace:** Grants a private virtual network card (`eth0`), private loopback, and private IP (`172.17.0.x`).
- **MNT Namespace:** Isolates the filesystem root (`/`). The container cannot view host files unless explicitly mounted.

### Linux cgroups (What a process can EAT)
- Sets hard ceilings on CPU percentage, RAM allocation, and I/O throughput.
- Enforces container OOM kills without risking host operating system stability.

---

## 2. The 3 Core Building Blocks of Docker

```text
[ Dockerfile ]  ──────(docker build)─────►  [ Docker Image ]  ──────(docker run)─────►  [ Live Container ]
 (The Recipe)                               (Frozen Template)                           (Active Process)
```

1. **`Dockerfile`**: Plaintext instructions describing how to package the runtime environment.
2. **`Docker Image`**: Immutable, layered, read-only snapshot containing the OS libraries and application binary.
3. **`Docker Container`**: An ephemeral, stateful running instance instantiated from an image.

---

## 3. Top 10 Dockerfile Keywords Reference

| Keyword | Role | Production Usage |
| :--- | :--- | :--- |
| **`FROM`** | Sets starting base image | `FROM python:3.11-slim` |
| **`WORKDIR`** | Creates & enters working directory | `WORKDIR /app` |
| **`COPY`** | Transfers files from host to container | `COPY server.py /app/server.py` |
| **`RUN`** | Executes commands during image build | `RUN pip install --no-cache-dir -r requirements.txt` |
| **`ENV`** | Sets default environment variables | `ENV PORT=8080` |
| **`EXPOSE`** | Informational port label | `EXPOSE 8080` |
| **`USER`** | Runs container as non-root user (Security) | `USER appuser` |
| **`VOLUME`** | Declares persistent storage mount | `VOLUME ["/data"]` |
| **`ADD`** | Like `COPY`, but auto-extracts `.tar.gz` and accepts URLs | Use `COPY` instead, unless extracting tarballs |
| **`CMD`** | Default runtime launch command (overridable) | `CMD ["python", "app.py"]` |
| **`ENTRYPOINT`** | Fixed executable that cannot be easily overridden | `ENTRYPOINT ["python"]` |

---

## 4. Inside the Container: Real Filesystem vs. Virtual Namespaces

When starting `FROM python:3.11-slim`, the container inherits a complete Debian-based Linux root filesystem:

```text
/
├── bin/      # Standard Linux binaries (ls, cat, sh)
├── etc/      # System configurations
├── usr/      # Python 3.11 runtime and installed packages
├── var/      # Logs and spool directories
├── tmp/      # Temporary storage
└── app/      # Custom directory created via WORKDIR
```

To explore inside a running container interactively:
```powershell
docker exec -it <container_name> bash
# Once inside: pwd, ls -la /, ps aux, exit
```

---

## 5. Docker Lifecycle & Management Cheat Sheet

| Task | Command |
| :--- | :--- |
| **List Running Containers** | `docker ps` |
| **List All Containers (Including Exited)** | `docker ps -a` |
| **List Local Images** | `docker images` |
| **Graceful Stop (SIGTERM 15)** | `docker stop <container>` |
| **Start Stopped Container** | `docker start <container>` |
| **Reboot Container** | `docker restart <container>` |
| **Delete Container (Stopped)** | `docker rm <container>` |
| **Force Delete Running Container (SIGKILL 9)** | `docker rm -f <container>` |
| **Delete Image Template** | `docker rmi <image_name:tag>` |
| **Garbage Collect All Unused Docker Assets** | `docker system prune -f` |

---

## 6. Image Versioning: Repositories vs. Tags

### Syntax: `REPOSITORY:TAG`
- The **Tag** is the software version label.
- A single image can hold multiple tags (e.g. `my-app:v2` and `my-app:latest` pointing to the same Image ID).
- In production, **always deploy explicit version tags (e.g., `:v1.2.0`)**, never deploy mutable `:latest`.

```powershell
# Build Version 1
docker build -t my-first-api:v1 .

# Build Version 2
docker build -t my-first-api:v2 .

# Alias v2 as latest
docker tag my-first-api:v2 my-first-api:latest
```

---

## 7. Incident Triage: Diagnosing Crashed Containers (`docker logs`)

### The Symptom
Container launched with `docker run -d` immediately disappears from `docker ps`.

### SRE Triage Workflow
```powershell
# 1. Identify exit code in the dead container registry
docker ps -a
# Status indicates: Exited (1) 5 seconds ago

# 2. View the container's standard output / error death log
docker logs <container_name>
# Traceback reveals: ModuleNotFoundError: No module named 'requests'

# 3. Fix: Add dependency in Dockerfile with --no-cache-dir
RUN pip install --no-cache-dir requests

# 4. Inject runtime secrets via -e flag
docker run -d -p 5000:5000 -e APP_SECRET_KEY="saad123" <image>
```

---

## 8. Resource Quotas & cgroups in Action (`docker stats`)

### The Production Leashed Container Command
```powershell
docker run -d -p 5001:5000 --name safe-app --memory="128m" --cpus="0.5" -e APP_SECRET_KEY="saad123" broken-app:v3
```

- `-d`: Detached mode (background).
- `-p 5001:5000`: Port translation (Host 5001 ➡️ Container 5000).
- `--name safe-app`: Explicit human-friendly identifier.
- `--memory="128m"`: cgroup hard cap at 128 MB RAM (OOM Killer triggers if exceeded, protecting host).
- `--cpus="0.5"`: cgroup CPU quota (Limits execution to 50% of one core).
- `-e KEY=VAL`: Injects environment secrets into process memory.

### Live Telemetry Monitoring
```powershell
docker stats
```
Reveals real-time CPU %, Memory consumption against hard limits, Network I/O, and total thread/process counts (`PIDS`).

---
*Created by Saad Sayyed during DevOps & Containerization Hands-On Labs.*
