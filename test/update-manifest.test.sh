#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_PATH="$ROOT_DIR/scripts/update-manifest.sh"

if [[ ! -f "$SCRIPT_PATH" ]]; then
  echo "update-manifest script not found at $SCRIPT_PATH"
  exit 1
fi

workspace="$(mktemp -d "${TMPDIR:-/tmp}/manifest-update-test.XXXXXX")"
trap 'rm -rf "$workspace"' EXIT

repo="$workspace/repo"
output_file="$workspace/output.txt"
mkdir -p "$repo"

cat > "$repo/package.json" <<'EOF'
{
  "name": "manifest-test",
  "version": "1.0.0"
}
EOF

VERSION='1.2.3' \
WORKING_DIRECTORY="$repo" \
UPDATE_PACKAGE_LOCK='false' \
GITHUB_OUTPUT="$output_file" \
bash "$SCRIPT_PATH"

new_version="$(node -p "require('${repo}/package.json').version")"
if [[ "$new_version" != '1.2.3' ]]; then
  echo "Expected package.json version 1.2.3 but got ${new_version}"
  exit 1
fi

if ! grep -q '^packageJsonUpdated=true$' "$output_file"; then
  echo 'Expected packageJsonUpdated=true'
  cat "$output_file"
  exit 1
fi

if ! grep -q '^packageLockUpdated=false$' "$output_file"; then
  echo 'Expected packageLockUpdated=false'
  cat "$output_file"
  exit 1
fi

echo "All update-manifest tests passed"
