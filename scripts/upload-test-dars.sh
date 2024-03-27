#!/usr/bin/env bash
set -euo pipefail

# Script to upload the  test DARs to the ledger

# Full path to this script
current_dir=$(cd "$(dirname "${0}")" && pwd)

source "${current_dir}/../.env"

download_url="https://repo1.maven.org/maven2/com/daml/ledger-api-test-tool/${SDK_VERSION}/ledger-api-test-tool-${SDK_VERSION}.jar"
jar_file=$(basename "${download_url}")

if [[ ! -s "${jar_file}" ]]; then
  echo "### Downloading Ledger API test tool ${SDK_VERSION} JAR file..."
  curl -fsSLO "${download_url}" \

else
  echo "### Using existing Ledger API test tool ${SDK_VERSION} JAR file"
fi

echo "### Extracting DARs from Ledger API conformance tests ${SDK_VERSION} 🛠️"
java -jar "${jar_file}" -x

for i in *.dar; do
    [ -f "$i" ] || break
    daml ledger upload-dar --host localhost --port 10011 "$i"
    rm "$i"
done

echo '### Done'
