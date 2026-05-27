# Team Knowledge — Index

Shared, machine-and-agent-agnostic knowledge. Composed of SOPs (verbs), Guidelines (static reference), Workstreams (named flows), Templates (entity scaffolds), and the live `tasks/` / `session-logs/` directories.

## SOPs

Seed set (Phase 1):

- `[[SOP-route-task]]` — TOWER assigns incoming tasks
- `[[SOP-claim-task]]` — agent takes ownership via `git mv`
- `[[SOP-handoff-task]]` — pass to next callsign
- `[[SOP-close-task]]` — finalize + journal extraction
- `[[SOP-escalate-blocked]]` — pause cleanly with TOWER notification
- `[[SOP-hire-agent]]` — SCOUT adds a new callsign
- `[[SOP-file-delegation]]` — CASCADE files GH issue + local mirror
- `[[SOP-cutover-machine]]` — RANGER moves a fleet machine to slim regime

Phase 2 populates the rest from Phase 0 audit PORT items.

## Guidelines

Empty in Phase 1. Phase 2 fills `GL-NNN-*.md` from PORTed `dotclaude/home/rules/`, `dotclaude/home/memory/feedback_*`, and split convention docs from `git-organizer`.

## Workstreams

- `[[WS-routing]]` — TOWER routing matrix (absorbs three `command-map.yaml` sources in Phase 2)
- `[[WS-001-dotfiles]]`
- `[[WS-002-dotclaude]]`
- `[[WS-003-fleet]]`
- `[[WS-004-git-conventions]]`
- `[[WS-005-aitools-common]]`

## Templates

- `[[Templates/repo.template]]`
- `[[Templates/machine.template]]`
- `[[Templates/plugin.template]]`
- `[[Templates/delegation.template]]`
- `[[Templates/agent-contract.template]]`

## Live state

- `tasks/{open,in-progress,done/<YYYY>/<MM>,cancelled/<YYYY>/<MM>}/`
- `session-logs/` — one file per session, append-only
