# ck-vpn

> IKEv2 VPN Server for iOS/OSX with zero config

[![Build Status](https://travis-ci.org/cybertk/ck-vpn.svg)](https://travis-ci.org/cybertk/ck-vpn)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://registry.hub.docker.com/u/quanlong/ck-vpn/)
[![Docker image layers and size](https://badge.imagelayers.io/quanlong/ck-vpn:latest.svg)](https://imagelayers.io/?images=quanlong/ck-vpn:latest)

## Getting started

    docker run --privileged -p 80:80 -p 500:500/udp -p 4500:4500/udp quanlong/ck-vpn

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

It's caused by running strongSwan with reduced privileges, and Running the IKE daemon as non-root user breaks support for iptables updown script. As *iptables* is unable to handle capabilities and does not allow non-root users to insert rules, even if that user has the required capabilities.

See more on:

- https://wiki.strongswan.org/projects/strongswan/wiki/Updown
- https://wiki.strongswan.org/projects/1/wiki/ReducedPrivileges

### IDir '172.17.0.6' does not match to '1.2.3.4'

Where 1.2.3.4 is the public ip of gateway, while 172.17.0.6 is the gateway's docker inner ip

If you don't set rightid it defaults to the other peer's IP address, in your case 192.168.5.100. Your peer, however, uses 172.16.20.101 as identity (its own private IP). So make sure you configure left|rightid on both peers appropriately, so that they agree on their respective identities (e.g. set rightid=172.16.20.101 here, or set leftid=192.168.5.100 on the responder - you don't have to use IP addresses by the way, you could also set it to a FQDN on which both agree).')

See more on https://wiki.strongswan.org/issues/984


### unable to install inbound and outbound IPsec SA (SAD) in kernel

There is a same [issue](https://wiki.strongswan.org/issues/1069) on Strongswan Redmine

Caused by missing required kernel modules

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
