# ADAPTER-PROMPT.md — Tool-agnostic bootstrap

**Status:** STUB. Real fork pending — see TODO below.

Paste the body of this file as message 1 into any AI tool (Claude Code, Cursor, Gemini, ChatGPT, Codex, …) opened against this repo. The prompt detects the tool, generates the right shim layer under `adapters/<tool>/`, and routes the model into TOWER identity by reading `AGENTS.md`.

## Tool-detection branches (planned)

- **Claude Code** — generate `~/.claude/CLAUDE.md` pointer + `adapters/claude/{agents,hooks,skills}/` shims from `Team/`, seed SOPs, and hook scripts.
- **Cursor** — generate `.cursor/rules/*.mdc` from Team/Guidelines, point at `AGENTS.md` for identity.
- **Gemini Code Assist** — generate `.gemini/` config + `GEMINI.md` pointer.
- **ChatGPT (web) / Codex** — emit a copy-paste system prompt fragment derived from `AGENTS.md` + agent-index.

## TODO — Phase 1 follow-up

Fork the upstream from [myICOR/myPKA](https://github.com/myICOR/myPKA/blob/main/ADAPTER-PROMPT.md) (~350 lines, tool-agnostic prose; see round-0 § R0-Q2). Adapt:

- Replace myPKA terminology (PKM → Principal, etc.) per R0-Q3.
- Wire in the 13-callsign roster instead of myPKA's default team.
- Add adapters/claude shim generation routine (Claude Code is the priority tool — `aitools-common` plugin manifest).
- Keep idempotent — re-pasting must be a no-op if shims already match content.

Track this as a `Team Knowledge/tasks/open/` task tagged `required-expertise: ai-tooling` (assignee: RELAY).
