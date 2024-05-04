#!/bin/sh

set -e

LATEST_ALPINE="$(curl -s https://hub.docker.com/v2/repositories/library/alpine/tags | jq -r '.results[].name' | grep -E '^([0-9]+\.){2}[0-9]+' | sort --version-sort | tail -n 1)"

echo "Latest Alpine version is $LATEST_ALPINE"

echo "$LATEST_ALPINE" > alpine-version

sed -i "s/alpine-tag: .*/alpine-tag: $LATEST_ALPINE/g" .github/workflows/tag.yaml
