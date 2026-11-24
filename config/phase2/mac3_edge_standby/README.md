# Mac 3 — Standby nginx edge (Phase 2, Ext E)

Same configuration as the primary edge on Mac 2 (`../mac2_edge_primary/nginx.conf`): same upstreams,
health checks, TLS settings and certificate. Differences: `X-Edge mac3-standby` and the local certificate path.
nginx 1.31.8, listens `*:8443` on `10.7.2.169`.

```bash
nginx -t -c ~/phase2/nginx-standby/nginx.conf && nginx -c ~/phase2/nginx-standby/nginx.conf   # start
nginx -s stop -c ~/phase2/nginx-standby/nginx.conf                                            # stop
```
Cutover = repoint `app.team1.test` to `10.7.2.169` on both DNS servers (`set_app_record.sh`).
The certificate key was copied from Mac 2 and is not committed (`*.key` is git-ignored).
