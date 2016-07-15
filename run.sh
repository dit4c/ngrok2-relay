#!/bin/bash

if [[ "$NGROK_REGION" == "" ]]; then
  echo "Must specify NGROK_REGION to expose"
  exit 1
fi

if [[ "$NGROK_BACKEND" == "" ]]; then
  echo "Must specify NGROK_BACKEND to expose"
  exit 1
fi

if [[ ! -f "$DIT4C_INSTANCE_PRIVATE_KEY" ]]; then
  echo "Unable to find DIT4C_INSTANCE_PRIVATE_KEY: $DIT4C_INSTANCE_PRIVATE_KEY"
  exit 1
fi

if [[ "$JWT_ISS" == "" ]]; then
  echo "Must specify JWT_ISS for JWT auth token"
  exit 1
fi

if [[ "$JWT_KID" == "" ]]; then
  echo "Must specify JWT_KID for JWT auth token"
  exit 1
fi

ngrok http --config /etc/ngrok2.conf \
    -region $NGROK_REGION \
    $NGROK_BACKEND | \
  /opt/bin/listen_for_url.sh | \
  /opt/bin/notify_portal.sh
