---
id: security-standards-track
status: open
priority: P1
required-expertise: [security, knowledge-ops, gitops]
assignee: TOWER
filed_by: TOWER
filed_at: 2026-05-30T19:00:00Z
blocks: []
links:
  - Deliverables/2026-05-30-signing-and-security-standards.md
  - Deliverables/2026-05-30-primer-commit-traceability.md
  - Deliverables/2026-05-30-primer-supply-chain.md
  - Deliverables/2026-05-30-primer-credential-lifecycle.md
  - Deliverables/2026-05-30-primer-browser-profiles.md
  - state/credentials/INVENTORY.yaml
---

# Security & signing standards — learn → validate → adopt-or-drop

## Context

Opened 2026-05-30 (session 2) out of the SENTRY GL-corpus audit. Principal's frame: build the knowledge **with** them, validate best practice, then decide each standard **adopt-or-drop** — enterprise-grade but pragmatic, security high but never a blocker, private-now/OSS-later. See memories `project_security-posture`, `project_traceability-goal`, `feedback_secret-handling`, `reference_credential-topology`, `reference_secret-scan-hook`, `project_browser-profiles-prereq`.

Roadmap: `Deliverables/2026-05-30-signing-and-security-standards.md`. Three primers filed (commit-traceability, supply-chain, credential-lifecycle) + a browser-profiles primer.

## Decisions awaiting the principal (each: read primer → adopt or drop)

1. **Commit signing model** — primer recommends staying status-quo now → SSH team key once 1P custody confirmed. NB: survey found **SSH signing already configured globally** (1P SSH agent, dedicated `id_ed25519_github_sign_key`); harness overrides to unsigned per GL-001. So team-signing is lighter-lift than assumed. Also: bot GitHub identity? trailer format?
2. **GL-006-commit-format** — adopt a single canonical trailer (resolves dangling `[[GL-NNN-commit-format]]`); principal wants the validated plan, not a pre-picked format. Absorbs Conventional-Commits body/footer rules GL-001 omits.
3. **release-please ↔ Keep-a-Changelog** (audit AUD-009) — mechanically incompatible in GL-004; resolve via release-please `changelog-sections` remap (verify capability) then amend GL-004.
4. **Supply-chain SLSA tier** (GL-005 amend + ADR-0002) — primer rec: Tier 1 now (syft+grype+Scorecard), Tier 2 before any repo goes public.
5. **Credential rotation + break-glass** (GL-002 amend) — 90d default (tuneable 180 low-blast / shorter throwaway later); break-glass = printed 1P Emergency Kit in a safe. Establish handling before expiry.
6. **AI-attribution bridge** (audit AUD-005) — reciprocal cross-link GL-001 ↔ GL-005; ratify.

## In-flight / built this session

- `state/credentials/INVENTORY.yaml` — first credential inventory (secret-free, evidence-based).
- `ci/scripts/check-credential-expiry.sh` — expiry alert (T-14/T-7), reads inventory metadata only; **not yet wired to cron**.

## Acceptance criteria

- [ ] Each decision 1–6 resolved adopt-or-drop with the principal
- [ ] Resulting GL-006 / GL-002,004,005 amendments / ADR-0002 authored (one atomic commit each)
- [ ] PAT inventory completed (BLOCKED on `[[project_browser-profiles-prereq]]`) and `check-credential-expiry.sh` wired to weekly cron
- [ ] Standing cross-consistency gate added to `[[SOP-close-session]]` librarian-pass (so the GL audit runs every session)

## Blockers

- **PAT inventory walk** is gated by browser-profile setup (`project_browser-profiles-prereq`) — work/personal profiles + sync must be configured before Chrome targeting / computer use / browser credential flows.

## Event log

- 2026-05-30T19:00:00Z — filed by TOWER at session close; carries the security/signing track out of build-doc-system so it has its own resume point.
