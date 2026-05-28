# WS-005 — aitools-common (→ aitools-claude eventually)

**Repo:** `arechste/aitools-common` (at `~/airepos/common/aitools-common/`) — rename to `aitools-claude` deferred to post-Phase 5 (R0-Q4).
**Distribution:** Claude Code plugin marketplace
**Primary agents:** RELAY, CASCADE

## Goal

Maintain the Claude Code plugin: skills, hooks, slash commands, plugin manifest. Post-Phase-5a target: ~70% smaller — skill *bodies* port to harness SOPs; this repo retains thin shims, hook scripts, plugin manifest, marketplace descriptor.

## Active tasks

See `state/delegations/open/aitools-common-*.md`.

## Phase notes

- Phase 2: PORT 10 skill bodies (SPLIT into `Team Knowledge/SOPs/` + `adapters/claude/commands/<skill>.md` shims), 4 hook scripts (verbatim to `adapters/claude/hooks/`), shared fragments to Guidelines.
- Phase 3: rewrite all 10 skill bodies in this repo as thin pointers — each body is just a wikilink to its SOP:

  ```text
  body = "Read [[SOP-XXX]] and follow it."
  ```

  Hooks migrate; plugin manifest stays.
- Phase 5a: slim — plugin wrapper only.

## Conventions in force (Phase 2 wiring)

- `[[GL-NNN-label-taxonomy]]`
- `[[GL-NNN-test-framework-detection]]`
- `[[GL-NNN-git-workflow]]`
