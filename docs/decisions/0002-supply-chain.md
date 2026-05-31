---
form: reference
status: accepted
date: 2026-05-31
deciders: principal · TOWER
last-verified: 2026-05-31
---

# ADR-0002 — Supply-chain & dependency posture

## Context

`security-standards-track` #4 asked for an initial supply-chain stance. The principal delegated the design ("you decide what is good enough today") but named the real risks precisely, and they are **not** the generic public-OSS provenance concerns:

1. Never use or execute code with **known vulnerabilities**, and never accidentally pull/run code we could have known was problematic.
2. **License & attribution awareness.** harness output is used in a Nutanix PreSales (employment) context and for the shared `ntnxlab.ch` lab. A copyleft creep, an OSS→source-available relicense, or stripped attribution could expose the principal's employer to legal risk. This must be avoided.
3. Avoid dependencies with **problematic owners** (sudden relicensing, abandonment, single-maintainer takeover risk). Prefer standard libraries; vendor a fork only deliberately.

Use is personal infra / homelab / shared lab — not artifacts published for the world to consume.

## Decision

Adopt a **pragmatic, informational tier** sized to that reality. No supply-chain check blocks a merge.

- **Vulnerabilities** — language-native audit (`npm audit` / `pip-audit` / `cargo audit`) plus `grype` over the dependency set, in CI, informational.
- **License & attribution (first-class)** — surface every dependency's license (e.g. `syft` SBOM license fields); **flag non-permissive licenses and any license change on update** as a principal-review event.
- **Owner / health** — keep the GL-005 new-dependency review (maintainer reputation, recency, canonical registry); OpenSSF Scorecard optional/informational.
- **Prefer standard libraries; vendor a fork only with a justification recorded in a PR or ADR.**

**Deferred** (not merited at this tier): SLSA build provenance, SBOM attestation, artifact/tag signing. Revisit only if/when a repo is published for outside consumption.

## Consequences

- Operational rules live in `GL-005-code-of-conduct` (Supply Chain + License pillars + the new operational-tooling section). This ADR records the *why* and the deferral.
- License findings are a flag-and-decide loop, not a gate — keeps flow unblocked while protecting against the legal-risk scenario the principal flagged.
- Non-blocking means a critical CVE warns but does not stop work; acceptable for private use. The escalation trigger is "a repo goes public," at which point provenance/signing get reconsidered.
- CI wiring (audit + grype + license scan) is a follow-up build task; this ADR + GL-005 are authoritative on intent now.

## Related

- GL-005-code-of-conduct · GL-004-release-versioning · ADR INDEX
- Deliverables/2026-05-30-primer-supply-chain.md
