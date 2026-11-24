# Phase 2 Report — Harden, Recover, and Troubleshoot

Team 1 · `team1.test` · 24 Nov 2026

## 1. What changed from Phase 1

| Area | Phase 1 | Phase 2 |
|---|---|---|
| IPs | Mac 1 `10.7.24.103`, Mac 2 `10.7.15.18`, Mac 3 `10.7.10.160`, Mac 4 `10.7.9.47` | Mac 1 `10.7.2.17`, Mac 2 `10.7.6.248`, Mac 3 `10.7.2.169`, Mac 4 `10.7.27.127` (new DHCP leases; all configs updated) |
| DNS | single dnsmasq on Mac 1, default TTL | primary on Mac 1 **+ backup on Mac 3** with identical records, `local-ttl=30`, explicit upstreams |
| Clients | one resolver | resolver list `10.7.2.17, 10.7.2.169` on Mac 1, 3, 4; certificate trusted in the System keychain on all clients (no `-k`) |
| Edge | nginx on Mac 2, plain round-robin | + passive health checks (`max_fails=1 fail_timeout=10s`, `proxy_next_upstream`), `X-Edge` header, upstream-aware access log |
| Standby edge | none | identical nginx on Mac 3 for DNS-based cutover |
| Isolation | backends open to the whole LAN | pf anchor `com.apple/team1_backend` allows only the edges to reach 3001/3002 (applied for the demo, then rolled back) |
| Troubleshooting | ad hoc | `scripts/diagnose.sh` checks DNS → IP → TCP → TLS → HTTP and reports the first failing layer |

Full inventory: `architecture/phase2-ip-service-table.md`. Configs: `config/phase2/`. Evidence index: `evidence/09_phase2/README.md`.

## 2. Resilience tests and results

| Test | Method | Result | Evidence |
|---|---|---|---|
| A. Primary DNS down | `sudo brew services stop dnsmasq` on Mac 1, flush client cache, resolve + curl from Mac 4 | direct query to `10.7.2.17` times out; system resolver answered by `10.7.2.169`; HTTPS `200` | p2_04, pcap |
| A. DNS failure vs app failure | stop both resolvers; then restore DNS and stop both backends | 1st: `curl: (28) Resolving timed out` although `ping 10.7.6.248` works · 2nd: name resolves, TCP+TLS succeed, edge returns `502` | p2_05 |
| B. TTL behaviour | resolve at t=0, change record to `10.7.2.169` on both servers, poll every ~4 s | servers return the new IP immediately; client served the old IP until t≈36–41 s, then the new one | p2_06, p2_08 |
| B. Manual flush | change record back, then `dscacheutil -flushcache; killall -HUP mDNSResponder` | stale answer before the flush, new answer immediately after | p2_07 |
| C. Isolation | pf rules on Mac 3 and Mac 4 | Mac 1 → 3001/3002 and Mac 4 → 3001: no TCP handshake · Mac 2 → both: `200` · service via edge: `200` A/B | p2_09 |
| C. Rollback | flush anchor, diff against saved copies | ruleset and `/etc/pf.conf` identical to rollback copy; direct access restored | p2_10 |
| D. Backend A down | kill `server.py 3001` on Mac 3, 8 requests from Mac 4 | 8/8 `HTTP/2 200` from B; nginx logged `connect() failed (61: Connection refused)` and retried on B (`upstream=10.7.2.169:3001, 10.7.27.127:3002`) | p2_11 |
| D. Backend A back | restart, wait > `fail_timeout` (10 s) | round-robin A/B resumes | p2_11 |
| E. Edge cutover | repoint `app.team1.test` → `10.7.2.169` | Mac 1 (fresh lookup) → `x-edge: mac3-standby` at once; Mac 4 (cached) stayed on `mac2-primary` until t≈36 s, then moved; both edges' access logs confirm | p2_08 |

Note on the measured TTL: the client kept the old answer for 36–41 s, slightly longer than the 30 s TTL. The
first lookup and the record change were ~1 s apart, the polling interval was ~4 s, and macOS `mDNSResponder` adds
a little slack before re-querying, so the switch is always seen *after* 30 s, never before.

## 3. Troubleshooting findings (Ext F)

Method (`scripts/diagnose.sh`, run on the client):
1. **DNS** — ask each team DNS server directly, then the system resolver (what apps use), and compare.
2. **IP** — ping the resolved address.
3. **TCP** — `nc -z` to the service port (handshake only).
4. **TLS** — `openssl s_client` handshake + certificate subject; `curl` verify result with no `-k`.
5. **HTTP** — status code, `X-Backend`, `X-Edge`; `502/503/504` points at the upstream tier.

Real faults found and fixed while building Phase 2:
- **Stale `/etc/hosts` entry on Mac 4** (`127.0.0.1 app.team1.test`) left over from an earlier test. It bypasses DNS
  entirely, so `dig` looks correct while `curl` fails. Detected by comparing the system resolver with `dig`; removed.
  We re-injected the same fault as the Ext F rehearsal (p2_12): the script flags DNS as the first failing layer
  even though TCP/TLS/HTTP also fail. Those later failures are consequences, not causes.
- **Managed-Mac application firewall on Mac 3** blocked inbound connections to the Python 3.15 binary (`Connection
  reset by peer` from Mac 4) and cannot be changed from the CLI. Backend A was moved to the allowed Python 3.14 binary.
  This was a transport-level symptom with a host-firewall cause.
- **Stale root-owned `nginx.pid` on Mac 2** from an earlier `sudo nginx` made `nginx -t` fail with
  `open() ".../nginx.pid" failed (13: Permission denied)`; removed.
- **Certificate trust on Mac 1** could not be added over SSH (`SecTrustSettingsSetTrustSettings: The authorization
  was denied since no user interaction was possible`); macOS requires local approval for trust changes. It was
  added locally on Mac 1, after which `curl` verifies without `-k`.

## 4. Single point of failure (Ext D discussion)

With two backends behind health checks, the application tier survives one backend failure. The **nginx edge on
Mac 2** is still a single point of failure: if it stops, every client fails at the TCP layer even though DNS and both
backends are healthy. Ext E gives a manual mitigation (standby edge + DNS cutover, bounded by the 30 s TTL). Eliminating
it needs either a floating virtual IP shared by two edges (VRRP/keepalived, as cloud load balancers do internally)
or health-checked DNS / anycast in front of two active edges. The DNS tier itself is no longer a SPOF thanks to the
backup resolver.

## 5. Learning summary

**Ext A: Backup DNS.** Clients get resilience from listing two resolvers, not from the servers knowing about each
other. The two dnsmasq instances are independent copies, so their records have to be changed together (that is why the
cutover script exists for both). Stopping the primary showed the difference between a DNS failure, where the name
cannot be resolved although every host still answers ping, and an application failure, where resolution, TCP and TLS
all succeed and the edge answers `502`.

**Ext B: TTL.** The authoritative change is instant on the servers, but every client keeps its cached answer until the
TTL expires. A low TTL (30 s) is what makes a planned migration fast. Production teams lower the TTL well before a
cutover and raise it afterwards. Flushing the cache shows that the delay comes from the client cache, not from the DNS
servers.

**Ext C: Service isolation.** Clients never need the backend ports, so exposing them only widens the attack surface.
pf rules that allow only the edges enforce "everything goes through the edge" at the network layer. A blocked client
gets no TCP handshake at all, while the edge path keeps working. Loading the rules into a `com.apple/*` sub-anchor and
keeping rollback copies made the change fully reversible, which we verified with a diff.

**Ext D: HA failover.** Passive health checks plus `proxy_next_upstream` mean a dead backend costs one failed connect,
which nginx retries on the healthy backend, so the client sees no error. `fail_timeout` controls how quickly a recovered
backend rejoins. Redundancy only helps where it exists: the edge itself remains a single point of failure.

**Ext E: DNS-based cutover.** Moving traffic to a standby edge by changing DNS is simple, but it drains gradually. New
lookups move immediately, while cached clients keep hitting the old edge until their TTL expires. The old edge must
therefore stay up for at least one TTL after the change. The `X-Edge` header and both access logs made this visible.

**Ext F: Troubleshooting.** Working bottom-up through the stack (DNS → IP → TCP → TLS → HTTP) and stopping at the first
failure avoids chasing symptoms. In our rehearsal TCP, TLS and HTTP all failed, but only because DNS returned
`127.0.0.1`. Comparing what `dig` reports with what the OS resolver actually returns is the key check for that class
of fault.
