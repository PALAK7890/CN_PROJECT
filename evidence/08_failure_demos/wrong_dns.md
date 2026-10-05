# Wrong DNS Server

## Scenario

This test demonstrates the effect of configuring the client to use an incorrect DNS server.

## Correct DNS Server

The project DNS server is:

10.7.24.103

## Expected Result

If the client uses a different or incorrect DNS server, the project domains may fail to resolve correctly.

For example:

app.team1.test

api.team1.test

may return no valid project IP address.

## Correct Configuration

The client should use:

10.7.24.103

for DNS resolution.

## Evidence

See `Wrong DNS server.png`.
