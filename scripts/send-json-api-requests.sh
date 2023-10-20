#!/usr/bin/env bash
set -euo pipefail

# Script to generate artificial load on the HTTP-JSON service

jwt=''
json_api_host=localhost
json_api_port=4001

# returns party ID, or empty
function getParty () {
  curl -s -o /dev/null \
    -H "Authorization: Bearer ${jwt}" \
    "http://${json_api_host}:${json_api_port}/v1/user"
}

# returns contract ID
function createContract () {
  curl -s -o /dev/null \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer ${jwt}" \
    --data '{}' \
    "http://${json_api_host}:${json_api_port}/v1/create"
}

loops=10

for i in $(seq 1 "${loops}")
do
  echo "# Request ${i} (out of ${loops})"

  # Generate some traffic on the standard API endpoints.
  if [ $((RANDOM%2)) -eq 0 ]
  then
    createContract
  else
    getParty
  fi

  sleep 1
done
