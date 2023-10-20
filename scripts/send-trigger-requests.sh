#!/usr/bin/env bash
set -euo pipefail

# Script to generate artificial load on the trigger service

loops=10

for i in $(seq 1 "${loops}")
do
  echo "# Request ${i} (out of ${loops})"

  # Generate a trigger request
  http_code=$(curl -fsSL -o /dev/null -w "%{http_code}" -X POST \
    -H 'Content-Type: application/json' \
    --data '{"triggerName":"e0326da3de4b3d4ef4d193907afb82bf9afb938daccea445cbca747bb79c9139:NoOp:noOp","party":"observability","applicationId": "test-app-id"}' \
    localhost:4002/v1/triggers)

  # Check to make sure the status code was OK
  if [ "${http_code}" != '200' ]; then
    echo "ERROR: HTTP status code was ${http_code} but expected 200"
    exit 1
  fi

  sleep 1
done
