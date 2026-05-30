# 6. Sessions and tasks

How the discuss → plan → deliver → ship loop runs day-to-day.

## A session

A "session" is one conversation with TOWER (and the callsigns TOWER pulls in). Each session has the same arc:

1. **Boot.** TOWER reads `AGENTS.md`, `Team/agent-index.md`, `tasks/open/`, `tasks/in-progress/`, `PKM/.user.yaml`. Picks up anything still in flight.
2. **Discuss + plan.** You bring a goal or topic; we plan and spec it. The plan is a Deliverable for anything substantial; for small work, just a paragraph of agreed approach.
3. **Approve.** You approve (or reshape). For work covered by the [[05-the-autonomy-contract|autonomy contract]] standing approvals, the team proceeds without per-step prompts.
4. **Deliver.** The team executes: writes code/docs/configs, runs commands, dispatches subagents. Granular commits along the way (one logical change each, so any can be cleanly reverted).
5. **Ship.** Where the change needs to reach the fleet, the team ships it (chezmoi sync, plugin marketplace push, manual deploy — depending on the artifact).
6. **Close.** `[[SOP-close-session]]` runs: session log written, in-progress tasks updated, durable insights graduated to `Journal/` or `Reference/`, the inbox swept if needed.

## A task

A task is a unit of work that may outlive a session. It lives as a file:

- `Team Knowledge/tasks/open/<slug>.md` — filed but not started
- `Team Knowledge/tasks/in-progress/<slug>.md` — claimed by a callsign, work underway
- `Team Knowledge/tasks/done/<YYYY>/<MM>/<slug>.md` — finished
- `Team Knowledge/tasks/cancelled/<YYYY>/<MM>/<slug>.md` — dropped (with reason)

Each has frontmatter (id, priority, required-expertise, assignee, links, …) and is the *resumption point* if a session ends mid-work. Lifecycle = folder moves, atomic via `git mv`. The lifecycle SOPs (`SOP-route-task`, `SOP-claim-task`, `SOP-handoff-task`, `SOP-close-task`, `SOP-escalate-blocked`) are in `Team Knowledge/SOPs/`.

## What you typically do vs. what the team does

| You | The team |
|---|---|
| Set goals; bring topics | Picks the right callsigns, plans the approach |
| Approve plans, deliverables, autonomy-contract entries | Executes within the autonomy bounds; asks at the boundaries |
| Review at session close (or whenever you want) | Writes the session log + graduates durable insights |
| Tell us what to keep, drop, or reshape | Tunes the SOPs to match your feedback |
| Drop raw inputs in `Team Inbox/` | Files them per `[[SOP-process-inbox]]` |

## When something feels wrong

Say so. Three things are explicit pushback channels:

- "Don't do that" — durable rule, the team writes a feedback memory and adjusts behavior next session and beyond.
- "Strike entry Pn from the autonomy contract" — immediate revoke.
- "Stop and explain" — interrupts whatever the team is doing; we play back understanding before continuing.
