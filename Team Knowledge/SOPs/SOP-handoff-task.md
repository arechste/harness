# SOP-handoff-task — Pass a task to the next callsign

**Owner:** the current assignee. **Triggers:** your portion of the work is done but the task isn't closeable.

## Purpose

Cleanly transfer ownership of an in-progress task to the next agent, preserving context and avoiding accidental re-assignment to yourself.

## When to call

- A workstream stages multiple agents (e.g., RECON researches → QUILL drafts → CASCADE commits)
- You've completed a precondition another agent needs
- You discover the wrong callsign was originally routed

## Inputs

- The task file under `tasks/in-progress/`
- The next callsign to receive it

## Steps

1. Append a `handoff:` event line under the task body: what you did, what's left, links to artifacts you produced.
2. Update frontmatter `assignee: <NEXT-CALLSIGN>`, leave `status: in-progress`.
3. If the task should pause until another event (review, scheduled time), set `status: blocked` and call `[[SOP-escalate-blocked]]` instead.
4. Commit: `chore(task): handoff <task-id> → <NEXT-CALLSIGN>`.

## Worked example

TBD (Phase 2).

## Common mistakes

- Moving the file back to `open/` — don't. `in-progress/` + new assignee is the correct state.
- Truncating context. Future-you (or the next agent) needs to know what you tried and why you stopped.
