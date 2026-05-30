---
form: explanation
last-verified: 2026-05-30
owner: TOWER (roadmap); principal (ratification)
status: draft
audience: principal
graduates-to: GL-006-commit-format · GL-002 amendments · GL-005 amendments · ADR-0002 · ADR-0003
---

# Signing & Security Standards — ROADMAP (learn → validate → adopt-or-drop)

**Status:** DRAFT roadmap. Source: SENTRY guidelines-corpus audit (2026-05-30, log `2026/05/2026-05-30-17-00_guidelines-corpus-audit.md`).

This is **not** a decision-forcing brief. Per the principal's direction (2026-05-30), each track runs **learn → validate best-practice → decide together (adopt or deprecate)**. TOWER builds the knowledge and learns alongside the principal; we implement only what we jointly deem suitable, enterprise-grade but pragmatic, security-high but never a blocker. Standards are set now for **private repos today, public/OSS later** — so the jump to public is a non-event.

Governing context (see memory): `project_traceability-goal`, `project_security-posture`, `feedback_secret-handling`.

Already fixed autonomously this session (hygiene, no decision needed): front-matter added to GL-001 & GL-002 (`c2dfcbf`); GL-003 owner-separator normalized; stale GL high-water line corrected (`d9aca61`).

---

## North star

> **Traceability to course-correct** — for any change, the principal can see *who / what / where / why* and intervene. The team is a single committer; the high-value "where" signal is **which callsign handled it** + repo/path. Hostname is now low-value (contributions flow through harness, not per-machine). Any team signing key must remain **available to the team during the principal's absence**.

---

## Track 1 — Commit traceability, trailer & signing

**Goal:** legible course-correction trail; one canonical trailer (kills the 3 drifting templates); decide signing deliberately.

**What we'll learn/validate (RECON):**
- Conventional Commits 1.0.0 full spec (body, `BREAKING CHANGE:`, footers) vs our partial GL-001.
- Git trailer conventions: GitHub-valid `Co-Authored-By: Name <email>` (must match an account to register) vs custom trailers (`Harness-Agent:`) for rich lineage.
- Signing options and the **key-availability-during-absence** constraint:
  - (a) unsigned team + principal-signed squash-merge (status quo),
  - (b) SSH-signed team key (low friction; needs custody that survives principal absence),
  - (c) Sigstore/gitsign keyless (strongest, heaviest).
- How each preserves callsign+scope traceability.

**Output:** plain-language primer + a recommended `GL-006-commit-format` draft for adopt-or-drop. **Validation gate:** confirm the GitHub Co-Author registration behavior and any signing-key custody mechanics before we commit.

## Track 2 — Supply-chain posture (SLSA / OpenSSF / SBOM)

**Goal:** demonstrate a serious posture pragmatically; climb the ladder deliberately as we approach OSS.

**What we'll learn/validate (RECON) — taught in plain terms, no jargon walls:**
- What each acronym actually *means* and *buys*: SLSA build-provenance levels, OpenSSF Scorecard, SBOM (`syft`/CycloneDX), artifact/tag signing, NIST SSDF.
- A staged ladder mapped to **harness's private-now/OSS-later** reality, with honest effort-vs-value per rung — so we pick a tier that's strong but not hassle-theater.

**Output:** a "supply-chain ladder for harness" explainer + a recommended starting tier and a climb schedule → graduates to a GL-005 amendment + ADR-0002.

## Track 3 — Credential lifecycle & safety

**Goal:** **establish handling before anything breaks** — inventory + expiry tracking first, then automate rotation; never leak.

**Hard rules (already set — see `feedback_secret-handling`):** TOWER never sees secret values, never prints them to console/prompt; safe injection only (`sops -d | tool`, `op read > $FILE`); when a human must act, principal gets exact copy-paste manual steps; prefer API/CLI/script automation.

**What we'll build/validate:**
- **Inventory first:** enumerate existing PATs/tokens and their *current* expiries (the principal already has some long-lived PATs to learn about and track) — produce a tracking surface, no values stored.
- **Rotation cadence:** default **90 days (quarter), tuneable** — up to 180 for low-blast-radius creds; explore **short-lived/throwaway** derived creds where a session can mint-and-discard.
- **Automation:** `gh`/`op`/`sops` scripts for expiry reporting and rotation assists, within the no-exposure rule; accurate manual instructions for the irreducibly-human steps.
- **Break-glass:** emergency-access path when 1Password is unavailable (NIST SSDF PO.5 — protect dev environments / privileged-access controls) — principal-held offline backup; medium TBD.

**Output:** credential-handling runbook + GL-002 amendments + future `[[SOP-rotate-credential]]`, `[[SOP-break-glass]]`, `[[SOP-audit-credentials]]`.

## Track 0 — Mechanical fix (no learning needed)

**D4 / AUD-009:** GL-004 mandates both Keep-a-Changelog format *and* release-please, which natively emits Conventional-Commit-type sections. Resolve by configuring release-please `changelog-sections` to remap types→KaC categories. **Validation gate:** confirm the config capability, then amend GL-004. Low-stakes; handle whenever Track 1 touches commit conventions.

---

## Sequencing (proposed)

1. **Now:** RECON produces the three primers (Tracks 1–3) at orientation depth — shared vocabulary first.
2. **Then, together:** read the primers, pick a tier/format per track (adopt-or-drop).
3. **Then:** author the GLs/ADRs/SOPs + build credential tooling — one atomic commit per item.
4. Credential **inventory** can start in parallel now (it's discovery, not a standard) — surfaces what's about to expire before we're forced to react.

Nothing is authored as a standard until we've learned it and decided together.
