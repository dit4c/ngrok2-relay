#!/bin/sh

set -e

# Read each line in
while IFS= read -r URL; do
  echo $URL
  if [[ "$NOTIFY_URL" != "" ]]; then
    curl -v --retry 1000 \
      -H "Content-Type: application/json; charset=UTF-8" \
      -d '{"url": "'$URL'"}' \
      "$NOTIFY_URL"
  fi
done
