#!/usr/bin/env bash
# install.sh — populate the workshop's nested repo clones.
#
# Run ONCE on the workshop machine (current default: fragtnix; alternate: merktnix).
# Idempotent — re-runs are safe; existing clones are left alone.
#
# This script does NOT install anything system-wide. It only clones the 5 product
# repos under ./repos/ (gitignored per R0-Q6) so harness SOPs can read/write them.
#
# Other (non-workshop) fleet machines do NOT run this — they consume harness OUTPUTS
# via existing distribution (chezmoi for dotfiles/dotclaude, plugin marketplace for
# aitools-common, manual clone for the *-organizer repos if needed).

set -euo pipefail

HARNESS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPOS_DIR="${HARNESS_ROOT}/repos"
GH_OWNER="arechste"

# Repos to clone. Note: still 'mac-organizer' pre-Phase-5a; rename to
# 'fleet-organizer' happens in that phase.
REPOS=(
  "aitools-common"
  "dotclaude"
  "dotfiles"
  "git-organizer"
  "mac-organizer"
)

mkdir -p "${REPOS_DIR}"
cd "${REPOS_DIR}"

for repo in "${REPOS[@]}"; do
  if [[ -d "${repo}/.git" ]]; then
    echo "ok      ${repo}            (already present, skipping)"
    continue
  fi
  if [[ -e "${repo}" ]]; then
    echo "skip    ${repo}            (non-git path exists; leaving alone)"
    continue
  fi
  echo "clone   ${repo}            (https://github.com/${GH_OWNER}/${repo}.git)"
  git clone --depth 1 "https://github.com/${GH_OWNER}/${repo}.git" "${repo}"
done

echo
echo "done. Repos under: ${REPOS_DIR}"
echo "Next: paste ${HARNESS_ROOT}/ADAPTER-PROMPT.md into a fresh Claude session."
