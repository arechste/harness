# Session log — 2026-05-28 23:22 — subagent-spec audit + reference

**Identity:** TOWER (dispatched RECON for the research + reference authoring).

Continuation of the same working session as `[[2026-05-28-22-43_wikilink-audit-placeholder-hygiene]]`; this log covers the subagent-spec thread that followed.

## Worked on

- Dispatched RECON to confirm the current Claude Code subagent definition spec from canonical docs. Confirmed (Tier 1, fetched 2026-05-28): `name` + `description` required; `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt` optional.
- Cross-checked our 12 shims (verified directly via frontmatter-key extraction): they use only `name`/`description`/`tools` — fully spec-compliant. `tower.md` correctly absent (TOWER is the main-session identity, not a subagent).
- Dispatched RECON again to file a durable reference at `[[claude-code-subagent-spec]]` (`Principal/Reference/`). Committed it.
- Principal acted on RECON's `model` advisory (commit `bc369fa`, from `merktnix`): set `CLAUDE_CODE_SUBAGENT_MODEL=sonnet` in `.claude/settings.json` so dispatched subagents default to sonnet while TOWER stays on opus.
- Librarian pass caught SSOT drift this introduced — the just-filed reference said subagents "default to `inherit`". Fixed the "Harness fit" note in place to reflect the sonnet env default.

## Decisions

- **Fresh RECON dispatch, not a resume.** `SendMessage` (the documented way to continue a subagent with its context) is not available in this environment, so the reference-authoring dispatch was a new RECON with the confirmed findings embedded in the prompt — same result, no re-research.
- **Committed the reference but did not push it** — principal said "commit it" (not push), and `[[GL-001-commit-autonomy]]` gates harness-`main` pushes on a close-session log entry existing for the change. Principal's own push of `bc369fa` + rebase replayed my commit (`987eaf4` → `0a34c44`) and synced everything to origin before this close-session.
- **Model axis = reasoning demand, not read/write** (per `bc369fa` rationale): heavy reasoning lives in TOWER's main session; bounded dispatched work is fine on sonnet. Global env is the 80/20 lever; per-shim `model:` stays as an exception mechanism.

## Realignments

- None — principal's `bc369fa` aligned with RECON's recommendation rather than overriding it.

## Insights

- **Resuming a subagent isn't possible here.** To carry a prior subagent's context forward, spawn a fresh one with the findings embedded in the prompt. Likely recurring whenever multi-step delegation to the same callsign is needed across turns.
- **Cross-machine collaboration is live.** Principal committed from `merktnix` while this session ran on `fragtnix`; the local commit was replayed on top via rebase (`pull.ff=only` is set, so this was a clean fast-forward + replay, not a merge). Expect origin to move under us between turns — re-check `git status` before assuming local state.
- **Graduation candidate (surfaced, not filed):** the subagent model-tiering decision (subagents→sonnet, TOWER→opus, axis = reasoning demand) is now a permanent design rule encoded in `.claude/settings.json`. Its rationale currently lives only in `bc369fa`'s commit message — a candidate to graduate into a Guideline or `Principal/Journal/` entry so it's discoverable.

## Open threads

- `[[wikilink-port-backlog]]` — still open, Phase 2 (27 SOPs + 14 GL-NNN Guidelines).
- 3 out-of-scope illustrative wikilink stragglers (`ADAPTER-PROMPT.md`, `docs/transformation/round-0.md`) still await a principal decision.

## Next likely move

Optionally graduate the model-tiering rationale into a Guideline/Journal entry; otherwise Phase-2 backlog work.

## Wikilinks

- `[[SOP-close-session]]`, `[[GL-001-commit-autonomy]]`, `[[agent-index]]`
- `[[claude-code-subagent-spec]]` (the reference filed this thread)
- Prior log, same session: `[[2026-05-28-22-43_wikilink-audit-placeholder-hygiene]]`
