# Phase 2 configuration bundle

| Folder | Machine | Contents |
|---|---|---|
| `mac1_dns_primary/` | Mac 1 `10.7.2.17` | primary dnsmasq (TTL 30), record cutover script |
| `mac2_edge_primary/` | Mac 2 `10.7.6.248` | primary nginx edge with passive health checks, log excerpts |
| `mac3_dns_backup/` | Mac 3 `10.7.2.169` | backup dnsmasq (same records), record cutover script |
| `mac3_edge_standby/` | Mac 3 `10.7.2.169` | standby nginx edge (identical config) |
| `mac3_backend_a/` | Mac 3 `10.7.2.169` | Backend A source, pf isolation rules + rollback copies |
| `mac4_backend_b/` | Mac 4 `10.7.27.127` | Backend B source, pf isolation rules + rollback copies, client setup |

`../scripts/diagnose.sh` is the layer-by-layer troubleshooting script used for Ext F.
Phase 1 configs remain in `config/dnsmasq.conf` and `config/nginx.conf` (old IPs).
