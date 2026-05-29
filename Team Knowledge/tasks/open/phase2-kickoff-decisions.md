---
id: phase2-kickoff-decisions
status: open
priority: P1
required-expertise: [routing]
assignee: TOWER
filed_by: TOWER
filed_at: 2026-05-29T00:40:00Z
blocks: [wikilink-port-backlog]
links: []
---

# Phase-2 kickoff — pending principal decisions

## Context

Phase 2 (build-then-carve: products UNTOUCHED until Phase 5a) is ready to start, driven by `docs/transformation/Phase-0-audit.md` (the authoritative per-item PORT/KEEP-CLAUDE/DROP/REPO-LOCAL worklist). The team produced a repo-state + issue-management proposal (CASCADE) and an ingest-with-review process (TOWER). Both are summarized in the session log dated 2026-05-29 00:40. **We paused to let the principal decide; this task is the resume point.** Do not start porting until the decisions below are answered.

## Decisions awaiting the principal

**Immediate (unblocks the first action):**
1. Green light to write & commit `state/repo-baselines.yaml` — the 5 product-repo SHAs recorded read-only, no tags on the products. (Approach already approved in principle; the specific file/format awaits the nod.)

**Process (the "show me how the team works" review):**
2. Approve the **ingest-with-review** loop (per-item verdict `keep-as-is | adapt | merge | supersede | drop` + provenance stamp), with **batch-1 fully reviewed by the principal, then calibrate** how light later batches' review can be. Approve or reshape.
3. Harness landing cadence: **batched direct-to-main + close-session logs** (current pattern, what CASCADE's model assumes) vs **feature-branch + PR**. Products always stay PR.

**Deferred (tracked, decide when reached):**
4. The 184-entry delegation/issue migration as **one dedicated triage session** (dedupe by GH-issue-URL across the 4 duplicate `delegated-issues.json` first).
5. git-organizer as **canonical** for the 3 duplicate `command-map.yaml` → `WS-routing.md`.
6. `repo-baselines` validation schema location (`ci/schemas/`) — or defer until Phase-2 CI work.
7. Pinned-plus-advance vs always-pull-latest for the `repos/` clones (CASCADE recommends pinned-plus-advance).
8. **Secrets / credential-autonomy sequencing** — the one genuinely-new design item (R0 never covered it; GL-002 + the ported credential ADRs are raw material). TOWER's lean: tackle right after baseline + first ingest cluster, since approval-friction throttles everything else.

## Principal decisions (2026-05-29)

1. **Baseline:** APPROVED — write `state/repo-baselines.yaml`. (Done this session.)
2. **Ingest-with-review:** APPROVED, reshape-as-we-go — start with the per-item verdict + provenance loop; expect to adjust taxonomy / review depth after batch-1.
3. **Landing cadence:** direct-to-main, **conditioned on granular commits**. Principal's requirement: must be able to revert changes and verify they work as we evolve. TOWER ruling: **one verdict = one atomic conventional commit** (clean `git revert` per item); CI-green + review-before-commit is the gate; feature-branch+PR reserved for genuinely risky/large work (184-issue triage, Phase-5a carve). Products always stay PR.

## Acceptance criteria

- [x] Decisions 1–3 answered; first action (baseline record) taken — `state/repo-baselines.yaml` written 2026-05-29
- [x] Ingest-with-review process ratified (approved, reshape-as-we-go)
- [ ] Deferred items 4–8 each have an owning task or a scheduled point

## Notes

- CASCADE recommends being the **standing owner** of repo-state + issue management.
- Baseline SHAs (perishable) captured in the session log; promote to `state/repo-baselines.yaml` once decision 1 lands.
- This task `blocks` `wikilink-port-backlog` — that earlier backlog is a thin proxy now superseded by `Phase-0-audit.md`; reconcile the two when Phase 2 starts.

## Event log

- 2026-05-29T00:40:00Z — filed by TOWER at session close as the Phase-2 resume point
- 2026-05-29 — principal answered decisions 1–3 (1: approve baseline; 2: approve ingest-with-review, reshape-as-we-go; 3: direct-to-main with granular atomic commits). TOWER wrote `state/repo-baselines.yaml` (SHAs re-verified, unchanged). Deferred items 4–8 still open.
- 2026-05-29 — **method pivot.** During the first ingest attempt (dotclaude `home/rules/`) the principal reframed: PORT is not copy-paste — mine intent, re-author tool-agnostically, transform or drop (see memory `port-no-copy-paste`). Bigger picture: harness becomes the **agnostic operating model + SSOT control plane** governing all domains; repos demote to artifact/distribution stores; organize by domain of expertise not repo-by-repo (see memory `harness-vision`). Principal chose **operating-model-first** and wants the team to *demonstrate understanding* before execution. Deliverable drafted: `docs/transformation/Phase-2-operating-model.md` (PROPOSAL, awaiting review — 6 open questions). The file-by-file Phase-0-audit destinations are downgraded to an inventory; this proposal is the active Phase-2 frame.
