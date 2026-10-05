# Phase 1 TCP and TLS Verification

## TCP Communication

The Phase 1 network uses TCP for HTTPS communication between the client, Nginx/TLS load balancer, and backend services.

The main HTTPS endpoint is:

10.7.15.18:8443

The backend services are:

- Backend A: 10.7.10.160:3001
- Backend B: 10.7.9.47:3002

The available packet-capture evidence does not contain a clean, isolated TCP three-way handshake showing SYN, SYN-ACK, and ACK packets. Therefore, no TCP handshake result is claimed here.

## TLS Communication

HTTPS traffic is terminated at the Nginx load balancer at:

10.7.15.18:8443

The TLS configuration uses TLS 1.2.

The certificate was created for:

- app.team1.test
- api.team1.test

The TLS handshake was verified from the client using `curl -v`.

The observed handshake included:

- Client Hello
- Server Hello
- Certificate
- Server Key Exchange
- Client Key Exchange
- Change Cipher Spec
- Finished

The certificate verification succeeded with:

SSL certificate verify ok.

## Evidence

- `tls_handshake.png` contains the Wireshark TLS evidence.
- The HTTPS/TLS client-side verification is also documented in the project evidence screenshots.
- `tcp_handshake.png` should only be treated as TCP handshake evidence if a capture clearly showing SYN, SYN-ACK, and ACK is available.
