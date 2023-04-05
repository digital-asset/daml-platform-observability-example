#!/bin/bash
set -euo pipefail

[[ -n ${VERBOSE:-} ]] && set -x

# Bash trick - Log everything (stdout and stderr) to both log file and terminal
exec > >(tee -a "/var/log/promtail/${DAML_SERVICE}.log") 2>&1

exec java -jar "/opt/${DAML_SERVICE}.jar" "${@}"
