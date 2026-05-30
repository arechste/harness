# SOP-cutover-machine — Deploy slimmed harness/dotfiles/dotclaude to a fleet machine

**Owner:** FORGE (RANGER folded in 2026-05-30). **Triggers:** Phase 5b — a non-workshop machine is being moved to the post-Phase-5a thin regime.

## Purpose

Each non-workshop machine pulls the slimmed `dotfiles` + `dotclaude` (and refreshed `aitools-common` plugin) that resulted from Phase 5a. Harness itself is NOT cloned on these machines — they consume the *outputs* of harness via existing distribution mechanisms.

## When to call

- Phase 5b cutover per machine, in order: tutnix (or a container) first, then machtnix, CR61790DFV, merktnix
- A re-cutover after a regression in the slim regime

## Inputs

- Target hostname
- Confirmed: Phase 5a merged on the relevant product repos
- `state/inventory/<host>.md` (current state) + `state/machines/<host>.md` (pending work)

## Steps

1. On the target machine, pull latest `dotfiles` and `dotclaude` (chezmoi source repos).
2. `chezmoi diff` — review what would change. Confirm no surprises.
3. `chezmoi apply` — deploy the slim configs.
4. In a fresh Claude session on the target, `/plugin update aitools-common` (or equivalent) — refresh the plugin from the marketplace.
5. Smoke test: run 1-2 common SOPs (e.g., `/dc:commit`, `/dc:work`) — confirm shims resolve, hooks fire, no missing-file errors.
6. Update `state/inventory/<host>.md` with the new versions and a `cutover:` event.
7. Commit (on the workshop): `chore(fleet): cutover <host> to slim regime`.

## Rollback

If smoke fails: `chezmoi apply --revert` to the previous version on the target machine, file a `state/delegations/` issue tagged `regression`.

## Worked example

TBD (Phase 5b).

## Common mistakes

- Skipping the diff. Always review what's about to change on a fleet machine.
- Cutting over multiple machines in parallel. Serialize — easier rollback if the first one reveals a problem.
