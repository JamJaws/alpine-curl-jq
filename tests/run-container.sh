#!/usr/bin/env bash

set -euo pipefail

image=${1:?Usage: tests/run-container.sh IMAGE [PLATFORM]}
platform=${2:-linux/amd64}
port=${TEST_PORT:-8765}
repository_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
server_log=$(mktemp)
base_url="http://127.0.0.1:$port"

python3 -m http.server "$port" --bind 127.0.0.1 \
  --directory "$repository_root/tests" > "$server_log" 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true; rm -f "$server_log"' EXIT

if ! curl --fail --silent --show-error --retry 5 --retry-connrefused \
  --retry-delay 1 --retry-max-time 10 --max-time 2 \
  "$base_url/fixture.json" > /dev/null; then
  cat "$server_log" >&2
  exit 1
fi

run_args=(
  --rm --platform "$platform" --network host
  --user 65532:65532 --read-only --cap-drop ALL
  --security-opt no-new-privileges=true --entrypoint sh
  --volume "$repository_root/test.sh:/opt/test.sh:ro"
)

docker run "${run_args[@]}" "$image" /opt/test.sh "$base_url/fixture.json"

# This also catches regressions where the entrypoint silently skips the test script.
if docker run "${run_args[@]}" "$image" /opt/test.sh "$base_url/missing.json"; then
  echo 'The smoke test incorrectly succeeded for an HTTP 404.' >&2
  exit 1
fi

printf 'Smoke tests passed on %s\n' "$platform"
