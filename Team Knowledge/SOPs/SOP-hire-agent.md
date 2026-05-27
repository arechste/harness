# SOP-hire-agent — Add a new callsign to the team

**Owner:** SCOUT. **Triggers:** an `[[SOP-route-task]]` invocation finds no matching callsign for the required expertise.

## Purpose

Author a new agent contract, register it, and (for active tools) generate the shim — without disturbing existing routing.

## When to call

- A new expertise gap surfaced by routing
- Principal-led scope expansion (new domain like browser, network, homelab)
- An existing callsign is overloaded and a domain should split

## Inputs

- The triggering task or scope brief
- `[[Templates/agent-contract.template.md]]`
- Current `[[agent-index]]`

## Steps

1. Propose a callsign + animal + role (3-7 letter callsign, evocative; animal evokes the role).
2. Copy `[[Templates/agent-contract.template.md]]` to `Team/<CALLSIGN> - <Role>/AGENTS.md` and fill it in (Identity, When to call, Inputs, Outputs, SOPs, Escalate to).
3. Add a row to `[[agent-index]]` with expertise tags. Update workstream mappings if relevant.
4. File a task assigned to RELAY: `[[SOP-generate-claude-shim]]` (when authored) for the new callsign — generates `adapters/claude/agents/<callsign>.md`.
5. If the original triggering task is still in `tasks/open/`, re-run `[[SOP-route-task]]` — it should now match.
6. Commit: `feat(team): hire <CALLSIGN> (<role>)`.

## Worked example

TBD (Phase 2).

## Common mistakes

- Creating a callsign that overlaps an existing one. Prefer expanding an existing contract or splitting it cleanly.
- Forgetting to update workstream mappings — the new agent will never be called.
