# Phase 1 DNS Packet Capture

## Purpose

This capture verifies DNS communication between the client and the project DNS server.

## DNS Server

- DNS Server IP: 10.7.24.103
- Protocol: DNS
- Port: 53
- Transport: UDP

## Client

- Client IP: 10.7.9.47

## Observed Traffic

The Wireshark capture shows DNS queries and responses between:

10.7.9.47 -> 10.7.24.103

and

10.7.24.103 -> 10.7.9.47

The DNS traffic confirms that the client is communicating with the configured private DNS server.

## Project DNS Resolution

The project domains resolve to the Nginx/TLS load balancer:

- app.team1.test -> 10.7.15.18
- api.team1.test -> 10.7.15.18

The DNS resolution was also verified using `dig` against the DNS server at 10.7.24.103.

## Evidence

See `dns.png` for the Wireshark DNS packet capture.
