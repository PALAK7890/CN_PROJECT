# Both Backends Down - 502 Bad Gateway

## Scenario

This test demonstrates the response when both backend services are unavailable.

## Backend Services

- Backend A: 10.7.10.160:3001
- Backend B: 10.7.9.47:3002

## Expected Result

When Nginx cannot connect to any upstream backend, the client receives:

HTTP 502 Bad Gateway

This indicates that the Nginx load balancer is reachable, but it cannot obtain a valid response from an upstream backend.

## Significance

This confirms that Nginx is acting as the reverse proxy and correctly reports upstream service failures.

## Evidence

See `Backend-Upstream Failure.png`.
