---
id: feedback-loop-design
status: open
priority: P2
required-expertise: [gitops, knowledge-ops, fleet]
assignee: unassigned
filed_by: TOWER
filed_at: 2026-05-31T00:00:00Z
blocks: []
links:
  - Team Knowledge/Guidelines/GL-006-commit-format.md
---

# Feedback loop — ship → issue → triage → fix (principal + fleet ↔ harness team)

## Context

Spun out of `security-standards-track` decision #7. The principal reframed "attribution" as the small end of a bigger need: harness ships artifacts (dotfiles, dotclaude, and later git-organizer / fleet-organizer / ntnxlab.ch repos) that the principal and several fleet machines **consume**. There needs to be a clean way for those consumers to **report issues / give feedback**, for the team to **triage**, and for the team to **deliver fixes** — including the case where the team cannot act directly.

The commit `Harness-Agent` trailer (`[[GL-006-commit-format]]`) is the audit side of this: when the team works autonomously, the trailer tells the principal *who/how* a change came to be, so he knows where to direct a hint or a fix request. This task designs the *forward* side.

## What to design

- **Feedback intake** — how an issue is filed against a shipped artifact. Likely the repo's GitHub issues, mirrored into the harness coordination plane (delegations pattern). Define the path from "a machine/principal hits a problem" → a triageable item.
- **Triage + routing** — how the team picks up an issue, assigns a callsign, and decides the fix.
- **Fix delivery, two modes:**
  - **Direct** — the team has remote access (e.g. SSH) to the affected machine and can apply/verify the fix.
  - **Instructed** — the team cannot act (needs `sudo`, interactive auth, physical access); it produces exact copy-paste instructions for the principal/operator to run, then verifies via reported output.
- **Fleet dimension** — the same artifact runs on multiple machines; a fix may need to roll out to N machines. Relationship to `[[WS-003-fleet]]` and the cutover/distribution path.
- **Identity for outside collaborators** — for `ntnxlab.ch` org repos worked on with humans who have no harness access, feedback must be legible without the harness coordination plane.

## Acceptance criteria

- [ ] A short design (Diátaxis explanation) covering intake → triage → fix (both modes) → verify → close
- [ ] Decide the intake surface (GitHub issues + harness mirror, or other) and whether an SOP is needed (`SOP-work-issue` already dangles in the backlog)
- [ ] Define how remote-vs-instructed fix delivery is chosen and recorded
- [ ] Cross-link to GL-006 (audit trailer), WS-003 (fleet), and the delegations pattern

## Event log

- 2026-05-31 — filed by TOWER, spun out of `security-standards-track` #7 (the feedback-loop half of the attribution decision).
