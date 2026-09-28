#!/bin/sh

set -eu

url=${1:?Usage: test.sh URL}

# HTTPS clients need a trust store even though the deterministic fixture uses HTTP.
test -s /etc/ssl/certs/ca-certificates.crt

# Keep the commands separate so a curl failure cannot be masked by a pipeline.
body=$(curl --fail --silent --show-error --connect-timeout 5 --max-time 15 "$url")
printf '%s\n' "$body" | jq --exit-status \
  '.message == "hello" and (.items | map(. * 2)) == [2, 4, 6]' > /dev/null
