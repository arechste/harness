# SOP-close-task — Finalize a completed task

**Owner:** the current assignee. **Triggers:** all task acceptance criteria met.

## Purpose

Move the task to `done/<YYYY>/<MM>/`, write a brief outcome, and extract any durable insight to the appropriate journal.

## When to call

- All acceptance criteria in the task pass
- Linked PRs merged (or explicit no-PR decision recorded)

## Inputs

- The task file under `tasks/in-progress/`
- Output artifacts (commits, PR URLs, files produced)

## Steps

1. Append a `closed:` event line: 1-3 sentences on the outcome, with links.
2. Set frontmatter `status: done`, `closed_at: <ISO ts>`.
3. `git mv Team Knowledge/tasks/in-progress/<task>.md Team Knowledge/tasks/done/$(date +%Y)/$(date +%m)/<task>.md` (mkdir -p the year/month dirs if missing).
4. If the work produced a durable insight (a lesson, a pattern, a non-obvious gotcha worth surfacing later), write a short note to `Principal/Journal/<YYYY>-<MM>-<slug>.md` and link it back from the task's frontmatter `linked_journal_entries:`.
5. Commit: `chore(task): close <task-id>`.

## Worked example

TBD (Phase 2).

## Common mistakes

- Skipping the journal extraction when the work was educational. The whole point of `done/` is "we've learned this and will not re-learn it the hard way."
- Closing while CI is still red on a linked PR.
