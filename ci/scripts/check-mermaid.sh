#!/usr/bin/env bash
# Extracts each ```mermaid ... ``` block from every .md (excluding repos/,
# node_modules/, .git/) and validates it by rendering with mmdc. Any parse
# failure fails the job. Requires @mermaid-js/mermaid-cli on PATH.
#
# Used by .github/workflows/diagram-parse.yml on push and PR.
#
# Locally: bash ci/scripts/check-mermaid.sh (after `npm i -g @mermaid-js/mermaid-cli`)

set -uo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

fail=0
total=0

# Extract Mermaid blocks. Each block becomes a separate .mmd file in tmpdir
# named <source-basename>_<block-index>.mmd so failures are traceable.
extract_blocks() {
  local file="$1"
  awk -v dir="$tmpdir" -v src="$(basename "$file" .md | tr ' /' '__')" '
    /^[[:space:]]*```mermaid[[:space:]]*$/ {
      in_block=1; n++
      out=dir "/" src "_" n ".mmd"
      header="# from: " FILENAME
      print header > out
      next
    }
    in_block && /^[[:space:]]*```[[:space:]]*$/ {
      in_block=0
      next
    }
    in_block { print > out }
  ' "$file"
}

while IFS= read -r file; do
  extract_blocks "$file"
done < <(find . \( -path ./repos -o -path ./node_modules -o -path ./.git \) -prune -o -name '*.md' -type f -print)

shopt -s nullglob
for mmd in "$tmpdir"/*.mmd; do
  total=$((total + 1))
  if ! mmdc -i "$mmd" -o "$tmpdir/out.svg" --quiet 2>"$tmpdir/err.log"; then
    echo "PARSE FAIL: $(head -1 "$mmd" | sed 's/^# from: //')"
    echo "--- block source: $mmd ---"
    cat "$mmd"
    echo "--- mmdc stderr ---"
    cat "$tmpdir/err.log"
    echo "---"
    fail=1
  fi
done

echo
echo "Mermaid blocks checked: ${total}"
echo "failures: ${fail}"
exit $fail
