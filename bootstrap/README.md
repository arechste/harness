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

## What it does NOT do

- Install any system tools (use `dotfiles` chezmoi-managed Brewfile/mise for that)
- Touch `~/.claude/` (ADAPTER-PROMPT.md handles that when pasted into a fresh Claude session)
- Run on non-workshop machines (those use chezmoi + plugin marketplace; harness is single-machine by design)
