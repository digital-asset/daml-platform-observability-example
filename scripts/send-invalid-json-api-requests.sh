#!/usr/bin/env bash
# Tool for generating artificial load on the HTTP-JSON service.

set -Eeuo pipefail

SOME_JWT=""

JSON_API_HOST=localhost
JSON_API_PORT=4001

# returns party ID, or empty
function getParty () {
  curl -s \
  -H "Authorization: Bearer ${SOME_JWT}" \
  "http://${JSON_API_HOST}:${JSON_API_PORT}/v1/user" | \
  jq -r ".result.primaryParty"
}

# $1 contract JSON
# returns contract ID
function createContract () {
  echo "$1" | \
  curl -s \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${SOME_JWT}" \
  --data @- \
  "http://${JSON_API_HOST}:${JSON_API_PORT}/v1/create" | \
  jq -r ".result.contractId"
}

# Generate some traffic.

CURRENT_NUMBER=1

while true
do
  ((CURRENT_NUMBER+=1))

  if [ $((CURRENT_NUMBER % 20)) -eq 0 ]
  then
    echo $CURRENT_NUMBER
  fi

  if [ $((RANDOM % 10)) -eq 0 ]
  then
    createContract "{}"
  else
    getParty
  fi
done
