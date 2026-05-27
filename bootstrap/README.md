# bootstrap/

Run `install.sh` ONCE on the workshop machine.

## What it does

Clones the 5 product repos under `../repos/` (gitignored per R0-Q6):

- `aitools-common` — Claude plugin (skills + hooks + commands)
- `dotclaude` — chezmoi-deployed Claude runtime config
- `dotfiles` — chezmoi-deployed system/shell config
- `git-organizer` — git/forge conventions authority
- `mac-organizer` — fleet inventory + OS scripts (renamed to `fleet-organizer` in Phase 5a)

After Phase 5a renames mac-organizer → fleet-organizer, update the `REPOS` list in `install.sh`.

## When to run

- First time setting up the workshop on a machine (after a fresh `git clone` of harness itself)
- After a wipe (e.g., Phase 1 Step 0 fragtnix clean-slate)

Idempotent: re-running with existing clones is a no-op.

## After install.sh — wire harness into the host

Run **`setup-host.sh`** once per workshop machine:

```bash
bash bootstrap/setup-host.sh
```

It does three things, all idempotent:

1. Restores `~/.ssh/id_ed25519.pub` from `git config --get user.signingkey` if missing (post-wipe + chezmoi-free hosts lack this; `op-ssh-sign` needs it).
2. Appends a `[includeIf "gitdir:<harness>/"]` block to `~/.gitconfig` so running git inside harness picks up the committed `harness/.gitconfig` (which sets `commit.gpgsign=false` for team commits — see `Team Knowledge/Guidelines/GL-001-commit-autonomy.md`). Outside-harness commits sign normally.
3. Probes 1Password CLI and reports whether the `harness-team` vault exists. Does NOT create the vault — that's a principal step (`op vault create harness-team`).

## What it does NOT do

- Install any system tools (use `dotfiles` chezmoi-managed Brewfile/mise for that)
- Touch `~/.claude/` (ADAPTER-PROMPT.md handles that when pasted into a fresh Claude session)
- Run on non-workshop machines (those use chezmoi + plugin marketplace; harness is single-machine by design)
