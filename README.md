# dit4c-router-ngrok2

DIT4C routing connector based on ngrok2.

## ./jwt

Currently includes statically-built binary for jwt creation:
<https://github.com/knq/jwt/>

It can be rebuilt with:
```
mkdir /tmp/go-build
rkt run --interactive --dns=8.8.8.8 --insecure-options=image \
  --volume go-build,kind=host,source=/tmp/go-build \
  docker://library/golang \
  --set-env CGO_ENABLED=0 \
  --set-env GOOS=linux \
  --mount volume=go-build,target=/go \
  --exec /usr/local/go/bin/go -- \
  get -v --ldflags '-extldflags "-static"' github.com/knq/jwt/cmd/jwt
```
