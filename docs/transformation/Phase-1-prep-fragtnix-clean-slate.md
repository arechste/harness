# Phase 1 Prep: Fragtnix Clean-Slate Procedure

**Purpose:** Make fragtnix a virgin Claude installation before harness scaffolding begins there. Removes the currently chezmoi-deployed `~/.claude/` regime (rules, memories, U-tier skills) and any local clones of `dotclaude` / `aitools-common`, so that when `ADAPTER-PROMPT.md` is pasted into a fresh Claude session on fragtnix, harness can establish its own scaffold from scratch without interference.

**Status:** Executed on fragtnix 2026-05-27. Procedure validated end-to-end. Real-world findings added inline below — keep this document up-to-date for future workshop migrations or re-cutovers.

**Prerequisite:** User is physically near fragtnix (or has a working SSH path that can authenticate 1P signing if needed). Each destructive step requires explicit user approval — the agent must NOT execute these in autonomous mode.

**Rollback property:** Every removal in this procedure is reversible — `chezmoi apply` re-deploys `~/.claude/`; `git clone` restores the dotclaude / aitools-common clones; the pre-removal tarball is the safety net.

---

## Real-world findings (2026-05-27 execution on fragtnix)

Three things to know that weren't obvious before running the procedure:

1. **`~/.ssh/id_ed25519.pub` gap.** chezmoi was *not* the canonical source of this file — it's deployed by some other path (likely an out-of-band one-time write). After wiping `~/.claude/` and skipping `chezmoi apply`, the pubkey file was missing, breaking `op-ssh-sign` for git commits. Symptom: `error: 1Password: agent returned an error / fatal: failed to write commit object`. Fix: `git config --get user.signingkey > ~/.ssh/id_ed25519.pub && chmod 644 ~/.ssh/id_ed25519.pub` — the full pubkey is stored inline in `~/.gitconfig` as `user.signingkey`. `bootstrap/setup-host.sh` automates this restoration; alternatively, harness ships `.gitconfig` setting `commit.gpgsign=false` for team commits, which avoids the need entirely on the team-work path.

2. **`enabledPlugins: {}` is the expected baseline post-wipe.** `~/.claude.json` regenerates on first Claude Code launch with no plugins enabled. The directory `~/.claude/plugins/` still appears (plugin infra files, marketplace cache), but it's empty of active plugins. This is correct — don't be tempted to manually install aitools-common; harness has its own adapter layer.

3. **`chezmoi source-path` falls back to `~/.local/share/chezmoi`** when `~/.config/chezmoi/` is wiped. That default path *does not exist* on a chezmoi-free fragtnix, so accidentally running `chezmoi apply` errors out. Harmless — no rogue deployment risk. If you ever want to fully re-init chezmoi for Phase 5b cutover, you'll run `chezmoi init --source ~/airepos/common/dotfiles` explicitly.

A fourth finding worth noting: **Claude Desktop was NOT installed on fragtnix** (probed in Step 1). The original procedure assumed it might be; on fragtnix specifically, Step 5 is a no-op. The probe in Step 1 tells you definitively per machine.

5. **DO NOT run `chezmoi apply` on fragtnix after the wipe.** The `dotfiles` source repo is still on disk at `~/airepos/common/dotfiles/` (re-cloned in Step 8 so it's available for editing during Phase 2-5). But the chezmoi binary, installed via brew, will happily re-deploy the full regime if you run `chezmoi init --source ~/airepos/common/dotfiles && chezmoi apply` (or even just `chezmoi apply` after a stray `chezmoi init`).

   We hit this during the first smoke-test run: a manual `chezmoi apply` restored all 8 symlinks under `~/.claude/` pointing at `dotclaude/home/*`, plus settings.json. Result: the legacy U-tier skills (which carry `name: dc:<skill>` in their frontmatter) reappeared in Claude Code's autocomplete alongside harness's 9 SOPs, breaking the "virgin harness workshop" property. The fix was to re-wipe ~/.claude symlinks + settings.json + ~/.config/chezmoi.

   **Until Phase 5b cuts fragtnix over to the slim regime, fragtnix must stay chezmoi-quiet.** If you need to edit dotfiles or dotclaude during Phase 2-4, edit the source repos at `~/airepos/common/{dotfiles,dotclaude}/` and commit/push — *do not apply locally*. Phase 5b will re-init chezmoi with the slimmed source.

   If you suspect chezmoi has been applied (symlinks under `~/.claude/` pointing at `dotclaude/home/*`, or `~/.config/chezmoi/` populated), re-run a partial wipe: remove just the chezmoi-deployed symlinks (keeping `~/.claude/.credentials.json` and Claude Code's own session state), then re-run `bash bootstrap/setup-host.sh` to restore harness's `.claude/{agents,commands}/` symlinks.

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

## Step 8 — Clone harness and run bootstrap

```bash
mkdir -p ~/airepos/common
cd ~/airepos/common
git clone https://github.com/arechste/dotfiles.git    # source-only, NOT chezmoi-applied
git clone https://github.com/arechste/dotclaude.git   # source-only, NOT chezmoi-applied
git clone https://github.com/arechste/harness.git
cd harness
bash bootstrap/install.sh
```

`install.sh` clones the 5 product repos under `harness/repos/` (gitignored). It is idempotent.

## Step 9 — Wire harness into the host (one-time per workshop)

```bash
bash bootstrap/setup-host.sh
```

`setup-host.sh` is idempotent and does three things:

1. **Restores `~/.ssh/id_ed25519.pub`** from `git config --get user.signingkey` if missing — fixes the post-wipe 1P-signing gap.
2. **Appends a portable `[includeIf]` block** to `~/.gitconfig` so that running git inside `~/airepos/common/harness/` picks up `harness/.gitconfig` automatically. The committed `harness/.gitconfig` sets `commit.gpgsign = false` so the team can commit on feature branches without 1P prompts. Your principal-scope `~/.gitconfig` is unchanged — outside-harness commits still sign normally.
3. **Probes 1P CLI auth** and reports whether the `harness-team` vault is reachable. If the vault doesn't exist yet, prints a one-liner to create it; if `op` isn't signed in, prints the signin command.

After this, `git commit` from inside harness/ no longer triggers 1P. Commits to other repos (dotfiles, dotclaude, …) still sign per your `~/.gitconfig`.

## Step 10 — Activate harness in Claude Code

```bash
cd ~/airepos/common/harness
claude
# In the first message of the new session, paste the full content of ADAPTER-PROMPT.md
```

The fresh Claude session has no `~/.claude/` content to inherit. ADAPTER-PROMPT detects Claude Code, generates `harness/CLAUDE.md` (project-scope pointer), 12 subagent shims under `adapters/claude/agents/`, 8 seed command shims under `adapters/claude/commands/`, and adopts TOWER identity.

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
