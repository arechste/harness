---
form: reference
last-verified: 2026-05-30
owner: QUILL
status: authoritative
---

# Architectural Decision Records (ADRs)

One decision per file, MADR 4.0.0 abbreviated format. Format and conventions in `[[GL-003-doc-authoring]]`.

| # | Title | Status | Date | Supersedes | Superseded by |
|---|---|---|---|---|---|
| [0001](0001-doc-system.md) | Doc system — Diátaxis · C4 · MADR · Mermaid | accepted | 2026-05-30 | — | — |
| [0002](0002-supply-chain.md) | Supply-chain & dependency posture | accepted | 2026-05-31 | — | — |

---

## Conventions

- Filename: `NNNN-kebab-slug.md`, monotonic numbering, never reused.
- Status: `proposed → accepted → superseded` (or `rejected`, `deprecated`). Bidirectional supersede links — old ADR notes the new one; new ADR cites the old one.
- New ADRs added to this table on accept. Status changes update the table.
