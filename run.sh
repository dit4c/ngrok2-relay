#!/bin/bash

set -e

if [[ "$NGROK_REGION" == "" ]]; then
  echo "Must specify NGROK_REGION to use: ap au eu us"
  exit 1
fi

if [[ "$TARGET_HOST" == "" ]]; then
  echo "Must specify TARGET_HOST to expose"
  exit 1
fi

if [[ "$TARGET_PORT" == "" ]]; then
  echo "Must specify TARGET_PORT to expose"
  exit 1
fi

ngrok http --config /etc/ngrok2.conf \
    -region $NGROK_REGION \
    $TARGET_HOST:$TARGET_PORT 2>&1 | \
  /opt/bin/listen_for_url.sh | \
  /opt/bin/notify.sh
