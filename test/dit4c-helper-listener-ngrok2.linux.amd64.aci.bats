#!/usr/bin/env bats

IMAGE="$BATS_TEST_DIRNAME/../dist/dit4c-helper-listener-ngrok2.linux.amd64.aci"
RKT="$BATS_TEST_DIRNAME/../build/rkt/rkt --dir=$BATS_TEST_DIRNAME/../build/test/rkt-env"

@test "curl supports HTTPS" {
  run sudo $RKT run --insecure-options=image $IMAGE --exec curl -- -V
  [ "$status" -eq 0 ]
  [ $(expr "${output}" : ".*Protocols: .*https.*") -ne 0 ]
}
