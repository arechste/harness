# NOTICE

This project (harness) is licensed under the MIT License — see [`LICENSE`](LICENSE).

## Inspirations & attributions

### myICOR/myPKA

harness's overall pattern — a markdown-only orchestrator scaffold with plain-text SOPs/Guidelines/Workstreams read at runtime by AI agents via `[[wikilinks]]`, a root `AGENTS.md` as identity contract, a `Team/<Name> - <Role>/AGENTS.md` per specialist, and a tool-agnostic `ADAPTER-PROMPT.md` that generates per-tool shims — is **structurally inspired by** [myICOR/myPKA](https://github.com/myICOR/myPKA) (© Paperless Movement® S.L., licensed under CC BY-NC-SA 4.0).

harness does NOT incorporate or redistribute any of myPKA's source text. The prose, identity model (TOWER + 12 callsigns), folder layout (Principal/ instead of PKM/, additional state/ and adapters/ trees), and bootstrap procedure are authored fresh for harness and released under MIT. Files that mirror myPKA's structure (notably `ADAPTER-PROMPT.md` and the root `AGENTS.md`) include an inline attribution note at the bottom.

myPKA is the upstream reference design — visit it for the canonical articulation of the pattern. `myICOR®`, `Paperless Movement®` are registered trademarks of their respective owners; nothing in harness implies endorsement, affiliation, or sponsorship.

### Other influences

Worth naming if/as they show up in the repo:

- **Claude Code subagent/skill/hook patterns** — `adapters/claude/` shim shapes mirror conventions from the Claude Code CLI (Anthropic).
- **chezmoi, mise, Homebrew** — the runtime substrates harness expects on the workshop and fleet machines (no code from any of them included here).

If you spot an unattributed inspiration, file an issue.
