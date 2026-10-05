# Phase 1 Report

## 1. Network Setup
Four Macs were configured on the same private network using interface `en0`, subnet
`10.7.0.0/19`, mask `255.255.224.0`, and gateway `10.7.0.1`.

## 2. Roles
- Mac 1: private DNS server
- Mac 2: Nginx TLS load balancer
- Mac 3: Backend A
- Mac 4: Backend B and client

## 3. DNS
The private DNS server is `10.7.24.103`. The application domains resolve to the Nginx
load balancer at `10.7.15.18`.

## 4. Load Balancing
Nginx listens on TCP `8443` and routes requests to Backend A on `3001` and Backend B on
`3002`. Selected evidence demonstrates alternating backend responses.

## 5. TLS
The selected evidence demonstrates certificate setup and a successful TLS handshake for
the private application domains.

## 6. Caching
The selected cache evidence demonstrates cache-control headers, an ETag, and a conditional
request returning `304 Not Modified`.

## 7. Packet Verification
Selected packet-capture screenshots demonstrate DNS resolution and backend switching.

## 8. Evidence Limitations
The supplied material did not include the raw application source, raw Nginx/dnsmasq config,
raw PCAP files, or dedicated failure-demo screenshots. The repository structure reserves
locations for these artifacts without fabricating them.
