#!/usr/bin/env bats

fixtures() {
    FIXTURE_DIR="$BATS_TEST_DIRNAME/fixtures"
    SCRIPT_DIR="$BATS_TEST_DIRNAME/.."

    FIXTURE_VALID_DIR="$BATS_TEST_DIRNAME/tmp"

    # UUID regex pattern, see http://stackoverflow.com/a/38162719/622662
    UUID_REGEX="[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}"
}

setup() {
    mkdir -p "$FIXTURE_VALID_DIR" || true
}

teardown() {
    rm -rf "$FIXTURE_VALID_DIR"
    sleep 1
}

fixtures

# Global setup. See https://github.com/sstephenson/bats/issues/108
@test "ensure fixtures" {
    echo pass
}

@test "initialize a mobileconfig" {
    expected_server_address="example.com"
    expected_secret="i_am_secret"

    run docker run --rm -it -v $SCRIPT_DIR:/ck-vpn alpine:3.3 /bin/sh -c \
        "CKVPN_TEST=1 . /ck-vpn/init.sh; init_mobileconfig "$expected_server_address" "$expected_secret""

    # it should exit 0
    [ $status -eq 0 ]
    # generated mobileconfig should contains valid server_address and secret
    echo "$output" | grep "$expected_server_address"
    echo "$output" | grep "$expected_secret"
    # generated mobileconfig should contains valid uuid
    echo "$output" | grep -E "$UUID_REGEX"
}
