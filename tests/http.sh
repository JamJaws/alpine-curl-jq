#!/bin/sh

set -eu

url=${1:?Usage: http.sh URL}

# Keep the commands separate so a curl failure cannot be masked by a pipeline.
body=$(curl --fail --silent --show-error --connect-timeout 5 --max-time 15 "$url")
printf '%s\n' "$body" | jq --exit-status \
  '.message == "hello" and (.items | map(. * 2)) == [2, 4, 6]' > /dev/null
