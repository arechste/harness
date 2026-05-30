#!/usr/bin/env bash
# Scans markdown files for `last-verified: YYYY-MM-DD` front matter and
# warns on files older than MAX_AGE_DAYS (default 180). Informational
# only — never fails the job; just prints stale files for review.
#
# Used by .github/workflows/doc-freshness.yml on a weekly cron.
#
# Locally: MAX_AGE_DAYS=30 bash ci/scripts/check-doc-freshness.sh

set -uo pipefail

MAX_AGE_DAYS="${MAX_AGE_DAYS:-180}"
TODAY_EPOCH=$(date +%s)
SECONDS_PER_DAY=86400

stale=0
total=0

# Parse `last-verified:` from the YAML front matter (between the first two
# `---` lines). Robust against `last-verified: 2026-05-30` and the same with
# trailing comments or whitespace.
get_last_verified() {
  awk '
    /^---[[:space:]]*$/ { n++; if (n==2) exit; next }
    n==1 && /^last-verified:/ {
      sub(/^last-verified:[[:space:]]*/, "")
      sub(/[[:space:]]*#.*$/, "")
      sub(/[[:space:]]+$/, "")
      print
      exit
    }
  ' "$1"
}

while IFS= read -r file; do
  date_str=$(get_last_verified "$file")
  [ -z "$date_str" ] && continue
  total=$((total + 1))

  # GNU date (Linux/CI) first, then BSD date (macOS) fallback.
  if file_epoch=$(date -d "$date_str" +%s 2>/dev/null); then
    :
  elif file_epoch=$(date -j -f '%Y-%m-%d' "$date_str" +%s 2>/dev/null); then
    :
  else
    printf "warn: unparseable last-verified '%s' in %s\n" "$date_str" "$file"
    continue
  fi

  age_days=$(( (TODAY_EPOCH - file_epoch) / SECONDS_PER_DAY ))
  if [ "$age_days" -gt "$MAX_AGE_DAYS" ]; then
    printf "STALE %4d days: %s (last-verified: %s)\n" "$age_days" "$file" "$date_str"
    stale=$((stale + 1))
  fi
done < <(find . \( -path ./repos -o -path ./node_modules -o -path ./.git \) -prune -o -name '*.md' -type f -print)

echo
echo "files with last-verified: ${total}"
echo "stale (>${MAX_AGE_DAYS} days):  ${stale}"
exit 0
