# Phase 2 IP / Service Table

IPs changed since Phase 1 (new DHCP leases). Network `10.7.0.0/19`, mask `255.255.224.0`, gateway `10.7.0.1`, interface `en0`.

| Machine | Owner | IP | MAC address | Phase 2 roles / services |
|---|---|---:|---|---|
| Mac 1 | Jashvitha | 10.7.2.17 | e6:65:15:e0:2b:94 | **Primary DNS** dnsmasq :53 · test client |
| Mac 2 | Palak | 10.7.6.248 | 5e:74:43:c7:2b:78 | **Primary edge** nginx TLS LB :8443 |
| Mac 3 | Samarth C. | 10.7.2.169 | 16:79:ee:a3:9d:04 | **Backend A** :3001 · **backup DNS** :53 · **standby edge** nginx :8443 |
| Mac 4 | Ji-samarth | 10.7.27.127 | de:c0:f8:b2:58:4e | **Backend B** :3002 · main test client |

DNS records (both servers, TTL 30 s): `app.team1.test`, `api.team1.test` → `10.7.6.248` (primary edge);
during the Ext E cutover `app.team1.test` → `10.7.2.169` (standby edge).

Client resolver order: `10.7.2.17`, `10.7.2.169`.

Backend ports 3001/3002: reachable only from the edges while the Ext C pf rules are loaded.

```
                 Mac 1 DNS primary 10.7.2.17 ──┐   Mac 3 DNS backup 10.7.2.169
                                               │ (same records, TTL 30)
 Mac 4 / Mac 1 client ── DNS ──────────────────┘
        │
        └─ HTTPS :8443 ──► Mac 2 nginx edge 10.7.6.248   (standby: Mac 3 nginx 10.7.2.169, via DNS cutover)
                               │  round-robin + passive health checks
                     ┌─────────┴──────────┐
                     ▼                    ▼
           Mac 3 Backend A :3001   Mac 4 Backend B :3002     (pf: only edges may connect)
```
