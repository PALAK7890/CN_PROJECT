# Phase 1 IP / Service Table

| Machine | Role | IP | Service |
|---|---|---:|---|
| Mac 1 | DNS Server | 10.7.24.103 | dnsmasq / DNS |
| Mac 2 | Nginx TLS Load Balancer | 10.7.15.18 | HTTPS :8443 |
| Mac 3 | Backend A | 10.7.10.160 | HTTP :3001 |
| Mac 4 | Backend B + Client | 10.7.9.47 | HTTP :3002 |

Network: `10.7.0.0/19`  
Subnet mask: `255.255.224.0`  
Gateway: `10.7.0.1`  
Interface: `en0`

Domains:
- `app.team1.test` → `10.7.15.18`
- `api.team1.test` → `10.7.15.18`
