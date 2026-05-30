---
form: reference
status: accepted
date: 2026-05-30
deciders: principal · TOWER
last-verified: 2026-05-30
---

# ADR-0001 — Doc System: Diátaxis · C4 · MADR · Mermaid

## Context and Problem Statement

Harness needs a documentation system that:
1. Is **tool-agnostic** (no doc generator that ties us to a specific runtime); the agnosticism principle is non-negotiable.
2. Is **principal-friendly**: visual > text, examples > prose, build-during-the-process, verifiably accurate.
3. **Aligns with harness SSOT** — SOPs, Guidelines, Workstreams already exist as folders; the system must map cleanly to them rather than fight them.
4. Defines what stays in the 5 product repos (minimal README + CHANGELOG + RELEASE notes + issue/PR history) vs. what moves to harness (all governance).
5. Catches drift early — broken links, stale guidance, unparsable diagrams — without dragging in heavy infrastructure.

The principal asked TOWER to research first, work out a plan, then transform existing repo content into the new standards. Three deliverables drove this ADR: `2026-05-30-doc-system-research.md` (RECON), `2026-05-30-doc-system-plan.md` (TOWER synthesis), and `2026-05-30-framework-explainer.md` (rationale, principal teaching).

## Considered Options

- **A. Diátaxis + C4 (L1/L2) + MADR abbreviated + Standard-Readme + Keep-a-Changelog + SemVer 0.y.z + Conventional Commits + Mermaid (primary) + ASCII + lychee/mmdc/freshness CI** — this proposal.
- **B. No framework — "just write docs"** — ad-hoc, status quo of many of the product repos today.
- **C. arc42 (12 enterprise sections) + UML diagrams + Nygard ADRs** — the enterprise-architecture stack.
- **D. Doc-generator stack** — mkdocs-material or docusaurus with built-in conventions, separate build target, deployed site.

## Decision Outcome

**Chosen: Option A** — the layered, lightweight, GitHub-native stack codified in `[[GL-003-doc-authoring]]`.

Specifically:
- **Diátaxis** discipline (4 forms, never mixed; declared via front-matter `form:`).
- **C4 model**, levels 1 (Context) + 2 (Container) only.
- **MADR 4.0.0 abbreviated** (drop RACI; keep Context + Problem Statement, Considered Options, Decision Outcome, Pros/Cons). One ADR per file at `docs/decisions/NNNN-title.md`.
- **Standard-Readme minimal** template for the 5 product repos (≤80 lines: title + 1-liner + Install + Usage + pointer to harness Handbook + license).
- **Keep-a-Changelog 1.1.0** with `release-please` automation.
- **SemVer 2.0.0** with floor `0.y.z` until interface stable (see `[[GL-004-release-versioning]]` for the discipline).
- **Conventional Commits 1.0.0** (already in use, verified current).
- **Mermaid** as primary diagram tool (renders natively in GitHub); **ASCII** for folder trees and simple sketches; **D2 / diagrams.net / excalidraw** as escape hatch when a specific diagram is unreadable in Mermaid.
- **CI stack:** lychee (links) + mmdc (Mermaid parse) + front-matter freshness script + existing wikilink-check + existing validate.yml.

Maintenance: QUILL writes; TOWER runs librarian-pass at session close; SENTRY runs weekly drift audit via CI.

## Pros and Cons of the Options

### Option A (chosen)

- ➕ **Tool-agnostic** — markdown only; renders in GitHub, Claude Code, Obsidian, any markdown viewer.
- ➕ **Lightweight** — no doc generator, no build target, no deployment pipeline.
- ➕ **Aligns to existing SSOT** — Diátaxis forms map clean to SOPs/Guidelines/Workstreams.
- ➕ **Each piece is a battle-tested industry standard** (Diátaxis: Canonical/Django/Python; C4: Simon Brown; MADR: ADR community; Keep-a-Changelog: olivierlacan; SemVer/Conventional Commits: broad).
- ➕ **Visual-first via Mermaid** — matches the principal's stated preference.
- ➕ **Automatable** — release-please reads Conventional Commits, writes CHANGELOG, opens Release PRs.
- ➖ **Layered = several conventions to learn at once** — mitigated by `[[GL-003-doc-authoring]]` + this ADR + the explainer.
- ➖ **Mermaid layout for dense diagrams** can be inferior to D2's — accepted; escape hatch covers the few cases.

### Option B — No framework

- ➕ Zero learning curve.
- ➖ The status quo we are explicitly moving away from. Causes "explano-tutorial mush" (a single page mixing tutorial + how-to + reference + explanation), inconsistent READMEs, missing changelogs, decisions lost to chat history.

### Option C — arc42 + UML + Nygard

- ➕ Comprehensive, enterprise-proven.
- ➖ arc42's 12 sections include ~8 designed for enterprise stakeholder communication — wasted for a personal infra orchestrator. UML's learning curve is high; Nygard ADRs lose the option-comparison structure that infra decisions need. The whole stack is over-engineered for our context.

### Option D — Doc generator (mkdocs/docusaurus)

- ➕ Polished output, search, navigation.
- ➖ Adds build infra, dependency management, deploy pipeline, theme maintenance. A separate audience (public-facing site) we don't need. Couples docs to a runtime. Violates the agnosticism principle and the lightweight intent.

## Confirmation

This decision is implemented and observable as of commit `441209f`:

- `[[GL-003-doc-authoring]]` codifies the Diátaxis discipline + diagram/ADR/naming conventions + CI checks.
- `docs/architecture/L1-context.md` and `L2-containers.md` exemplify the C4 + Mermaid stack.
- This ADR (`0001-doc-system.md`) exemplifies the MADR format.
- The CI workflows (lychee, mmdc, freshness) follow in the next commit (step F of the execution sequence).
- The release-versioning discipline lands as `[[GL-004-release-versioning]]` in step E.

Per-repo migration (Standard-Readme + Keep-a-Changelog + release-please) is step G — gated on Phase-2 freeze rules in place.

## More Information

- Research: `Deliverables/2026-05-30-doc-system-research.md` (RECON)
- Plan: `Deliverables/2026-05-30-doc-system-plan.md` (TOWER synthesis)
- Teaching: `Deliverables/2026-05-30-framework-explainer.md` (alternatives weighed, rationale)
- Operating model: `Deliverables/2026-05-29-phase-2-operating-model.md` (the context that justified the doc-system shape)
