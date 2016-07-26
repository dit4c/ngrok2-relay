#!/usr/bin/env bats

IMAGE="$BATS_TEST_DIRNAME/../dist/dit4c-helper-listener-ngrok2.linux.amd64.aci"
RKT="$BATS_TEST_DIRNAME/../build/rkt/rkt --dir=$BATS_TMPDIR/../build/test/rkt-env"

teardown() {
  sudo $RKT gc --grace-period=0s
}

@test "curl supports HTTPS" {
  run sudo $RKT run --insecure-options=image $IMAGE --exec curl -- -V
  echo $output
  [ "$status" -eq 0 ]
  [ $(expr "${output}" : ".*Protocols: .*https.*") -ne 0 ]
}
