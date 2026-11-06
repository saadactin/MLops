# Day 9 SRE & DevOps Production Learning Notes
**Date:** 2026-11-05  
**Topic:** Container Networking Internals, Linux Network Namespaces, Virtual Ethernet (`veth`) Pairs, Docker DNS Resolution, and Storage Persistence (Volumes)  
**Engineer:** Saad Sayyed  

---

## 1. Linux Kernel Networking: Under the Hood

Docker does not have proprietary networking magic; it stitches together native Linux kernel primitives:

### A. Network Namespaces (`netns`)
* **What it is:** An isolated copy of the network stack (interfaces, routing tables, iptables, loopback).
* **Commands:**
  ```bash
  ip netns add red          # Create isolated network space "red"
  ip netns add blue         # Create isolated network space "blue"
  ip netns list             # List all network namespaces
  ip netns exec red <cmd>   # Step inside "red" and execute <cmd>
  ```

### B. Virtual Ethernet Pairs (`veth`)
* **What it is:** A virtual network patch cable with two ends. Anything entering one end instantly pops out of the other.
* **Commands:**
  ```bash
  # 1. Manufacture the cable with two ends:
  ip link add veth-red type veth peer name veth-blue

  # 2. Plug one end into "red" and the other into "blue":
  ip link set veth-red netns red
  ip link set veth-blue netns blue

  # 3. Assign IP addresses and power on the interfaces:
  ip netns exec red ip addr add 10.0.0.1/24 dev veth-red
  ip netns exec red ip link set veth-red up
  ip netns exec red ip link set lo up

  ip netns exec blue ip addr add 10.0.0.2/24 dev veth-blue
  ip netns exec blue ip link set veth-blue up
  ip netns exec blue ip link set lo up

  # 4. Ping across the virtual cable:
  ip netns exec red ping -c 3 10.0.0.2
  ip netns exec blue ping -c 3 10.0.0.1
  ```

---

## 2. Docker Multi-Container Networking & The DNS Trap

### The Default Bridge vs Custom Bridge:
1. **Default Bridge (`bridge` / `docker0`):**
   * Legacy Docker behavior.
   * **DNS resolution is DISABLED.**
   * Containers cannot communicate by container name (`ping db` fails with `ping: bad address 'db'`).
2. **User-Defined Custom Bridge (`docker network create <name>`):**
   * Docker's embedded DNS server (`127.0.0.11`) is automatically **ACTIVE**.
   * Containers automatically resolve each other's IP using their container name as the hostname.
   * **Commands:**
     ```powershell
     # Create custom bridge network
     docker network create company-network

     # Run containers attached to the network
     docker run -d --name secure-db --network company-network alpine sleep 1000
     docker run --rm --network company-network alpine ping -c 2 secure-db

     # Inspect network and connected container IPs
     docker network inspect company-network
     ```

---

## 3. Storage Persistence: Ephemeral Layers vs Docker Volumes

### Why Databases Die Without Volumes:
* By default, container storage is **ephemeral** (lives in the container's temporary writable layer).
* If a container is restarted (`docker restart`), data stays.
* **BUT** if a container is deleted or recreated (`docker rm -f`, image upgrade, or pod rescheduling), **all internal data is destroyed permanently.**

### Docker Volumes (`-v`):
* A Docker Volume is an isolated storage vault that lives **outside the container lifecycle** on the host machine.
* Even if you destroy the container 100 times, the volume remains 100% intact.
* **Volume Syntax (`LEFT:RIGHT` Rule):**
  $$\mathbf{-v} \quad \underbrace{\text{volume-name}}_{\text{OUTSIDE (Host Vault)}} \quad \mathbf{:} \quad \underbrace{\text{/var/lib/postgresql/data}}_{\text{INSIDE (Container Path)}}$$

### The 5 Essential Docker Volume Commands:
```powershell
docker volume create <name>     # Create a storage vault
docker volume ls               # List all volumes
docker volume inspect <name>    # Inspect exact host mount path
docker volume rm <name>         # Delete a volume
docker volume prune            # Remove unused orphaned volumes
```

### The Immortal Database Workflow:
```powershell
# 1. Create volume
docker volume create saad-pg-data

# 2. Run Postgres with volume mount
docker run -d --name my-postgres -e POSTGRES_PASSWORD=secret123 -v saad-pg-data:/var/lib/postgresql/data postgres:15-alpine

# 3. Destroy container
docker rm -f my-postgres

# 4. Spin up fresh replacement with same volume - DATA SURVIVES!
docker run -d --name my-new-postgres -e POSTGRES_PASSWORD=secret123 -v saad-pg-data:/var/lib/postgresql/data postgres:15-alpine
```

---

## 4. Key Takeaways for Senior DevOps / SRE Interviews
1. **Stateless Services:** (Web apps, APIs, proxies) $\rightarrow$ No volumes needed. Easily scaled and replaced.
2. **Stateful Services:** (Databases, search indices, object stores) $\rightarrow$ **Volumes are mandatory.**
3. **Container-to-Container DNS:** Always run production multi-container apps on custom user-defined bridge networks, never the default bridge.

