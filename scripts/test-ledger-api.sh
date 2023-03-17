#!/usr/bin/env bash
# Run conformance tests against the Ledger API.
# See Ledger API Test Tool site https://docs.daml.com/tools/ledger-api-test-tool/index.html for more info.

set -euo pipefail

# shellcheck disable=SC1090
source "$(dirname "$0")"/../.env

LEDGER_API_TEST_TOOL=ledger-api-test-tool-${SDK_VERSION}.jar
LEDGER_API_HOST=localhost
LEDGER_API_PORT=10011

echo '### Downloading Ledger API Test Tool...'
curl -o "${LEDGER_API_TEST_TOOL}" -O  https://repo1.maven.org/maven2/com/daml/ledger-api-test-tool/"${SDK_VERSION}"/ledger-api-test-tool-"${SDK_VERSION}".jar

echo "### Running Ledger API conformance tests ${SDK_VERSION} 🛠️"
java -jar "${LEDGER_API_TEST_TOOL}" ${LEDGER_API_HOST}:${LEDGER_API_PORT}
