#!/usr/bin/env bash
set -euo pipefail

version="${VERSION:?VERSION is required}"
package_json_path="${PACKAGE_JSON_PATH:-package.json}"
package_lock_path="${PACKAGE_LOCK_PATH:-package-lock.json}"
update_package_lock="${UPDATE_PACKAGE_LOCK:-true}"
working_directory="${WORKING_DIRECTORY:-.}"

pushd "$working_directory" >/dev/null

package_json_updated='false'
package_lock_updated='false'

if [[ -f "$package_json_path" ]]; then
  NEW_VERSION="$version" PACKAGE_JSON_PATH="$package_json_path" python3 - <<'PY'
import json
import os

path = os.environ["PACKAGE_JSON_PATH"]
version = os.environ["NEW_VERSION"]

with open(path, "r", encoding="utf-8") as handle:
    parsed = json.load(handle)

parsed["version"] = version

with open(path, "w", encoding="utf-8") as handle:
    json.dump(parsed, handle, indent=2)
    handle.write("\n")
PY
  package_json_updated='true'
fi

if [[ "$update_package_lock" == "true" && -f "$package_lock_path" ]]; then
  if command -v npm >/dev/null 2>&1; then
    if [[ -f package.json ]]; then
      npm install --package-lock-only --ignore-scripts >/dev/null
      package_lock_updated='true'
    fi
  fi
fi

popd >/dev/null

echo "packageJsonUpdated=${package_json_updated}" >> "$GITHUB_OUTPUT"
echo "packageLockUpdated=${package_lock_updated}" >> "$GITHUB_OUTPUT"
