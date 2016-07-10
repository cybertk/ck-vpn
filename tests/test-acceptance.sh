#!/usr/bin/env bats

fixtures() {
    FIXTURE_DIR="$BATS_TEST_DIRNAME/fixtures"
    SCRIPT_DIR="$BATS_TEST_DIRNAME/.."

    FIXTURE_VALID_DIR="$BATS_TEST_DIRNAME/tmp"

    TEST_IMAGE=test-ck-vpn
    TEST_CONTAINER=test-ck-vpn
}

setup() {
    mkdir -p "$FIXTURE_VALID_DIR" || true
}

teardown() {
    rm -rf "$FIXTURE_VALID_DIR"
    # Cleanup docker
    docker rm -f "$TEST_CONTAINER"

    sleep 1
}

fixtures

@test "global setup" {
    # Build image
    docker build -t "$TEST_IMAGE" "$SCRIPT_DIR"
}

@test "start through docker with predefined server_address and secret" {
    expected_server_address="$(docker-machine ip)"
    expected_secret="iamsecret"
    expected_mobileconfig=$FIXTURE_VALID_DIR/vpn.mobileconfig

    run docker run -d --name $TEST_CONTAINER \
        --privileged -p 80:80 -p 500:500/udp -p 4500:4500/udp \
        -e "CK_VPN_SERVER_ADDRESS=$expected_server_address" \
        -e "CK_VPN_SECRET=$expected_secret" \
        $TEST_IMAGE

    # it should exit 0
    [ $status -eq 0 ]

    # it should listen on udp port 500
    sudo nmap "$expected_server_address" -sU -Pn -p 500 | grep '500\/udp.*open'
    # it should listen on udp port 4500
    sudo nmap "$expected_server_address" -sU -Pn -p 4500 | grep '4500\/udp.*open'
    # it should listen on tcp port 80
    nmap "$expected_server_address" -Pn -p 80 | grep '80\/tcp.*open'

    # it should accept vpn client
    # docker run --rm -it --privileged $TEST_IMAGE \
    #     charon-cmd --host $expected_server_address --identity tester.docker

    # it should host vpn profile
    curl http://$expected_server_address/vpn.mobileconfig >$expected_mobileconfig

    # it should host valid vpn profile
    # TODO: profiles will pop up a prompt window to confirm modification
    # sudo profiles -I -F $expected_mobileconfig -U $(whoami)

    # generated mobileconfig should contains valid server_address and secret
    cat "$expected_mobileconfig" | grep "$expected_server_address"
    cat "$expected_mobileconfig" | grep "$expected_secret"
}

@test "global teardown" {
    docker rmi -f "$TEST_IMAGE"
}
