FROM alpine:3.3

# See http://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management#Advanced_APK_Usage
RUN apk add --no-cache strongswan=5.3.5-r1

# Strongswan Configuration
ADD ./vpn_config/ipsec.conf /etc/ipsec.conf
ADD ./vpn_config/strongswan.conf /etc/strongswan.conf

# Apps
Add init.sh /usr/bin/init

# Web
ADD web /www

VOLUME /www

EXPOSE 80 500/udp 4500/udp

# ENTRYPOINT ["/usr/local/bin/init"]
CMD /usr/bin/init
