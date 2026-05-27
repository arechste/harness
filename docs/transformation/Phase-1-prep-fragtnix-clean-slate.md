# Phase 1 Prep: Fragtnix Clean-Slate Procedure

**Purpose:** Make fragtnix a virgin Claude installation before harness scaffolding begins there. Removes the currently chezmoi-deployed `~/.claude/` regime (rules, memories, U-tier skills) and any local clones of `dotclaude` / `aitools-common`, so that when `ADAPTER-PROMPT.md` is pasted into a fresh Claude session on fragtnix, harness can establish its own scaffold from scratch without interference.

**Status:** Not yet executed. Documented here so that when Phase 1 begins on fragtnix, the procedure is ready to run.

**Prerequisite:** User is physically near fragtnix (or has a working SSH path that can authenticate 1P signing if needed). Each destructive step requires explicit user approval — the agent must NOT execute these in autonomous mode.

**Rollback property:** Every removal in this procedure is reversible — `chezmoi apply` re-deploys `~/.claude/`; `git clone` restores the dotclaude / aitools-common clones; the pre-removal tarball is the safety net.

---

## Step 1 — Probe current state

From fragtnix (or via `ssh arechste@fragtnix-1` if doing it remotely):

```bash
# What chezmoi has deployed under ~/.claude/
ls -la ~/.claude/

# Any existing repo clones
ls -la ~/airepos/common/
ls -la ~/airepos/claude/code/ 2>/dev/null

# Per-project trust state, enabled plugins, MCP connectors
cat ~/.claude.json | jq 'keys'

# Active Claude sessions (MUST be empty)
pgrep -af '[c]laude'
```

**Gate:** if `pgrep` returns anything, STOP. Wait for active sessions to end (or kill them after user confirmation).

## Step 2 — Stop chezmoi from re-deploying `~/.claude/`

Two options; pick one:

**Option A (preferred — temporary):** add `.chezmoiignore` entry to skip `home/dot_claude/`:

```bash
cd ~/airepos/common/dotfiles  # or wherever the dotfiles source repo lives
echo "home/dot_claude/" >> .chezmoiignore
```

Commit this on a `transformation/fragtnix-stop-deploy` branch in dotfiles. Do NOT push to main yet — only this branch protects fragtnix; other machines still get `~/.claude/` from main.

**Option B (machine-scoped):** use chezmoi's template gating to conditionally ignore on fragtnix only. More elegant; requires editing `home/.chezmoiignore.tmpl` with a `{{ if eq .chezmoi.hostname "fragtnix" }}home/dot_claude/{{ end }}` block.

**Verify:** `chezmoi apply --dry-run` shows no changes pending under `~/.claude/`.

## Step 3 — Archive `~/.claude/` (safety backup)

```bash
DATE=$(date +%F)
tar -czf ~/claude-pre-harness-backup-${DATE}.tar.gz ~/.claude
ls -lh ~/claude-pre-harness-backup-${DATE}.tar.gz
```

Move the tarball off `~/` if you want extra distance (e.g., `~/Backups/` or an external drive). Retain for ~30 days post-Phase-1.

## Step 4 — Delete `~/.claude/`

```bash
rm -rf ~/.claude
ls ~/.claude 2>/dev/null  # should be empty / no output
```

## Step 5 — Reset `~/.claude.json`

```bash
# Option A: write minimal empty JSON
echo '{}' > ~/.claude.json

# Option B: remove entirely; Claude regenerates on first launch
rm ~/.claude.json
```

**Consequence:** loses per-project trust state on fragtnix. User will re-trust the harness directory once on first Claude launch there.

## Step 6 — Remove regime-supporting clones (but not dotfiles)

```bash
# Remove dotclaude and aitools-common clones from fragtnix
# (re-cloneable from GitHub if ever needed)
rm -rf ~/airepos/common/dotclaude
rm -rf ~/airepos/common/aitools-common

# DO NOT remove dotfiles — chezmoi needs it
ls ~/airepos/common/  # should show dotfiles, possibly others (mac-organizer, git-organizer)
```

If you want to also clean the intermediate-path clones (e.g., `~/airepos/claude/code/dotclaude` from earlier migration eras), remove those too — but only after confirming nothing on fragtnix references them.

## Step 7 — Verify clean state

```bash
# Should produce no output
ls ~/.claude/ 2>/dev/null

# Should be empty object or missing
cat ~/.claude.json 2>/dev/null

# Should show dotfiles intact, no dotclaude/aitools-common
ls ~/airepos/common/

# No active Claude session
pgrep -af '[c]laude'
```

## Step 8 — Proceed to Phase 1 Step 1: clone harness

```bash
git clone https://github.com/arechste/harness.git ~/airepos/common/harness
cd ~/airepos/common/harness
# Paste ADAPTER-PROMPT.md into a fresh Claude session
```

The fresh Claude session has no `~/.claude/` content to inherit. The ADAPTER-PROMPT generates whatever it needs inside `harness/adapters/claude/` (and the corresponding bootstrap-generated `~/.claude/` stubs).

**If anything in the old regime turns out to be needed**, that's exactly the test we want — harness should be able to re-establish it inside `harness/adapters/claude/`. Don't restore from the tarball reflexively; investigate first.

---

## Rollback (if Phase 1 fails)

```bash
# Restore ~/.claude/ from backup
DATE=<the date used in step 3>
tar -xzf ~/claude-pre-harness-backup-${DATE}.tar.gz -C /

# Re-clone the regime repos
git clone https://github.com/arechste/dotclaude.git ~/airepos/common/dotclaude
git clone https://github.com/arechste/aitools-common.git ~/airepos/common/aitools-common

# Restore chezmoi behavior
cd ~/airepos/common/dotfiles
git checkout transformation/fragtnix-stop-deploy
# Revert the .chezmoiignore change OR delete the branch and apply main
git checkout main

# Verify
chezmoi apply
ls ~/.claude/
```

---

## Notes

- This procedure does NOT touch any of the 5 product repos on GitHub. Everything is local-only state on fragtnix.
- This procedure does NOT touch other machines (merktnix, tutnix, machtnix, CR61790DFV). They continue running the existing regime until Phase 5b deploys the slimmed dotfiles + dotclaude to them.
- The `transformation/fragtnix-stop-deploy` branch in dotfiles is fragtnix-specific scaffolding — it should NOT merge to main. After Phase 5a slims dotfiles, this branch can be deleted (the slim version on main is the canonical deployment for all machines).
