#!/bin/sh

# The MIT License (MIT)
#
# Copyright (c) 2016 Quanlong He
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Customizations
CONFIG_VIP=10.0.5.0/24
CONFIG_HTTP_HOME=/www
CONFIG_MOBILECONFIG_PATH=$CONFIG_HTTP_HOME/vpn.mobileconfig
CONFIG_IPSEC_SECRETS_PATH=$CONFIG_HTTP_HOME/ipsec.secrets

config_route() {
    local vip="$1"

    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv6.conf.all.forwarding=1

    # https://wiki.strongswan.org/projects/strongswan/wiki/ForwardingAndSplitTunneling
    iptables -t nat -A POSTROUTING -s $vip -o eth0 -m policy --dir out --pol ipsec -j ACCEPT
    iptables -t nat -A POSTROUTING -s $vip -o eth0 -j MASQUERADE
}

init_ipsec_config() {
    local secret="$1"

    echo ": PSK \"$secret\""
}

init_mobileconfig() {
    local tv_server_address="$1" tv_secret="$2"

    # Alpine Linux dose not have uuidgen
    [ -f /proc/sys/kernel/random/uuid ] && alias uuidgen="cat /proc/sys/kernel/random/uuid"

    # The template variables contains in the following mobileconfig are
    # - $tv_server_address
    # - $tv_secret
    cat <<EOF
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<!-- See https://developer.apple.com/library/mac/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html -->
<plist version="1.0">
<dict>
    <!-- Set the name to whatever you like, it is used in the profile list on the device -->
    <key>PayloadDisplayName</key>
    <string>CK-VPN</string>
    <!-- This is a reverse-DNS style unique identifier used to detect duplicate profiles -->
    <key>PayloadIdentifier</key>
    <string>com.cybertk.vpn</string>
    <!-- A globally unique identifier, use uuidgen on Linux/Mac OS X to generate it -->
    <key>PayloadUUID</key>
    <string>$(uuidgen)</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadContent</key>
    <array>
        <!-- It is possible to add multiple VPN payloads with different identifiers/UUIDs and names -->
        <dict>
            <!-- This is an extension of the identifier given above -->
            <key>PayloadIdentifier</key>
            <string>com.cybertk.vpn.ikev2</string>
            <!-- A globally unique identifier for this payload -->
            <key>PayloadUUID</key>
            <string>$(uuidgen)</string>
            <key>PayloadType</key>
            <string>com.apple.vpn.managed</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <!-- This is the name of the VPN connection as seen in the VPN application later -->
            <key>UserDefinedName</key>
            <string>CK-VPN</string>
            <key>VPNType</key>
            <string>IKEv2</string>
            <key>IKEv2</key>
            <dict>
                <!-- Hostname or IP address of the VPN server -->
                <key>RemoteAddress</key>
                <string>$tv_server_address</string>
                <!-- Remote identity, can be a FQDN, a userFQDN, an IP or (theoretically) a certificate's subject DN. Can't be empty.
                     IMPORTANT: DNs are currently not handled correctly, they are always sent as identities of type FQDN -->
                <key>RemoteIdentifier</key>
                <string>$tv_server_address</string>
                <!-- Local IKE identity, same restrictions as above. If it is empty the client's IP address will be used -->
                <key>LocalIdentifier</key>
                <string></string>
                <!-- Use a pre-shared secret for authentication -->
                <key>AuthenticationMethod</key>
                <string>SharedSecret</string>
                <!-- The actual secret -->
                <key>SharedSecret</key>
                <string>$tv_secret</string>
                <!-- No EAP -->
                <key>ExtendedAuthEnabled</key>
                <integer>0</integer>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF
}

uuidgen() {
    if [[ -f /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
    else
        /usr/bin/uuidgen
    fi
}
get_public_ip() {
    # See https://www.ipify.org
    curl -s https://api.ipify.org
}

main() {
    local server_address secret

    server_address=$(get_public_ip)
    secret="$(openssl rand -base64 32)"

    # Initialize if did not
    if [ ! -f "$CONFIG_IPSEC_SECRETS_PATH" ]; then
        echo "ck-vpn: initializing"
        init_ipsec_config "$secret" >"$CONFIG_IPSEC_SECRETS_PATH"
        init_mobileconfig "$server_address" "$secret" >"$CONFIG_MOBILECONFIG_PATH"
    fi

    ln -sf "$CONFIG_IPSEC_SECRETS_PATH" /etc/ipsec.secrets

    echo "ck-vpn: configuring route tables"
    config_route "$CONFIG_VIP"

    echo "ck-vpn: starting http server on $server_address:80"
    httpd -h "$CONFIG_HTTP_HOME"

    echo "ck-vpn: starting ipsec"
    /usr/sbin/ipsec start --nofork $CK_VPN_IPSEC_DEBUG_OPTS
}

# [[ "$0" == "$BASH_SOURCE" ]] && main "$@"
[[ -z "$CK_VPN_TEST" ]] && main "$@"
