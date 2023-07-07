#!/usr/bin/env bash
# Run conformance tests against the Ledger API.
# See Ledger API Test Tool site https://docs.daml.com/tools/ledger-api-test-tool/index.html for more info.

set -euo pipefail

# Full path to this script
current_dir=$(cd "$(dirname "${0}")" && pwd)

# shellcheck source=./.env
source "${current_dir}/../.env"

download_url="https://repo1.maven.org/maven2/com/daml/ledger-api-test-tool/${SDK_VERSION}/ledger-api-test-tool-${SDK_VERSION}.jar"
jar_file=$(basename "${download_url}")
ledger_api_host=localhost
ledger_api_port=10011

if [[ ! -s "${jar_file}" ]]; then
  echo "### Downloading Ledger API test tool ${SDK_VERSION} JAR file..."
  curl -fsSLO "${download_url}" \

else
  echo "### Using existing Ledger API test tool ${SDK_VERSION} JAR file"
fi

echo "### Running Ledger API conformance tests ${SDK_VERSION} 🛠️"
java -jar "${jar_file}" ${ledger_api_host}:${ledger_api_port} --exclude ''
