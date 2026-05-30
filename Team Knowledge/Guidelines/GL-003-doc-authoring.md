---
form: reference
last-verified: 2026-05-30
owner: QUILL (authoring); TOWER (librarian-pass); SENTRY (drift audit)
status: authoritative
---

# GL-003 — Doc-Authoring Discipline (Diátaxis · MADR · Mermaid)

**Status:** Authoritative. **Owner:** QUILL (authoring); TOWER (librarian-pass at session close); SENTRY (weekly drift audit).

## Policy

Every doc page in harness serves **exactly one** of the four Diátaxis forms — never mixed. The form is declared in YAML front matter. Mixing forms is the failure mode this guideline exists to prevent.

| Form | What the reader is doing | Page MUST do | Page MUST NOT do |
|---|---|---|---|
| `tutorial` | Learning | Hand-hold a beginner through doing the thing | Be exhaustive; assume prior knowledge |
| `how-to` | Achieving a task | Direct steps for someone who knows what they want | Teach; explain why |
| `reference` | Looking up facts | Scan-friendly, exhaustive, dry | Tell a story; persuade |
| `explanation` | Understanding why | Discursive; concepts, history, trade-offs | Be action-oriented |

## Folder ↔ form mapping

```
Team Knowledge/
  SOPs/                      → how-to       (procedures)
  Guidelines/                → reference    (standing rules)
  Workstreams/               → explanation  (multi-domain flows)
  Templates/                 → reference    (entity scaffolds)

PKM/
  Handbook/                  → mixed (per-page declaration; mostly explanation + how-to)
  Reference/                 → reference
  Journal/                   → explanation (principal's lessons)
  My Life/ · CRM/ · Documents/ → reference

docs/
  architecture/              → explanation (with embedded diagrams)
  decisions/                 → reference   (ADRs; one per file)
  transformation/            → explanation (migration archive)

Deliverables/                → mixed; usually explanation; graduates to canonical surface
```

## Front-matter contract

Every `.md` under the surfaces above declares:

```yaml
---
form: tutorial | how-to | reference | explanation
last-verified: YYYY-MM-DD
owner: <CALLSIGN or principal>
status: draft | authoritative | superseded | archived
---
```

Optional fields per surface: `supersedes:`, `supersededBy:`, `audience:`, `graduates-to:`.

## Diagram conventions

- **Mermaid** — primary tool for in-repo diagrams (flowcharts, sequence, state, ER, C4, mindmap). Renders natively in GitHub. Mermaid blocks live inline in the markdown.
- **ASCII** — for folder trees, simple boxes-and-arrows where Mermaid would be overkill. Zero tooling.
- **D2 / diagrams.net / excalidraw** — *escape hatch* only. Use when a specific diagram is unreadable in Mermaid. Source file (`*.d2` / `*.drawio` / `*.excalidraw`) committed alongside a rendered SVG/PNG in `PKM/Images/YYYY/MM/`, embedded into the markdown via `![[Images/...]]`.
- Architecture diagrams use **C4** vocabulary (L1 Context + L2 Container only; see `docs/architecture/`).

## ADR format

Decisions are recorded as **MADR 4.0.0 abbreviated** (no RACI fields). One decision per file at `docs/decisions/NNNN-kebab-title.md`. Required sections:

1. Context and Problem Statement
2. Considered Options
3. Decision Outcome
4. Pros and Cons of the Options

Status field uses `proposed | accepted | superseded by [ADR-NNNN](...)` with **bidirectional** supersede links. Index at `docs/decisions/INDEX.md`.

See `[[ADR-0001-doc-system]]` as the canonical worked example.

## Naming conventions

| Surface | Convention | Example |
|---|---|---|
| SOPs | `SOP-<verb>-<noun>.md` | `SOP-process-inbox.md` |
| Guidelines | `GL-NNN-<topic>.md` | `GL-003-doc-authoring.md` |
| Workstreams | `WS-NNN-<topic>.md` | `WS-001-dotfiles.md` |
| ADRs | `NNNN-<kebab-slug>.md` | `0001-doc-system.md` |
| Handbook pages | `NN-<kebab-slug>.md` | `01-how-harness-works.md` |
| Deliverables | `YYYY-MM-DD-<kebab-slug>.md` | `2026-05-30-doc-system-plan.md` |
| Templates | `<entity>.template.md` | `repo.template.md` |
| Session logs | `YYYY-MM-DD-HH-MM_<topic>.md` | (already in use) |

All filenames kebab-case. No spaces. ASCII only.

## CI enforcement

| Check | Tool | Trigger | Failure mode |
|---|---|---|---|
| Broken links | lychee | push + weekly | broken `[text](url)` or `[[name]]` |
| Mermaid parse | mmdc | push (PRs) | any Mermaid block fails to render |
| Wikilink integrity | existing wikilink-check | push | `[[name]]` doesn't resolve to a file stem |
| Front-matter schema | existing validate.yml + LATTICE schema | push | missing `form:`, bad date, unknown enum |
| Freshness | freshness script | weekly cron | `last-verified` > 180 days → opens issue |

## Maintenance

- **QUILL** writes new doc content in the right form.
- **TOWER** runs the librarian-pass at session close per `[[SOP-close-session]]`: form discipline, wikilink integrity, INDEX freshness.
- **SENTRY** runs the weekly drift audit via CI.
- **Every commit** that changes structure updates its diagram in the same commit (granular, atomic — established cadence).

## Related

- `[[ADR-0001-doc-system]]` — the founding decision this guideline implements
- `[[GL-001-commit-autonomy]]` — commit cadence for doc changes
- `[[GL-004-release-versioning]]` — release/CHANGELOG discipline
- `[[SOP-close-session]]` — runs the librarian pass
- `Deliverables/2026-05-30-framework-explainer.md` — rationale for these choices
