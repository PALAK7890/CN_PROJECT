# CN Private Network Project

A private four-machine network that demonstrates how real web infrastructure fits together: private DNS, an Nginx TLS load balancer, two backend services, HTTPS termination, round-robin routing, response caching, and packet-level verification.

**Status:** Phase 1 and Phase 2 complete

---

## Overview

Requests from a client are resolved through a private DNS server, sent over HTTPS to an Nginx load balancer, decrypted (TLS termination), and distributed across two backend services in round-robin order. Every claim is backed by captured evidence (curl output, logs, packet captures) stored in the repo.

## Architecture

### Phase 2 (current)

| Machine | Role | Address |
|---|---|---|
| Mac 1 | Primary DNS + test client | `10.7.2.17` |
| Mac 2 | Primary Nginx TLS edge / load balancer | `10.7.6.248:8443` |
| Mac 3 | Backend A + backup DNS + standby edge | `10.7.2.169` (`:3001`, `:53`, `:8443`) |
| Mac 4 | Backend B + main client | `10.7.27.127:3002` |

Details: [`architecture/phase2-ip-service-table.md`](architecture/phase2-ip-service-table.md)

### Phase 1

| Machine | Role | Address |
|---|---|---|
| Mac 1 | DNS Server | `10.7.24.103` |
| Mac 2 | Nginx TLS Load Balancer | `10.7.15.18:8443` |
| Mac 3 | Backend A | `10.7.10.160:3001` |
| Mac 4 | Backend B + Client | `10.7.9.47:3002` |

Network: `10.7.0.0/19`

```
                 +------------------+
                 |  Mac 1: DNS      |
                 |  10.7.24.103     |
                 +--------^---------+
                          | 1. resolve name
                          |
+----------------+        |        +-----------------------+
| Mac 4: Client  |--------+------> | Mac 2: Nginx LB (TLS) |
| 10.7.9.47      |  2. HTTPS      | 10.7.15.18:8443       |
+----------------+                +-----------+-----------+
                                    3. round-robin
                              +-----------------+----------------+
                              v                                  v
                    +------------------+              +------------------+
                    | Mac 3: Backend A |              | Mac 4: Backend B |
                    | 10.7.10.160:3001 |              | 10.7.9.47:3002   |
                    +------------------+              +------------------+
```

## Features

- **Private DNS:** custom name resolution inside the private network
- **TLS termination:** Nginx handles HTTPS on port 8443 and forwards to the backends
- **Round-robin load balancing:** requests alternate between Backend A and Backend B
- **Caching:** repeated requests can be served from the load balancer's cache
- **Packet-level verification:** behaviour confirmed with packet captures, not just application logs
- **Failure scenario:** documented behaviour when a client connects to the wrong HTTPS port

## Repository Structure

```
.
├── architecture/   # Network design and topology
├── config/         # DNS, Nginx, and host configuration files
├── docs/           # Project documentation
├── evidence/       # Test outputs, captures, and scenario write-ups (Phase 2: evidence/09_phase2/)
├── scripts/        # diagnose.sh: layer-by-layer troubleshooting (Phase 2)
└── README.md
```

## Prerequisites

- 4 machines (macOS) on the same `10.7.0.0/19` network
- Python 3 (backend services)
- Nginx
- A DNS server (e.g. dnsmasq or equivalent)
- OpenSSL (for generating the TLS certificate)
- curl and tcpdump or Wireshark (for testing and verification)

## Setup and Usage

> Replace the placeholders below with your actual commands and file names.

**1. DNS server (Mac 1)**

```bash
# start the DNS server using the config in config/
<your dns start command>
```

**2. Backend services (Mac 3 and Mac 4)**

```bash
# Mac 3, Backend A on port 3001
python3 <backend_script>.py --port 3001

# Mac 4, Backend B on port 3002
python3 <backend_script>.py --port 3002
```

**3. Nginx load balancer (Mac 2)**

```bash
# use the Nginx config from config/, then start or reload
nginx -c /path/to/config/nginx.conf
```

**4. Test from the client (Mac 4)**

```bash
# repeated requests should alternate between Backend A and Backend B
for i in 1 2 3 4; do curl -k https://<your-domain>:8443/; done
```

## Verification

| Check | How it was verified |
|---|---|
| DNS resolution | `dig` / `nslookup` against `10.7.24.103` |
| TLS termination | `curl -v` and packet capture of the HTTPS handshake |
| Round-robin routing | Alternating backend responses across requests |
| Caching | Repeat requests compared against backend logs |
| Wrong-port scenario | Connection to a non-HTTPS port, documented in `evidence/` |

Full outputs and captures are in the [`evidence/`](evidence/) folder.

## Tech Stack

Python · Nginx · TLS/HTTPS · DNS · Wireshark/tcpdump

## Roadmap

- [x] Phase 1: private network, DNS, TLS load balancer, backends, verification
- [x] Phase 2: backup DNS, TTL/record change, backend isolation (pf), HA failover, DNS-based edge cutover, troubleshooting

## Phase 2: Harden, Recover, Troubleshoot

| Extension | What we built | Evidence |
|---|---|---|
| A: Backup DNS | second dnsmasq on Mac 3 with identical records; clients list `10.7.2.17`, `10.7.2.169` | p2_03, p2_04, p2_05, pcap |
| B: TTL + record change | `local-ttl=30`; `set_app_record.sh`; cache vs. manual flush | p2_06, p2_07 |
| C: Service isolation | pf anchor `com.apple/team1_backend`: only edges reach 3001/3002; rollback verified | p2_09, p2_10 |
| D: HA failover | nginx `max_fails`/`fail_timeout` + `proxy_next_upstream` | p2_11 |
| E: Edge cutover | standby nginx on Mac 3, DNS repointed, TTL drain observed | p2_08 |
| F: Troubleshooting | `scripts/diagnose.sh` (DNS → IP → TCP → TLS → HTTP) | p2_12 |

Report: [`docs/Phase2_Report.md`](docs/Phase2_Report.md) · Configs: [`config/phase2/`](config/phase2/) · Evidence: [`evidence/09_phase2/`](evidence/09_phase2/)


Built as a Computer Networks course project.
