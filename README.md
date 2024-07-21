# WireGuard

Project to learn about WireGuard.

## level1

* Base code to get a WireGuard server running with docker container to route all traffic through a VPN.

## level 2

* Externalized configuration

## level 3

* Reducing security risks, running without root user.

# FYI

* The project https://github.com/pivpn/pivpn has many interesting scripts, ex.:
    * Detecting which network interface to use
    * Auto-picking ip addresses for clients given an ip network
    * IPv6 support
    * etc.

<details><summary>Implementation details</summary>

* My custom env. variables are prefixed with `LEVELX_`, so it's easier to search references across files.
  * And to make it clear that I am not re-using env. variables that are supported by other software.
* Port numbers could all be the same, but distinct values were used to not confound them & help people not familiar with docker.
</details>