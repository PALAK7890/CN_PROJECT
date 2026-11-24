# Phase 2 evidence

All screenshots are Terminal windows on Mac 3 driving the other Macs over SSH; each command line shows
`user@macN` so you can see which machine ran it. Captured 24 Nov 2026.

| # | File | Shows | Extension |
|---|---|---|---|
| 1 | `screenshots/p2_01_inventory_ping.png` | hostname / IP / MAC / gateway of all 4 Macs, full-mesh ping, listening services | Demo steps 1–2 |
| 2 | `screenshots/p2_02_baseline_dns_https_lb.png` | client resolver list, `dig` → Mac 2, HTTPS with no `-k` (`ssl_verify_result=0`), A/B alternation | Demo steps 3–5 |
| 3 | `screenshots/p2_03_extA_backup_dns_setup.png` | identical records on primary + backup, both answer, clients list both resolvers | A |
| 4 | `screenshots/p2_04_extA_primary_down_failover.png` | dnsmasq stopped on Mac 1, direct query times out, client still resolves via `10.7.2.169`, tcpdump of the failover | A |
| 5 | `screenshots/p2_05_extA_dns_failure_vs_app_failure.png` | both resolvers down → "Resolving timed out" while ping works; DNS up + both backends down → `502` | A |
| 6 | `screenshots/p2_06_extB_ttl_record_change.png` | record changed to `10.7.2.169`; client keeps the cached old answer until the TTL runs out (switch seen at t≈41 s) | B |
| 7 | `screenshots/p2_07_extB_manual_flush.png` | record changed back; stale until `dscacheutil -flushcache` → new answer immediately | B |
| 8 | `screenshots/p2_08_extE_edge_cutover.png` | standby edge config diff, cutover, fresh client → `mac3-standby` while cached client stays on `mac2-primary` until TTL expiry, access logs of both edges | E |
| 9 | `screenshots/p2_09_extC_backend_isolation_pf.png` | before: clients reach 3001/3002 directly; pf rules + rollback copy; after: clients blocked, Mac 2 still gets 200, service via edge unaffected | C |
| 10 | `screenshots/p2_10_extC_firewall_rollback.png` | anchor flushed, `pfctl -sr` and `/etc/pf.conf` identical to rollback copy, direct access restored | C |
| 11 | `screenshots/p2_11_extD_ha_failover.png` | health-check config; Backend A killed → 8/8 requests `200` from B; nginx error log + retried upstream in access log; A restarted → round-robin resumes | D |
| 12 | `screenshots/p2_12_extF_troubleshooting_rehearsal.png` | injected `/etc/hosts` fault, symptom, `diagnose.sh` pinpoints DNS layer, fix, all layers OK | F |

Packet capture: `pcap/extA_dns_failover_mac4.pcap` (open in Wireshark, filter `dns`): Mac 4's queries to
`10.7.2.17` go unanswered, then the same query is retried to `10.7.2.169` and answered.

Raw logs: `../../config/phase2/mac2_edge_primary/logs/`.
