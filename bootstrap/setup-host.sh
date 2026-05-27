#!/usr/bin/env bash
# setup-host.sh — wire harness into the host machine (one-time per workshop).
#
# Idempotent — re-runs are safe; each step checks current state first.
#
# Three concerns:
#   1. Restore ~/.ssh/id_ed25519.pub from git's inline user.signingkey if missing
#      (post-wipe + chezmoi-free hosts lack the file; op-ssh-sign needs it).
#   2. Append [includeIf "gitdir:HARNESS_ROOT/"] block to ~/.gitconfig so that
#      running git inside harness picks up harness/.gitconfig automatically.
#   3. Probe 1Password CLI auth and surface whether the harness-team vault is
#      reachable. Does NOT create the vault — that is the principal's job.

set -euo pipefail

HARNESS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GITCONFIG="$HOME/.gitconfig"
PUB_KEY="$HOME/.ssh/id_ed25519.pub"
INCLUDE_BLOCK_MARKER="# harness:gitdir-include"

step() { printf '\n== %s ==\n' "$1"; }
ok()   { printf '  ok    %s\n' "$1"; }
warn() { printf '  warn  %s\n' "$1"; }
todo() { printf '  todo  %s\n' "$1"; }

step "1. SSH pubkey for 1P op-ssh-sign"
if [[ -s "$PUB_KEY" ]]; then
  ok "$PUB_KEY already present ($(wc -c < "$PUB_KEY") bytes)"
else
  inline_key="$(git config --get user.signingkey 2>/dev/null || true)"
  if [[ "$inline_key" == ssh-* ]]; then
    mkdir -p "$(dirname "$PUB_KEY")"
    chmod 700 "$(dirname "$PUB_KEY")"
    printf '%s\n' "$inline_key" > "$PUB_KEY"
    chmod 644 "$PUB_KEY"
    ok "restored $PUB_KEY from git user.signingkey ($(wc -c < "$PUB_KEY") bytes)"
  else
    warn "no inline ssh key in git config — skipping pubkey restore"
    warn "(set user.signingkey to the full 'ssh-ed25519 ...' string if you want auto-restore)"
  fi
fi

step "2. Git includeIf for harness gitdir"
if [[ -f "$GITCONFIG" ]] && grep -Fq "$INCLUDE_BLOCK_MARKER" "$GITCONFIG"; then
  ok "includeIf already present in $GITCONFIG"
else
  cat >> "$GITCONFIG" <<EOF

$INCLUDE_BLOCK_MARKER — auto-included by harness/bootstrap/setup-host.sh
[includeIf "gitdir:$HARNESS_ROOT/"]
    path = $HARNESS_ROOT/.gitconfig
EOF
  ok "appended includeIf block to $GITCONFIG"
fi

# Verify the include actually triggers by reading a known harness key from inside the repo.
inside_signing="$(git -C "$HARNESS_ROOT" config --get commit.gpgsign 2>/dev/null || echo unset)"
if [[ "$inside_signing" == "false" ]]; then
  ok "verified: commit.gpgsign=false inside harness/"
else
  warn "expected commit.gpgsign=false inside harness, got: $inside_signing"
fi

step "3. Wire .claude/{agents,commands} symlinks for Claude Code discovery"
# Claude Code discovers subagents in <project>/.claude/agents/ and slash commands in
# <project>/.claude/commands/. Canonical shims live under adapters/claude/{agents,skills}/
# (SSOT, host-generic naming). This step symlinks them into .claude/ so Claude Code finds
# them. Relative symlinks => portable across workshops. .claude/ is gitignored.

mkdir -p "$HARNESS_ROOT/.claude/agents" "$HARNESS_ROOT/.claude/commands"

agent_written=0; agent_skipped=0
for f in "$HARNESS_ROOT/adapters/claude/agents/"*.md; do
  [[ -e "$f" ]] || continue
  name=$(basename "$f")
  target="$HARNESS_ROOT/.claude/agents/$name"
  if [[ -L "$target" || -e "$target" ]]; then
    agent_skipped=$((agent_skipped+1))
  else
    ln -s "../../adapters/claude/agents/$name" "$target"
    agent_written=$((agent_written+1))
  fi
done
ok ".claude/agents/: $agent_written written, $agent_skipped already present"

cmd_written=0; cmd_skipped=0
for f in "$HARNESS_ROOT/adapters/claude/skills/"*.md; do
  [[ -e "$f" ]] || continue
  name=$(basename "$f")
  target="$HARNESS_ROOT/.claude/commands/$name"
  if [[ -L "$target" || -e "$target" ]]; then
    cmd_skipped=$((cmd_skipped+1))
  else
    ln -s "../../adapters/claude/skills/$name" "$target"
    cmd_written=$((cmd_written+1))
  fi
done
ok ".claude/commands/: $cmd_written written, $cmd_skipped already present"

step "4. 1Password CLI + harness-team vault"
if ! command -v op >/dev/null 2>&1; then
  todo "install 1Password CLI (brew install 1password-cli)"
else
  if op account list 2>/dev/null | grep -q '@'; then
    ok "op is signed in"
    if op vault list 2>/dev/null | awk '{print $NF}' | grep -qx 'harness-team'; then
      ok "'harness-team' vault exists"
    else
      todo "create vault: op vault create harness-team"
      todo "  add a 'github-pat' item (API Credential) via the 1P UI or:"
      todo "    op item create --vault harness-team --category 'API Credential' --title 'github-pat'"
      todo "  add an 'age-key' item (Secure Note) holding the team age secret key value"
    fi
  else
    todo "sign in to 1Password: eval \"\$(op signin)\""
  fi
fi

step "Summary"
echo "harness root: $HARNESS_ROOT"
echo "next: cd $HARNESS_ROOT && claude  (then paste ADAPTER-PROMPT.md if first activation)"
