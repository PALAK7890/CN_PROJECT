# Mac 3 — Backend A (:3001) + service isolation (Phase 2, Ext C)

`server.py 3001 A` — same code as Backend B (`../mac4_backend_b/server.py`), binds `0.0.0.0:3001`.

```bash
cd ~/phase2/Backend-A && nohup /opt/homebrew/opt/python@3.14/bin/python3.14 -u server.py 3001 A >> backend_A.log 2>&1 &
```
Note: Mac 3 is a managed Mac whose application firewall blocks incoming connections for the Python 3.15
binary and cannot be changed from the command line; the Python 3.14 binary is allowed, so Backend A runs on 3.14.

pf isolation (`team1_backend.pf`) is loaded into anchor `com.apple/team1_backend`: only Mac 2 (`10.7.6.248`)
may open TCP 3001 over `en0`; the standby edge on this same Mac reaches it over loopback.
Apply / rollback commands and the meaning of `rollback_*` are identical to Mac 4 (`../mac4_backend_b/README.md`).

An older, unreferenced top-level anchor `team1_isolation` (from 23 Nov, stale IP `10.7.0.239`) exists on this Mac;
it is not evaluated by the main ruleset and was left untouched.
