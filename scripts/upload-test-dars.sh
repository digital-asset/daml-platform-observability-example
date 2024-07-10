#!/usr/bin/env bash
set -euo pipefail

# Script to upload the  test DARs to the ledger

# Full path to this script
current_dir=$(cd "$(dirname "${0}")" && pwd)

source "${current_dir}/../.env"

jar_file=lapitt.jar

echo "### Extracting DARs from Ledger API conformance tests ${SDK_VERSION} 🛠️"
java -jar "${jar_file}" -x

for i in *.dar; do
    [ -f "$i" ] || break
    daml ledger upload-dar --host localhost --port 10011 "$i"
    daml ledger upload-dar --host localhost --port 10021 "$i"
    rm "$i"
done

echo '### Done'
