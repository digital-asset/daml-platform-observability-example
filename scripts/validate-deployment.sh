#!/usr/bin/env bash

set -euo pipefail

## Query Prometheus for the daml_health_status metric and validate that it has the value 1, representing a healthy service

retry=0
result=
until [ "$retry" -ge 5 ]; do
  # Running the command directly in the prometheus container
  # This is required so that we can run it in CircleCI, more details here: https://circleci.com/docs/building-docker-images/#accessing-services
  result=$(curl --retry 10 --retry-connrefused 'http://localhost:9090/api/v1/query?query=daml_health_status+%3E%3D+1' | grep daml_health_status)
  if [ -z "$result" ]; then
    echo "Services are registered healthy in prometheus."
    echo "$result"
    exit 0
  else
    echo "No healthy service yet, retrying."
    echo "$result"
  fi
  retry=$((retry + 1))
  sleep 15
done

echo "No healthy service was found in the metrics."
echo "Canton logs"
docker logs canton
exit 1
