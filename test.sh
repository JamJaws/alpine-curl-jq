#!/bin/sh

set -eu

cd "$(dirname "$0")"
export TEST_IMAGE="${1:-alpine-curl-jq:test}"
export TEST_PLATFORM="${2:-}"

compose() {
  docker compose -p "alpine-curl-jq-test-$$" -f compose.test.yaml "$@"
}

run() {
  compose run --rm -T --no-deps test "$@"
}

trap 'compose down --remove-orphans' EXIT

# With an image argument, test that exact image without rebuilding it (used by CI).
if [ "$#" -eq 0 ]; then
  docker build --pull -t "$TEST_IMAGE" .
fi

compose up -d --wait --wait-timeout 30 busybox
run 'exec /opt/http.sh http://busybox:8080/fixture.json'

# Require curl's HTTP-error status; a skipped script or network failure must fail.
status=0
run 'exec /opt/http.sh http://busybox:8080/missing.json' || status=$?
if [ "$status" -ne 22 ]; then
  echo "Expected curl exit 22 for HTTP 404, got $status." >&2
  exit 1
fi

help_output=$(run)
case "$help_output" in
  'Usage: curl '*) ;;
  *) echo 'Running without a command did not print curl help.' >&2; exit 1 ;;
esac

echo 'Container tests passed.'
