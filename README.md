# CN Private Network Project

## Phase 1 Overview

This project demonstrates a private multi-Mac network with private DNS, an Nginx TLS
load balancer, two backend services, HTTPS termination, round-robin routing, caching,
and packet-level verification.

## Architecture

- Mac 1 — DNS Server — `10.7.24.103`
- Mac 2 — Nginx TLS Load Balancer — `10.7.15.18:8443`
- Mac 3 — Backend A — `10.7.10.160:3001`
- Mac 4 — Backend B + Client — `10.7.9.47:3002`
- Network — `10.7.0.0/19`
- Gateway — `10.7.0.1`
- Interface — `en0`

`app.team1.test` and `api.team1.test` resolve to `10.7.15.18`.

## Evidence

The `evidence/` directory is organized by project phase and contains the selected screenshots
from the supplied material. Duplicate, failed/intermediate, unrelated, and noisy screenshots
were intentionally excluded.

## Important

Source code, raw Nginx/dnsmasq configuration, raw PCAP files, and failure-demo screenshots
were not present in the supplied screenshot set, so those slots are marked clearly instead of
inventing or mislabeling files.
