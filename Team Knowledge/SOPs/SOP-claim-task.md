# SOP-claim-task — Take ownership of a routed task

**Owner:** any callsign that finds itself assigned. **Triggers:** model wears a callsign and finds matching tasks in `tasks/open/`.

## Purpose

Atomically move a task from `open/` to `in-progress/`, signaling exclusive ownership. Prevents two parallel sessions from working the same task.

## When to call

- Session boot, after `[[SOP-route-task]]` has assigned tasks
- An agent picks up a previously blocked task that's been un-blocked

## Inputs

- The task file under `tasks/open/`
- Your callsign

## Steps

1. Re-read the task to confirm `assignee:` matches your callsign. If not, stop — it's not yours.
2. `git mv Team Knowledge/tasks/open/<task>.md Team Knowledge/tasks/in-progress/<task>.md`
3. Set frontmatter `status: in-progress`, `claimed_at: <ISO ts>`.
4. Commit immediately with message `chore(task): claim <task-id>` so the move is durable.
5. Read all linked artifacts (`links[]`, `linked_sops[]`).
6. Begin execution.

## Race-safety note

`git mv` is atomic per filesystem. If two sessions try to claim the same task, one wins; the other gets `fatal: bad source` on `git mv` (file already moved) and re-runs routing.

## Worked example

TBD (Phase 2).

## Common mistakes

- Forgetting to commit the move — the next session sees the task in two places and races.
- Reading linked artifacts in the wrong order (read the SOP before the data it operates on).
