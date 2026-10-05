# Wrong HTTPS Port

## Scenario

This test demonstrates what happens when the client connects to the wrong HTTPS port.

## Correct HTTPS Endpoint

The Nginx TLS load balancer listens on:

10.7.15.18:8443

## Failure Demonstration

The client attempts to connect using:

10.7.15.18:8444

The connection is refused because no HTTPS service is listening on port 8444.

## Expected Result

The client receives a connection failure instead of an HTTP response.

## Correct Request

The correct endpoint is:

https://app.team1.test:8443/api/status

## Evidence

See `Wrong HTTPS Port.png`.
