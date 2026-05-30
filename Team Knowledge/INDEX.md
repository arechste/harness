# Team Knowledge — Index

Shared, machine-and-agent-agnostic knowledge. Composed of SOPs (verbs), Guidelines (static reference), Workstreams (named flows), Templates (entity scaffolds), and the live `tasks/` / `session-logs/` directories.

> **This is the team's BKM (Best-Known Methods).** It is the durable team operating knowledge — the counterpart to `PKM/`, which is the principal's personal long-term wiki. See `PKM/Handbook/04-pkm-and-bkm.md` for the full PKM/BKM split.

## SOPs

Seed set (Phase 1):

- `[[SOP-route-task]]` — TOWER assigns incoming tasks
- `[[SOP-claim-task]]` — agent takes ownership via `git mv`
- `[[SOP-handoff-task]]` — pass to next callsign
- `[[SOP-close-task]]` — finalize + journal extraction
- `[[SOP-close-session]]` — wrap the session, log durably, propose graduations
- `[[SOP-escalate-blocked]]` — pause cleanly with TOWER notification
- `[[SOP-hire-agent]]` — SCOUT adds a new callsign
- `[[SOP-file-delegation]]` — CASCADE files GH issue + local mirror
- `[[SOP-cutover-machine]]` — RANGER moves a fleet machine to slim regime
- `[[SOP-process-inbox]]` — TOWER+VAULT file raw intake from `Team Inbox/`

Phase 2 populates the rest from Phase 0 audit PORT items.

## Guidelines

Policy set (Phase 1 — Session A):

- `[[GL-001-commit-autonomy]]` — team commits unsigned on feature branches; principal signs at merge
- `[[GL-002-credential-custody]]` — 1P-canonical + sops-on-disk two-tier model; age key as session bridge
- `[[GL-003-doc-authoring]]` — Diátaxis discipline · MADR ADRs · Mermaid + ASCII diagrams · front-matter contract
- `[[GL-004-release-versioning]]` — SemVer 2.0.0 (floor `0.y.z`) · Keep-a-Changelog 1.1.0 · release-please · cross-repo pinning · 1.0.0 promotion criteria

Phase 2 fills `GL-005`+ from PORTed `dotclaude/home/rules/`, `dotclaude/home/memory/feedback_*`, and split convention docs from `git-organizer`.

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
