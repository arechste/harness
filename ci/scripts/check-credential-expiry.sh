#!/usr/bin/env bash
# check-credential-expiry.sh — warn on credentials nearing or past expiry.
#
# Reads the SECRET-FREE inventory at state/credentials/INVENTORY.yaml (GL-002)
# and flags entries whose `expires:` date falls within the alert window. Reads
# ONLY metadata — never a credential value. Non-blocking by default: prints a
# report and exits 0 unless --strict is passed (then exits 1 if anything is due).
#
# Usage:
#   ci/scripts/check-credential-expiry.sh [--warn N] [--crit M] [--strict] [--file PATH]
#
# Defaults: --warn 14 (T-14d), --crit 7 (T-7d). Entries with expires: unknown
# are reported as NEEDS-METADATA (a gap to close), not as errors. Entries with
# expires: n/a or never are skipped (no fixed expiry — e.g. OAuth, age key).
#
# Requires: yq (mikefarah v4), GNU date (date -d).

set -euo pipefail

WARN_DAYS="${WARN_DAYS:-14}"
CRIT_DAYS="${CRIT_DAYS:-7}"
STRICT=0
FILE="state/credentials/INVENTORY.yaml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --warn) WARN_DAYS="$2"; shift 2 ;;
    --warn=*) WARN_DAYS="${1#*=}"; shift ;;
    --crit) CRIT_DAYS="$2"; shift 2 ;;
    --crit=*) CRIT_DAYS="${1#*=}"; shift ;;
    --strict) STRICT=1; shift ;;
    --file) FILE="$2"; shift 2 ;;
    --file=*) FILE="${1#*=}"; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -f "$FILE" ]]; then
  echo "check-credential-expiry: no inventory at $FILE (nothing to check)"
  exit 0
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "check-credential-expiry: yq not found; cannot parse inventory" >&2
  exit 2
fi

now_epoch=$(date +%s)
due=0          # 1 if any WARN/CRIT/EXPIRED found (gates --strict)
needs_meta=0

# Emit: id<TAB>expires for every credentials[] entry. yq prints "null" for a
# missing key, which we treat as unknown.
while IFS=$'\t' read -r id expires; do
  [[ -z "$id" ]] && continue

  case "$expires" in
    n/a|never|null|"")
      # No fixed expiry by design (OAuth token, age key, SSH agent identity).
      continue ;;
    unknown)
      echo "NEEDS-METADATA: $id (expires: unknown — record the date)"
      needs_meta=1
      continue ;;
  esac

  if ! exp_epoch=$(date -d "$expires" +%s 2>/dev/null); then
    echo "NEEDS-METADATA: $id (unparseable expires: '$expires')"
    needs_meta=1
    continue
  fi

  days_left=$(( (exp_epoch - now_epoch) / 86400 ))

  if (( days_left < 0 )); then
    echo "EXPIRED ($(( -days_left ))d ago): $id — rotate now"
    due=1
  elif (( days_left <= CRIT_DAYS )); then
    echo "CRITICAL (${days_left}d left): $id — rotate this week"
    due=1
  elif (( days_left <= WARN_DAYS )); then
    echo "WARN (${days_left}d left): $id — schedule rotation"
    due=1
  fi
done < <(yq -r '.credentials[]? | [.id, (.expires // "unknown")] | @tsv' "$FILE")

if (( due == 0 && needs_meta == 0 )); then
  echo "check-credential-expiry: all tracked credentials outside the ${WARN_DAYS}d window."
fi

if (( STRICT == 1 && due == 1 )); then
  echo "check-credential-expiry: credentials due for rotation (--strict)" >&2
  exit 1
fi

exit 0
