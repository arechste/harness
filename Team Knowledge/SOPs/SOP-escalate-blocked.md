# SOP-escalate-blocked — Mark a task blocked and surface it

**Owner:** the current assignee. **Triggers:** you cannot make progress and the blocker isn't yours to resolve.

## Purpose

Pause work cleanly without losing context. Make the blocker visible so TOWER (or the principal) can unblock it.

## When to call

- Missing input from another agent or the principal
- External dependency (PR review, vendor outage, scheduled time)
- Conflict between two SOPs/Guidelines that needs a higher-level decision

## Inputs

- The task file under `tasks/in-progress/`
- A precise description of the blocker

## Steps

1. Append a `blocked:` event line: what's blocking, who/what unblocks it, expected unblock window.
2. Set frontmatter `status: blocked`, `blocked_at: <ISO ts>`, `blocked_by: <description or callsign>`.
3. Leave the file in `tasks/in-progress/` (not back to `open/`) — it's owned, just paused.
4. Notify TOWER by creating a triage task under `tasks/open/` referencing the blocked task (frontmatter `required-expertise: routing`, `links: [<blocked-task-id>]`).
5. Commit: `chore(task): block <task-id> (<reason>)`.

## Worked example

TBD (Phase 2).

## Common mistakes

- Moving the blocked task back to `open/` — it's still owned. Use the `status: blocked` frontmatter.
- Vague blocker descriptions ("waiting on user"). State *what* you need and *what unblocks*.
