# harness

Personal infra assistant for [@arechste](https://github.com/arechste) — a team of AI agents managing the umbrella of personal infrastructure repos.

**Status:** Round 0 design complete. Phase 0 audit not yet started. See [`docs/transformation/round-0.md`](docs/transformation/round-0.md) for the design plan, and the anchor issue in [`arechste/aitools-common`](https://github.com/arechste/aitools-common/issues) titled *chore(arch): personal-infra-assistant transformation* for live tracking.

## What this is

A scaffold inspired by [myICOR/myPKA](https://github.com/myICOR/myPKA) — plain markdown SOPs/Guidelines/Workstreams read at runtime by AI agents via `[[wikilinks]]`. Tool-agnostic at the content layer; tool-specific shims (Claude Code, future Cursor/Gemini) live under `adapters/`.

## The team (planned, not yet built)

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

Not yet built. When ready, the bootstrap will be: clone this repo, paste `ADAPTER-PROMPT.md` into any AI tool as message 1.

## Architecture

The workshop where the team works lives on a single machine at a time (planned primary: fragtnix). Backup via git push to this repo. Outputs land as commits in the 5 product repos (`dotfiles`, `dotclaude`, `git-organizer`, `fleet-organizer`, `aitools-common`) which are distributed to other machines via existing mechanisms (chezmoi, Claude Code plugin marketplace).

## License

[MIT](LICENSE)
