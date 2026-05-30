# WS-001 — dotfiles

**Repo:** `arechste/dotfiles` (at `~/airepos/common/dotfiles/`)
**Distribution:** chezmoi to all fleet machines
**Primary agents:** FORGE (RANGER folded into FORGE 2026-05-30)

## Goal

Maintain the shell + system config layer (Brewfile, mise.toml, zsh rc, ghostty, starship, etc.) deployed via chezmoi to every Claude-using machine.

## Active tasks

See `state/delegations/open/dotfiles-*.md`.

## Phase notes

- Phase 5a: PORT a small set of cross-cutting rule-doc files into harness (see Phase-0-audit § dotfiles PORT list — ~17 items, mostly cross-stack ADRs and security/permissions reference).
- Phase 5b: slim distribution to fleet via chezmoi.
- Otherwise unchanged — this is the most stable of the 5 product repos.

## Conventions in force (Phase 2 wiring)

- `[[GL-NNN-cross-project-architecture]]`
- `[[GL-NNN-secrets-conventions]]`
- `[[GL-NNN-per-project-secrets]]`
