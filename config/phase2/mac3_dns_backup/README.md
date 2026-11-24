# Mac 3 — Backup DNS resolver (Phase 2, Ext A)

dnsmasq 2.93 on Mac 3 (`10.7.2.169`) with **the same project records and TTL** as the primary on Mac 1.
Only `listen-address` and the log path differ (`diff ../mac1_dns_primary/dnsmasq.conf dnsmasq.conf`).

```bash
sudo /opt/homebrew/sbin/dnsmasq -C ~/phase2/DNS-backup/dnsmasq.conf --pid-file=$HOME/phase2/DNS-backup/dnsmasq.pid   # start
sudo kill $(cat ~/phase2/DNS-backup/dnsmasq.pid)                                                                     # stop
dig @10.7.2.169 app.team1.test
sudo ./set_app_record.sh <IP>     # Ext B/E record change, keep in step with Mac 1
```
Clients (Mac 1, Mac 3, Mac 4) list `10.7.2.17` first and `10.7.2.169` second
(`sudo networksetup -setdnsservers Wi-Fi 10.7.2.17 10.7.2.169`).
