# WS-004 — git-conventions

**Repo:** `arechste/git-organizer` (at `~/airepos/common/git-organizer/`)
**Distribution:** consulted on the workshop; conventions enforced on all repos
**Primary agents:** CASCADE, TOWER (librarian-pass) (VAULT folded into TOWER 2026-05-30)

## Goal

Maintain the cross-repo git/forge convention authority: labels, merge lifecycle, PR review tiers, commit format, release pipeline, workspace layout. Post-Phase-5a target: ~35% smaller — orchestration extracts to harness; git/forge depth stays.

## Active tasks

See `state/delegations/open/git-organizer-*.md`.

## Phase notes

- Phase 2: SPLIT each convention doc — extract cross-repo orchestration → harness; retain git/forge depth in git-organizer (see Phase-0-audit § git-organizer SPLIT table — 10 docs SPLIT, ~20 GLs produced).
- Phase 2: PORT label-definitions.json + delegation tracker entries (184 entries → `state/delegations/`).
- Phase 5a: slim repo, keep workflows/, schemas/, actions/.

## Conventions in force (Phase 2 wiring)

- `[[GL-006-commit-format]]`
- `[[GL-NNN-label-taxonomy]]`
- `[[GL-NNN-pr-review-tiers]]`
- `[[GL-NNN-merge-lifecycle]]` (planned)
- `[[GL-NNN-release-versioning]]`
- `[[GL-NNN-workspace-layout]]`
