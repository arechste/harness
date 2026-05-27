# Agent Index — Routing Table

When TOWER (or any orchestrator) reads an incoming task, it matches the task's `required-expertise:` tag against this table to pick the assignee. See `[[SOP-route-task]]`.

| Callsign | Animal | Role | Layer | Expertise tags |
|---|---|---|---|---|
| **TOWER** | Eagle | COO / Orchestrator | Leadership | routing, prioritization, escalation, cross-workstream |
| **SCOUT** | Wolf | Recruiter | Leadership | hiring agents, scope expansion, contract authorship |
| **RECON** | Fox | Researcher | Research | web research, source-tier evaluation, evidence gathering |
| **VAULT** | Elephant | Librarian | Knowledge ops | SSOT custody, wikilinks, taxonomy, dead-link audits |
| **QUILL** | Magpie | Tech Writer | Knowledge ops | doc authoring, README/CHANGELOG, ADRs, narrative |
| **LATTICE** | Spider | Schemar | Knowledge ops | JSON/YAML schemas, frontmatter contracts, validation rules |
| **BRIDGE** | Octopus | Integrator | Integration | MCP servers, forge APIs (GH/GL), connectors |
| **SENTRY** | Mongoose | Auditor | QA | security review, conflict detection, drift detection, dead-link |
| **FORGE** | Beaver | DevOps Engineer | Eng | chezmoi, mise, brew, package management, runtime envs |
| **RANGER** | Border Collie | SysAdmin | Eng | fleet ops, OS configs (macOS/Linux), inventory, machine lifecycle |
| **SPARK** | Raccoon | Developer | Eng | shell, python, automation scripts, CLI tooling |
| **CASCADE** | Salmon | GitOps Engineer | Eng | git, gh, branches, PRs, releases, repo conventions |
| **RELAY** | Chameleon | AI Tooling Engineer | Eng | Claude Code, plugins, adapters, hooks, skill shims |

## Workstream → agents (initial)

| Workstream | Primary agents |
|---|---|
| `[[WS-001-dotfiles]]` | FORGE, RANGER |
| `[[WS-002-dotclaude]]` | RELAY, FORGE |
| `[[WS-003-fleet]]` | RANGER, SENTRY |
| `[[WS-004-git-conventions]]` | CASCADE, VAULT |
| `[[WS-005-aitools-common]]` | RELAY, CASCADE |
| `[[WS-routing]]` | TOWER (with VAULT for index hygiene) |

## Hiring

New roles are added via SCOUT running `[[SOP-hire-agent]]`. Each new entry here pairs with a `Team/<CALLSIGN> - <Role>/AGENTS.md` contract and (for Claude Code) a regenerated shim under `adapters/claude/agents/`.
