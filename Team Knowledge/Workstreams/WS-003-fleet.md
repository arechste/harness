# WS-003 — fleet (mac-organizer → fleet-organizer)

**Repo:** `arechste/mac-organizer` (at `~/airepos/common/mac-organizer/`) — renamed to `fleet-organizer` in Phase 5a (R0-Q7), with `os:` field for unified Mac/Linux/container scope.
**Distribution:** manual clone on machines that run its tooling
**Primary agents:** RANGER, SENTRY

## Goal

Per-machine inventory, OS-level scripts (launchd/systemd, mirror-backup, Brewfile reconciliation), fleet maintenance runbooks. Post-Phase-5a target: ~25% smaller — orchestration SOPs move out, OS depth stays.

## Active tasks

See `state/delegations/open/{mac,fleet}-organizer-*.md`.

## Phase notes

- Phase 2: PORT 13 top-level docs + 3 standards + 1 research note + 6 cross-machine workflows into harness SOPs/Guidelines (see Phase-0-audit § mac-organizer PORT table).
- Phase 2: DROP 15 convention files duplicated from git-organizer (cleanest single win in the audit).
- Phase 5a: rename + scope expansion + `os:` field added to every inventory entry.
- Phase 5b: cutover per machine via `[[SOP-cutover-machine]]`.

## Conventions in force (Phase 2 wiring)

- `[[GL-NNN-fleet-context]]`
- `[[GL-NNN-agent-permissions]]`
- `[[GL-NNN-wat-framework]]`
