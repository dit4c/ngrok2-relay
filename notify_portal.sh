#!/bin/sh

set -e

# Read each line in
while IFS= read -r URL; do
  TOKEN=$(jwt -k $DIT4C_INSTANCE_PRIVATE_KEY \
    -alg RS512 \
    -enc \
    iss=$DIT4C_INSTANCE_JWT_ISS \
    kid=$DIT4C_INSTANCE_JWT_KID)
  curl -v -X PUT --retry 1000 \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: text/plain; charset=UTF-8" \
    -d "$URL" \
    "$DIT4C_INSTANCE_URI_UPDATE_URL"
done
