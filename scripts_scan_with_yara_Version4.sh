#!/usr/bin/env bash
set -euo pipefail
RULES=${1:-./all_rules_combined.yar}
TARGET=${2:-/var/www}
YARA_BIN=${3:-./out/bin/yara}

if [ ! -x "$YARA_BIN" ]; then
  echo "yara not found: $YARA_BIN" >&2
  exit 2
fi
if [ ! -f "$RULES" ]; then
  echo "rules not found: $RULES" >&2
  exit 2
fi

WHITELIST=( "/var/www/vendor/" "/var/www/node_modules/" )
is_white(){
  for w in "${WHITELIST[@]}"; do
    [[ "$1" == "$w"* ]] && return 0
  done
  return 1
}

while IFS= read -r -d '' file; do
  is_white "$file" && continue
  out=$("$YARA_BIN" -r "$RULES" "$file" 2>/dev/null || true)
  if [ -n "$out" ]; then
    echo "MATCH: $file"
    echo "$out"
  fi
done < <(find "$TARGET" -type f -print0)