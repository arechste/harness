# WS-002 — dotclaude

**Repo:** `arechste/dotclaude` (at `~/airepos/common/dotclaude/`)
**Distribution:** chezmoi to Claude-using fleet machines
**Primary agents:** RELAY, FORGE

## Goal

Maintain the chezmoi-deployed Claude Code runtime: settings.json.tmpl, hooks, agent definitions, scheduled tasks. Post-Phase-5a target: ~500 lines (down from ~3000) — most rule/memory/skill content moves to harness.

## Active tasks

See `state/delegations/open/dotclaude-*.md`.

## Phase notes

- Phase 1: agents under `home/agents/{implementer,planner}.md` stay KEEP-CLAUDE until Phase 3 regenerates equivalents in `adapters/claude/agents/`.
- Phase 2: PORT `home/rules/`, `home/memory/feedback_*`, `home/memory/source_*`, `home/skills/<U-tier>/` and `.claude/skills/<project>/`.
- Phase 5a: slim source repo, leave chezmoi machinery intact.

## Conventions in force (Phase 2 wiring)

- All `GL-NNN-*` Guidelines PORTed from `dotclaude/home/rules/` (7 files)
- `GL-NNN-feedback-*` Guidelines PORTed from `dotclaude/home/memory/feedback_*`
