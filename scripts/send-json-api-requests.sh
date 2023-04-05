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
  "http://${JSON_API_HOST}:${JSON_API_PORT}/v1/user" > /dev/null 2>&1
}

# $1 contract JSON
# returns contract ID
function createContract () {
  echo "$1" | \
  curl -s \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${SOME_JWT}" \
  --data @- \
  "http://${JSON_API_HOST}:${JSON_API_PORT}/v1/create" > /dev/null 2>&1
}

CURRENT_NUMBER=1
while true
do
  ((CURRENT_NUMBER+=1))
  if [ $((CURRENT_NUMBER % 10)) -eq 0 ]
  then
    echo Iteration $CURRENT_NUMBER
    # Reduce CPU use since it is assumed this is running on a laptop.
    sleep 1
  fi

  # Generate some traffic on the standard API endpoints.
  if [ $((RANDOM % 2)) -eq 0 ]
  then
    createContract "{}"
  else
    getParty
  fi

  # Generate traffic on the health check endpoints.  See https://docs.daml.com/json-api/index.html#healthcheck-endpoints
  curl http://${JSON_API_HOST}:${JSON_API_PORT}/livez > /dev/null 2>&1
  curl http://${JSON_API_HOST}:${JSON_API_PORT}/readyz > /dev/null 2>&1
done
