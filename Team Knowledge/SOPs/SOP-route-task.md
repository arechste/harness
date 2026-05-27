# SOP-route-task — Assign an incoming task to a callsign

**Owner:** TOWER. **Triggers:** unassigned task in `Team Knowledge/tasks/open/`.

## Purpose

Match an incoming task's `required-expertise:` tag(s) against `[[agent-index]]` and set `assignee:`. Do not execute the task — only route it.

## When to call

- Session boot finds tasks in `tasks/open/` with no `assignee:` (or `assignee: unassigned`)
- A blocked task is re-routed after escalation
- A task's expertise tag changed during execution

## Inputs

- The task file (frontmatter `id`, `priority`, `required-expertise[]`, `links[]`)
- `[[agent-index]]`
- Active workstreams (to detect concurrent ownership)

## Steps

1. Read the task file. If `required-expertise:` is missing, file `[[SOP-escalate-blocked]]` against the requester to add it.
2. For each tag, look up the callsign in `[[agent-index]]`. If multiple match, prefer the most specific (e.g., `claude-shim` → RELAY over `eng`).
3. If no callsign matches, hand off to SCOUT (`[[SOP-hire-agent]]`).
4. If a callsign matches, write `assignee: <CALLSIGN>` into the task frontmatter and append a `routing:` event line: `routed by TOWER at <ISO ts>`.
5. Notify the assignee — in single-agent reality, this means: the next time the model wears that callsign's hat, the task will be visible under `tasks/open/` matching `assignee: <CALLSIGN>`.

## Worked example

TBD (Phase 2).

## Common mistakes

- Routing without reading the linked artifacts — caller often hides constraints in the link target.
- Splitting a task across two callsigns. Prefer one assignee + handoffs via `[[SOP-handoff-task]]`.
