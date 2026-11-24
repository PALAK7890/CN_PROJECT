# Mac 4 — Backend B (:3002) + main test client (Phase 2)

| | |
|---|---|
| Host | Mac 4 (`10.7.27.127`) |
| Backend | `server.py 3002 B` (Python 3.14 `ThreadingHTTPServer`, binds `0.0.0.0:3002`, sends `X-Backend: B`, `Cache-Control`, `ETag`) |
| Client DNS | Wi-Fi resolvers `10.7.2.17` (primary, Mac 1) then `10.7.2.169` (backup, Mac 3) |
| Trust | `app.team1.test` certificate trusted in the System keychain → all demos use `curl` **without `-k`** |

```bash
cd ~/phase1/Backend-B && nohup python3 -u server.py 3002 B >> backend_B.log 2>&1 &
sudo networksetup -setdnsservers Wi-Fi 10.7.2.17 10.7.2.169
```

## Ext C — service isolation (pf)
`team1_backend.pf` is loaded into the sub-anchor `com.apple/team1_backend`, which the stock
`/etc/pf.conf` already evaluates (`anchor "com.apple/*"`), so `/etc/pf.conf` itself is never edited.
Only the edges (Mac 2 `10.7.6.248`, standby Mac 3 `10.7.2.169`) may open TCP 3002.

```bash
# rollback copy first
sudo pfctl -sr > rollback_main_rules.txt; sudo pfctl -a com.apple -s Anchors > rollback_anchors.txt; cp /etc/pf.conf rollback_pf.conf
sudo pfctl -a com.apple/team1_backend -f team1_backend.pf     # apply
sudo pfctl -a com.apple/team1_backend -sr                      # show
sudo pfctl -a com.apple/team1_backend -F rules                 # rollback (restores original state)
```
`rollback_*` are the copies taken on Mac 4 before the demo; after rollback `pfctl -sr` and `/etc/pf.conf`
were diffed against them with no differences.

## Housekeeping found during Phase 2
`/etc/hosts` contained a leftover `127.0.0.1 app.team1.test` line from an earlier test, which silently overrode
DNS. It was removed (backup `/etc/hosts.bak-cnproject`); the same fault was later re-used as the Ext F rehearsal.
