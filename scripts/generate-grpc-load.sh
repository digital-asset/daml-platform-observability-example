#!/usr/bin/env bash
# Run conformance tests against the Ledger API.
# Usage:  generate-rpc-load.sh <<number of iterations>>  where <<number of iterations>> defaults to 10
# See Ledger API Test Tool site https://docs.daml.com/tools/ledger-api-test-tool/index.html for more info.

# shellcheck disable=SC1090
source "$(dirname "$0")"/../.env

LEDGER_API_TEST_TOOL=ledger-api-test-tool-${SDK_VERSION}.jar
LEDGER_API_HOST=localhost
LEDGER_API_PORT=10011

if [ ! -f "$LEDGER_API_TEST_TOOL" ]; then
    echo "### Retrieving $LEDGER_API_TEST_TOOL from Maven."
    curl -o "${LEDGER_API_TEST_TOOL}" -O  https://repo1.maven.org/maven2/com/daml/ledger-api-test-tool/"${SDK_VERSION}"/ledger-api-test-tool-"${SDK_VERSION}".jar
fi

if [ -f "$LEDGER_API_TEST_TOOL" ]; then
    echo "### $LEDGER_API_TEST_TOOL exists .. preparing to start the Ledger API Test Tool."
else 
    echo "### $LEDGER_API_TEST_TOOL does not exist .. exiting."
    exit 1
fi

counter=10 # default number of loops
if [ $# -ne 0 ]
  then
    # arguments supplied
    counter=$(( $1 ))
fi

echo "### Running Ledger API conformance tests ${SDK_VERSION} 🛠️"
echo "### Starting Ledger API Test Tool with a countdown of $counter to 0"
while [ $counter -ne 0 ]
do
    echo "============================= "
    echo "Iteration " $counter
    echo " " 
    java -jar "${LEDGER_API_TEST_TOOL}" ${LEDGER_API_HOST}:${LEDGER_API_PORT}
    ((counter--))
done
