#!/usr/bin/env bash
# Tool for generating artificial load on the trigger service.

set -Eeuo pipefail

TRIGGER_API_HOST=localhost
TRIGGER_API_PORT=4002
GOOD_STATUS="200"


CURRENT_NUMBER=1
while true
do
  ((CURRENT_NUMBER+=1))
  # provide an indication after 10 seconds that something happened
  if [ $((CURRENT_NUMBER % 10)) -eq 0 ]
  then
    echo Iteration $CURRENT_NUMBER
    # Sleep for 1 second after each request. Triggers should be dependent upon ledger events so
    # they aren't expected to be the load traffic source. However, we do want the load to show up so
    # it needs to be comparable to the JSON API server.
    sleep 1
  fi

  # Generate a trigger request
  http_code=$(curl --silent --output /dev/null --write-out "%{http_code}" --request POST --data '{
    "triggerName": "e0326da3de4b3d4ef4d193907afb82bf9afb938daccea445cbca747bb79c9139:NoOp:noOp",
    "party": "alice",
    "applicationId": "test-app-id"
  }' -H 'Content-Type: application/json' ${TRIGGER_API_HOST}:${TRIGGER_API_PORT}/v1/triggers )

  # Check to make sure the status code was OK
  if [ "${http_code}" != "${GOOD_STATUS}" ]; then
      echo "ERROR:  CURL status code was ${http_code} but expected ${GOOD_STATUS}.  Exiting ...."
      exit 1
  fi


done
