#!/bin/bash

if [[ "$NGROK_REGION" == "" ]]; then
  echo "Must specify NGROK_REGION to use"
  exit 1
fi

if [[ "$DIT4C_INSTANCE_HELPER_AUTH_HOST" == "" ]]; then
  echo "Must specify DIT4C_INSTANCE_HELPER_AUTH_HOST to expose"
  exit 1
fi

if [[ "$DIT4C_INSTANCE_HELPER_AUTH_PORT" == "" ]]; then
  echo "Must specify DIT4C_INSTANCE_HELPER_AUTH_PORT to expose"
  exit 1
fi

if [[ ! -f "$DIT4C_INSTANCE_PRIVATE_KEY" ]]; then
  echo "Unable to find DIT4C_INSTANCE_PRIVATE_KEY: $DIT4C_INSTANCE_PRIVATE_KEY"
  exit 1
fi

if [[ "$DIT4C_INSTANCE_JWT_ISS" == "" ]]; then
  echo "Must specify DIT4C_INSTANCE_JWT_ISS for JWT auth token"
  exit 1
fi

if [[ "$DIT4C_INSTANCE_JWT_KID" == "" ]]; then
  echo "Must specify DIT4C_INSTANCE_JWT_KID for JWT auth token"
  exit 1
fi

ngrok http --config /etc/ngrok2.conf \
    -region $NGROK_REGION \
    $DIT4C_INSTANCE_HELPER_AUTH_HOST:$DIT4C_INSTANCE_HELPER_AUTH_PORT | \
  /opt/bin/listen_for_url.sh | \
  /opt/bin/notify_portal.sh
