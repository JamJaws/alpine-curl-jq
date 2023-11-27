#!/bin/sh

set -e

value=$(curl -s -f https://jsonplaceholder.typicode.com/posts/2 | jq -e -r '.title' )

if [ "$value" = "qui est esse" ]; then
  exit 0
else
  exit 1
fi
