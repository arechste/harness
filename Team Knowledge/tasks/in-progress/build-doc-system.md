---
id: build-doc-system
status: in-progress
priority: P1
required-expertise: [documentation, research, knowledge-ops]
assignee: TOWER
filed_by: TOWER
filed_at: 2026-05-30T13:00:00Z
blocks: []
links:
  - Deliverables/2026-05-29-phase-2-operating-model.md
  - PKM/Handbook/INDEX.md
---

# Build the harness documentation system

## Context

Principal directed (2026-05-30) that the doc work proceed in three phases: **research** top-class handbook + system architecture practices, **work out a plan**, **then transform** existing repo content into the new standards. The system must align with harness SSOT (SOPs/Guidelines/Workstreams) and must explicitly define what stays in the product repos (minimal README, CHANGELOG, RELEASE notes, issue/PR history) vs. what moves to harness.

Principal's stated preferences: visual > text; code snippets and examples > prose; build during the process (continuous, not batched); verify accuracy.

## Acceptance criteria

- [ ] Research brief written by RECON to `Deliverables/2026-05-30-doc-system-research.md` covering: Diátaxis / C4 / arc42 / ADRs / README conventions / Keep-a-Changelog / SemVer / Conventional Commits / Mermaid-vs-D2 / living-doc patterns
- [ ] TOWER synthesizes a doc-system **Plan** at `Deliverables/2026-05-30-doc-system-plan.md` covering: harness doc framework, SSOT integration, repo-content migration approach, and explicit repo-doc policy (what stays minimal in each product repo)
- [ ] Principal reviews the plan; ratifies / reshapes
- [ ] Migration plan executed: existing repo docs audited, transformed (kept-as-is / adapted / merged / superseded / dropped per the [[port-no-copy-paste]] discipline), and the new doc structure stood up
- [ ] Repo policy enforced: each product repo trimmed to its agreed minimum (README + CHANGELOG + RELEASE notes per the new policy)
- [ ] Standing doc-maintenance practice in place: QUILL writes, TOWER's librarian-pass at session close, SENTRY runs periodic "doc drift" audit (CI gains: Mermaid-parse + last-verified-date warnings)

## Plan-of-work

1. **RECON research** (dispatched in background). Read-only; cites sources; flags decisions still open vs. clear best-practice.
2. **TOWER synthesis** (this session, after RECON returns). Plan covers framework choice (Diátaxis + C4/arc42 + Mermaid/D2 + Nygard/MADR ADRs), SSOT integration, migration approach, and per-repo doc policy.
3. **Principal review** (this or next session). Ratify / reshape the plan.
4. **Audit existing repo docs** (next session). QUILL/VAULT-style pass over the 5 repos' `docs/`, `README.md`, `CHANGELOG.md`, plus the Phase-0-audit doc-related items. Per-item verdict.
5. **Transform + stand up** (subsequent sessions). Author harness's Handbook + architecture in the new framework; rewrite repo READMEs to the agreed minimal shape; carve obsolete repo docs.
6. **Steady state**: maintenance practice runs every session.

## Event log

- 2026-05-30T13:00:00Z — TOWER filed and claimed. RECON dispatched in background for research brief.
