# Agent Index — Routing Table

When TOWER (or any orchestrator) reads an incoming task, it matches the task's `required-expertise:` tag against this table to pick the assignee. See `[[SOP-route-task]]`.

The team is **10 callsigns**: 6 core (myPKA scaffold-aligned) + 4 complementary (harness infrastructure). Same model wears every hat.

## Core 6 — myPKA scaffold

| Callsign | Animal | Role | Layer | Expertise tags |
|---|---|---|---|---|
| **TOWER** | Eagle | COO / Orchestrator (also runs the librarian-pass at session close) | Leadership | routing, prioritization, escalation, cross-workstream, ssot-custody, wikilinks, librarian, indexes |
| **SCOUT** | Wolf | Recruiter | Leadership | hiring agents, scope expansion, contract authorship |
| **RECON** | Fox | Researcher | Research | web research, source-tier evaluation, evidence gathering |
| **QUILL** | Magpie | Tech Writer (+ journal capture) | Knowledge ops | doc authoring, README/CHANGELOG, ADRs, narrative, journal |
| **LATTICE** | Spider | Schemar / Data Architect | Knowledge ops | JSON/YAML schemas, frontmatter contracts, validation rules |
| **SPARK** | Raccoon | Automation Specialist (Developer) | Engineering | shell, python, automation scripts, CLI tooling |

## Complementary 4 — harness infrastructure

| Callsign | Animal | Role | Layer | Expertise tags |
|---|---|---|---|---|
| **FORGE** | Beaver | DevOps + SysAdmin (homedir tooling + fleet/machines) | Engineering | chezmoi, mise, brew, package management, runtime envs, fleet ops, OS configs (macOS/Linux), inventory, machine lifecycle |
| **CASCADE** | Salmon | GitOps + Integrator (git/gh + MCP/forge APIs) | Engineering | git, gh, branches, PRs, releases, repo conventions, MCP servers, forge APIs (GH/GL), connectors |
| **RELAY** | Chameleon | **Adapter Engineer** — the only tool-coupled callsign | Engineering | Claude Code, plugins, adapters, hooks, skill shims, ADAPTER-PROMPT, future cursor/gemini |
| **SENTRY** | Mongoose | Auditor (kept independent for separation of duties) | QA | security review, conflict detection, drift detection, dead-link, contract↔enforcement audit |

## Workstream → primary callsigns

| Workstream | Primary callsigns |
|---|---|
| `[[WS-001-dotfiles]]` | FORGE |
| `[[WS-002-dotclaude]]` | RELAY · FORGE |
| `[[WS-003-fleet]]` | FORGE · SENTRY |
| `[[WS-004-git-conventions]]` | CASCADE · TOWER (librarian-pass) |
| `[[WS-005-aitools-common]]` | RELAY · CASCADE |
| `[[WS-routing]]` | TOWER (with TOWER librarian-pass for index hygiene) |

## What folded where (consolidation 2026-05-30)

Three callsigns from the original 13-roster were consolidated; the responsibilities are preserved as **modes** the absorbing callsign wears:

- **VAULT (Librarian)** → folded into **TOWER**. Librarian-pass runs at session close (`[[SOP-close-session]]`) — wikilink integrity, INDEX freshness, taxonomy drift. Mirrors myPKA's Larry pattern.
- **RANGER (SysAdmin)** → folded into **FORGE**. Mac/Linux scoping convergence (Phase-5a `os:` field) made the split artificial; one callsign for the whole "what the machine is" layer.
- **BRIDGE (Integrator)** → folded into **CASCADE**. MCP/forge-API integration is the same external-API craft as git/gh CLI work.

## Hiring

New roles are added via SCOUT running `[[SOP-hire-agent]]`. Each new entry here pairs with a `Team/<CALLSIGN> - <Role>/AGENTS.md` contract and (for Claude Code) a regenerated shim under `adapters/claude/agents/`.

Future scope (browser, tailscale, homelab, …) ships as **Expansion packs** rather than core callsigns — see `Expansions/README.md`.
