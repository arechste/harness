---
date: 2026-05-29
status: durable
topic: subagent model tiering
graduation-candidate: GL (team operational policy)
---

# Subagent model tiering — sonnet for dispatched work, opus for TOWER

**Decision (live in `.claude/settings.json`, commit `bc369fa`):** set
`CLAUDE_CODE_SUBAGENT_MODEL=sonnet` so all 12 callsign subagents default to
sonnet when dispatched, while TOWER's main session stays on opus. Per-shim
`model:` remains available as a per-role override if a specific callsign proves
it needs opus.

## Why

- The right axis for model choice is **reasoning demand, not read/write
  permissions.** The heavy reasoning — routing, synthesis, judgment — happens in
  TOWER's main session. Dispatched subagents do bounded, well-scoped work that
  sonnet handles well.
- Subagent `model:` defaults to `inherit`, which would run every dispatched
  agent on the main session's model (opus, 1M context) — expensive for bounded
  work. A global env default is the 80/20 cost lever.
- Setting it via harness-canonical `settings.json` (not per-shim `model:`
  fields) keeps the 12 shims uniform and restores the principal's pre-wipe
  global default in one place.

## Provenance

Surfaced by RECON's Claude Code subagent-spec audit (2026-05-28). Rationale
captured here so it doesn't live only in a commit message. Spec details:
`Principal/Reference/claude-code-subagent-spec.md`.

**Graduation note:** this is team operational policy and a candidate to become a
Guideline (`GL-NNN-subagent-model-tiering`) when Phase 2 reconciles and numbers
the Guideline set. Kept as a Journal entry for now to avoid pre-empting that
numbering.
