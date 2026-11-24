# Mac 2 — Primary edge: nginx TLS reverse proxy + load balancer (Phase 2)

| | |
|---|---|
| Host | Mac 2 (`10.7.6.248`), nginx 1.31.6, listens `*:8443` (TLS 1.2, HTTP/2) |
| Live config | `~/phase2/nginx.conf` (copy: `nginx.conf`), started with `nginx -c ~/phase2/nginx.conf` |
| Certificate | self-signed `CN=app.team1.test`, SAN `app.team1.test, api.team1.test` (key not in repo) |
| Upstreams | Backend A `10.7.2.169:3001` (Mac 3), Backend B `10.7.27.127:3002` (Mac 4) |

## What changed from Phase 1
- Upstream IPs updated for the new DHCP leases.
- **Ext D passive health checks**: `max_fails=1 fail_timeout=10s` per backend plus
  `proxy_next_upstream error timeout http_502 http_503 http_504` / `proxy_next_upstream_tries 2`.
  A refused/timed-out connect marks that backend down for 10 s and the *same* request is retried on
  the other backend, so the client still gets `200`.
- `add_header X-Edge mac2-primary` so clients can see which edge served them (needed for Ext E cutover).
- `team1_access.log` records client IP and `$upstream_addr` / `$upstream_status` for every request.
- An identical standby edge runs on Mac 3 (`../mac3_edge_standby/`), differing only in `X-Edge` and cert path.

## Known limitation (single point of failure)
This nginx is still the single entry point. Ext E shows the mitigation: a standby edge plus a DNS cutover
(TTL 30 s). Removing the SPOF fully needs a shared virtual IP (keepalived/VRRP-style failover) or
health-checked DNS/anycast in front of two active edges.

## Log excerpts
`logs/` holds the error/access log lines produced during the Phase 2 demos (backend failover, edge cutover).
