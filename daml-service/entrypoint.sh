#!/bin/bash
set -euo pipefail

[[ -n ${VERBOSE:-} ]] && set -x

# Log everything (stdout and stderr) to both log file and terminal
exec > >(tee /var/log/promtail/"${DAML_SERVICE}".log) 2>&1

# eval "exec java -XX:+CrashOnOutOfMemoryError ${JAVA_OPTS:-} -jar /opt/service.jar \"\$@\""
eval "exec java ${JAVA_OPTS:-} -jar /opt/service.jar \"\$@\""
