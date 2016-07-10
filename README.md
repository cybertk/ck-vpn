# ck-vpn

> IKEv2 VPN Server for iOS/OSX with zero config

[![Build Status](https://travis-ci.org/cybertk/ck-vpn.svg)](https://travis-ci.org/cybertk/ck-vpn)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://registry.hub.docker.com/u/quanlong/ck-vpn/)
[![Docker image layers and size](https://badge.imagelayers.io/quanlong/ck-vpn:latest.svg)](https://imagelayers.io/?images=quanlong/ck-vpn:latest)

## Getting started

    docker run --privileged -p 80:80 -p 500:500/udp -p 4500:4500/udp quanlong/ck-vpn

## Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command. Alternatively you can use docker-compose.*

Below is the complete list of available options that can be used to customize your ck-vpn installation.

- **CKVPN_SERVER_ADDRESS:**, The server address. No defaults.
- **CKVPN_SECRET:** Pre share key of VPN server. Defaults to the 32 random characters.
- **CKVPN_VIP:** Client's subnet. Defaults to `10.0.5.0/24`.
- **CKVPN_HTTP_HOME:** The home/root dir of builtin HTTP server(**httpd**). Defaults to `/www`.
- **CKVPN_MOBILECONFIG_PATH:** The path of generated Apple's VPN profile. Defaults to `$CONFIG_HTTP_HOME/vpn.mobileconfig`.

## FAQ

### invalid ID_V1 payload length, decryption failed?

The "invalid ID_V1 payload length, decryption failed" part is typical of a mismatched pre-shared key, though that's not the only possible cause.

See more on:

- https://forum.pfsense.org/index.php?topic=100597.0

### no virtual IP found, sending INTERNAL_ADDRESS_FAILURE

```
10[IKE] peer requested virtual IP %any6
10[IKE] no virtual IP found for %any6 requested by 'ios'
10[IKE] no virtual IP found, sending INTERNAL_ADDRESS_FAILURE
```

### updown: iptables v1.4.21: can't initialize iptables table `filter': Permission denied (you must be root)

Solved by disabled updown script with `--disable-updown` while compiling from source

See more on:

- https://wiki.strongswan.org/projects/strongswan/wiki/Updown
- https://wiki.strongswan.org/projects/strongswan/wiki/ForwardingAndSplitTunneling

## References

- https://github.com/gaomd/docker-ikev2-vpn-server
- https://github.com/philpl/docker-strongswan
- https://wiki.strongswan.org/projects/strongswan/wiki/AppleIKEv2Profile
- https://wiki.strongswan.org/projects/strongswan/wiki/ConnSection
- https://www.ipify.org
- http://cr.yp.to/publicfile/install.html
- https://wiki.openwrt.org/doc/howto/http.httpd
- http://nickjanetakis.com/blog/alpine-based-docker-images-make-a-difference-in-real-world-apps
- https://git.busybox.net/busybox/tree/networking/httpd.c
