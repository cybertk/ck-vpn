# ck-vpn

> IKEv2 VPN Server for iOS/OSX with zero config

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
