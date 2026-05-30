---
form: reference
last-verified: 2026-05-30
owner: QUILL
status: authoritative
---

# docs/architecture — System Architecture (C4)

The living architecture view of harness. Two C4 levels are maintained — the deeper levels (Component, Code) are over-detailed for a markdown-only orchestrator and are intentionally skipped.

## Contents

- [[L1-context]] — System Context. Harness in the wider IT estate: principal, GitHub, 1Password, product repos, fleet.
- [[L2-containers]] — Container view. Inside harness: identity, Team, SSOT, PKM, state, adapters, the rest.

## Conventions

- All diagrams use **Mermaid** (renders natively in GitHub). ASCII for folder trees.
- C4 vocabulary (Context · Container), not formal notation — Mermaid `flowchart` with C4-flavored labels.
- Each page declares `form: explanation` in front matter.
- Significant structural changes update the diagram in the same commit (per `[[GL-003-doc-authoring]]`).

## Decisions behind this structure

- `[[ADR-0001-doc-system]]` — the founding decision: Diátaxis + C4 L1/L2 + MADR + Mermaid.
- `Deliverables/2026-05-29-phase-2-operating-model.md` — the operating model that shaped the L2 containers (harness as agnostic control plane; repos as artifact stores; adapters as the only tool-coupled surface).

## Maintenance

- **QUILL** authors and updates.
- **TOWER** at session close (`[[SOP-close-session]]`) checks that recent structural commits updated the diagrams.
- **SENTRY** runs the weekly drift audit (link health, mermaid parse, last-verified freshness).
