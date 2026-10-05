# Backend Failure

## Scenario

This test demonstrates the behavior of the Nginx load balancer when a backend service is unavailable.

## Normal Configuration

The project uses two backend servers:

- Backend A: 10.7.10.160:3001
- Backend B: 10.7.9.47:3002

Nginx listens for HTTPS requests on:

- 10.7.15.18:8443

## Failure Demonstration

When a backend becomes unavailable, Nginx attempts to route the request to an available upstream server.

The failure can result in an upstream connection error if the requested backend cannot be reached.

## Expected Behavior

Nginx should continue serving requests through the available backend whenever possible.

## Evidence

See `Backend-Upstream Failure.png`.
