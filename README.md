# harness

Personal infra assistant for [@arechste](https://github.com/arechste) — a team of AI agents managing the umbrella of personal infrastructure repos.

**Status:** Phase 1 scaffolding in progress. Round 0 design + Phase 0 audit committed. Greenfield skeleton (Team/, Team Knowledge/, Principal/, state/, adapters/claude/, bootstrap/, ci/) authored on merktnix; awaits Phase 1 Step 0 (fragtnix clean-slate) before becoming the active workshop. See [`docs/transformation/round-0.md`](docs/transformation/round-0.md), [`docs/transformation/Phase-0-audit.md`](docs/transformation/Phase-0-audit.md), [`docs/transformation/Phase-1-prep-fragtnix-clean-slate.md`](docs/transformation/Phase-1-prep-fragtnix-clean-slate.md). Anchor issue: [`arechste/aitools-common#22`](https://github.com/arechste/aitools-common/issues/22).

## What this is

A scaffold inspired by [myICOR/myPKA](https://github.com/myICOR/myPKA) — plain markdown SOPs/Guidelines/Workstreams read at runtime by AI agents via `[[wikilinks]]`. Tool-agnostic at the content layer; tool-specific shims (Claude Code, future Cursor/Gemini) live under `adapters/`.

## The team (Phase 1 contracts authored as stubs)

| Callsign | Animal | Role |
|---|---|---|
| TOWER | Eagle | COO / Orchestrator |
| SCOUT | Wolf | Recruiter |
| RECON | Fox | Researcher |
| VAULT | Elephant | Librarian |
| QUILL | Magpie | Tech Writer |
| LATTICE | Spider | Schemar |
| BRIDGE | Octopus | Integrator |
| SENTRY | Mongoose | Auditor |
| FORGE | Beaver | DevOps Engineer |
| RANGER | Border Collie | SysAdmin |
| SPARK | Raccoon | Developer |
| CASCADE | Salmon | GitOps Engineer |
| RELAY | Chameleon | AI Tooling Engineer |

## Bootstrap

1. `git clone https://github.com/arechste/harness.git ~/airepos/common/harness && cd ~/airepos/common/harness`
2. `bash bootstrap/install.sh` — clones the 5 product repos under `repos/` (gitignored).
3. Paste `ADAPTER-PROMPT.md` into a fresh AI session opened against this directory.

`ADAPTER-PROMPT.md` is structurally inspired by [myICOR/myPKA](https://github.com/myICOR/myPKA) (CC BY-NC-SA 4.0) — see [`NOTICE.md`](NOTICE.md). The prose is authored fresh for harness; no upstream text is incorporated.

## Architecture

The workshop where the team works lives on a single machine at a time (planned primary: fragtnix). Backup via git push to this repo. Outputs land as commits in the 5 product repos (`dotfiles`, `dotclaude`, `git-organizer`, `fleet-organizer`, `aitools-common`) which are distributed to other machines via existing mechanisms (chezmoi, Claude Code plugin marketplace).

## License & attribution

[MIT](LICENSE). See [`NOTICE.md`](NOTICE.md) for inspirations and attributions (notably myICOR/myPKA as the upstream pattern reference).
