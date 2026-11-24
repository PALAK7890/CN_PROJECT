# Mac 1 — Primary DNS (Phase 2)

| | |
|---|---|
| Host | Mac 1 (`10.7.2.17`), dnsmasq 2.93 via `brew services` (root LaunchDaemon `sh.brew.dnsmasq`) |
| Live config | `/opt/homebrew/etc/dnsmasq.conf` (copy: `dnsmasq.conf`) |
| Records | `app.team1.test`, `api.team1.test` → `10.7.6.248` (Mac 2 edge) |
| TTL | `local-ttl=30` (Ext B: short, visible TTL) |
| Upstream | `no-resolv` + `server=10.5.7.1`, `server=8.8.8.8` for non-project names |

Backup resolver with identical records runs on Mac 3 (`10.7.2.169`), see `../mac3_dns_backup/`.

```bash
sudo brew services start dnsmasq      # start
sudo brew services stop dnsmasq       # Ext A: simulate primary DNS failure
dig @10.7.2.17 app.team1.test         # verify (TTL column should read 30)

# Ext B / Ext E: repoint app.team1.test (keeps .bak, syntax-checks, restarts)
sudo ./set_app_record.sh 10.7.2.169   # cut over to the standby edge (Mac 3)
sudo ./set_app_record.sh 10.7.6.248   # back to the primary edge (Mac 2)
```
The same change must be made on the backup DNS (Mac 3) so both resolvers agree.
