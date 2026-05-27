# WS-routing — TOWER routing matrix

**Status:** Phase 1 stub. Phase 2 absorbs three `command-map.yaml` sources into this file (see Phase-0-audit § "Cross-repo observations" item 1).

## Purpose

When a task or invocation arrives, this file (together with `[[agent-index]]`) determines which callsign handles it. It is the most-frequently-read non-SOP file in the harness.

## Routing axes

1. **Required expertise** — primary axis. Task frontmatter `required-expertise: [tag, tag]`. Mapped via `[[agent-index]]`.
2. **Workstream** — if the task is part of an active workstream, prefer the workstream's primary agents (see agent-index § "Workstream → agents").
3. **Slash command (Claude Code only)** — `/dc:<name>` invocations route through `adapters/claude/skills/<name>.md` shims, which point at SOPs.

## Sources to merge in Phase 2

- `aitools-common/data/command-map.yaml` — `/dc:` command → skill mapping
- `dotclaude/data/command-map.yaml` — user-scope command map
- `git-organizer/data/command-map.yaml` — fleet-canonical command map (likely SSOT per R0-Q10)

Per Phase-0-audit, **git-organizer is canonical**; the other two are mirrors that get deleted in Phase 5a. Migration steps for Phase 2: read all three, diff, fold deltas into this file, then DROP the duplicates.

## Current direct mappings (manual, until Phase 2 migration)

| Trigger | Skill / SOP | Callsign |
|---|---|---|
| Unassigned task in `tasks/open/` | `[[SOP-route-task]]` | TOWER |
| New expertise gap | `[[SOP-hire-agent]]` | SCOUT |
| Cross-repo work request | `[[SOP-file-delegation]]` | CASCADE |
| Fleet machine cutover | `[[SOP-cutover-machine]]` | RANGER |
