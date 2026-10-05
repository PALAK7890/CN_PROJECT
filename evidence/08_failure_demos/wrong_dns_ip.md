# Wrong DNS Record

## Scenario

This test demonstrates the effect of configuring an incorrect IP address for a project domain.

## Correct DNS Records

The correct DNS records are:

app.team1.test -> 10.7.15.18

api.team1.test -> 10.7.15.18

## Failure Demonstration

An incorrect DNS record points the domain to the wrong address.

For example:

app.team1.test -> 10.7.13.58

This causes the client to connect to the wrong host instead of the Nginx/TLS load balancer.

## Expected Result

The application request fails or reaches the wrong service because DNS resolves the hostname to an incorrect IP address.

## Evidence

See `Wrong DNS record → 10.7.13.58....png`.
