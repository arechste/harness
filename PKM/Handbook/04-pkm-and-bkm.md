# 4. PKM and BKM — where everything lives

Harness has two long-term wikis, plus a few specialized surfaces. Knowing which is which means you never have to wonder where a fact belongs.

## The two wikis

| | **PKM** (`PKM/`) | **BKM** (`Team Knowledge/`) |
|---|---|---|
| **Whose** | The principal's — yours | The team's — shared |
| **Holds** | Personal long-term knowledge: identity, goals, life concepts, journal, CRM, documents, images, references | Durable team operating knowledge: SOPs, Guidelines, Workstreams, Templates, tasks, session-logs |
| **Authority** | You own final content; team helps with capture & connective tissue | The team owns it (with your approval for substantive change) |
| **Examples** | "What are my goals this quarter?" "Who is X?" "Where is my passport stored?" | "How does the team route a task?" "What's the commit-trailer convention?" "What's the inventory schema?" |

> *Naming note:* "BKM" (Best-Known Method) is the concept; `Team Knowledge/` is the folder name we use, inherited from myPKA. They're the same thing.

## The other surfaces

| Folder | Purpose | Lifecycle |
|---|---|---|
| `Team Inbox/` | Raw intake — you drop, team files | Transient (filed → removed) |
| `Deliverables/` | Team-produced briefs & proposals you review | Working; graduates into PKM/Team Knowledge when ratified |
| `state/` | Operational state (delegations, inventory, machine baselines, credentials) | Live, mutable |
| `docs/decisions/` | ADRs (architectural decisions, 030+) | Append-only history |
| `docs/architecture/` | Living system documentation | Maintained by QUILL · TOWER (librarian-pass) |
| `docs/transformation/` | One-time migration archive (round-0, Phase-0-audit) | Frozen after Phase 5 |
| `adapters/` | Tool-specific shims (Claude today; cursor/gemini later) | Regenerated, not authored |
| `repos/` | Gitignored clones of the 5 product repos | Read-only during Phase 2 freeze |
| `bootstrap/`, `ci/` | Install + validation infra | Maintained by FORGE + LATTICE |

## SSOT rule

If a fact appears in two places, **one is the source of truth and the other links to it**.

- In PKM: the concept folder file (e.g., `My Life/Topics/foo.md`) is canonical; the Journal entry links to it via `[[wikilinks]]`.
- In BKM: the SOP/Guideline is canonical; tasks and session-logs link to it.
- Across folders: PKM owns *personal* facts; Team Knowledge owns *team* facts; state owns *operational* facts. If a thing crosses (e.g., your machines), `PKM/Machines/` holds your principal-facing notes; `state/inventory/` holds the operational inventory; they're explicitly different views of the same machine.
