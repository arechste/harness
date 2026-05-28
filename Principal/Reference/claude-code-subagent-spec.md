---
title: Claude Code Subagent Definition Spec
topic: claude-code
source_tier: 1
source_url: https://code.claude.com/docs/en/sub-agents
checked: 2026-05-28
status: verified
---

# Claude Code Subagent Definition Spec

Supported YAML frontmatter fields for `.claude/agents/<name>.md` subagent
definition files. In a file-based shim, the markdown body below the
frontmatter IS the subagent's system prompt.

## Field table

| Field | Required? | Value format | Meaning |
|---|---|---|---|
| `name` | **Yes** | lowercase letters + hyphens; unique across the tree | Identifier. Hooks see it as `agent_type`. Filename need not match. |
| `description` | **Yes** | free text | When Claude should delegate to this subagent. "Use proactively" encourages delegation. |
| `tools` | no | comma-separated list (e.g. `Read, Grep, Glob`) or YAML/JSON array | Tool allowlist. Inherits all tools if omitted. Supports `Agent(type)` scoping. |
| `disallowedTools` | no | comma-separated list | Denylist. Removed from the inherited/specified set. Applied before `tools`. |
| `model` | no | `sonnet` \| `opus` \| `haiku`, a full model ID (e.g. `claude-opus-4-8`), or `inherit` | Model the subagent runs on. Defaults to `inherit`. |
| `permissionMode` | no | `default` \| `acceptEdits` \| `auto` \| `dontAsk` \| `bypassPermissions` \| `plan` | Permission handling. |
| `maxTurns` | no | integer | Max agentic turns before stopping. |
| `skills` | no | YAML list of skill names | Skills preloaded (full content) at startup. |
| `mcpServers` | no | list of names or inline server defs | MCP servers scoped to this subagent. |
| `hooks` | no | hook config object (`PreToolUse` / `PostToolUse` / `Stop`) | Lifecycle hooks scoped to the subagent. |
| `memory` | no | `user` \| `project` \| `local` | Persistent cross-session memory dir. |
| `background` | no | `true` \| `false` (default `false`) | Always run as a background task. |
| `effort` | no | `low` \| `medium` \| `high` \| `xhigh` \| `max` | Effort override (model-dependent). |
| `isolation` | no | `worktree` | Run in a temp git worktree. |
| `color` | no | `red` \| `blue` \| `green` \| `yellow` \| `purple` \| `orange` \| `pink` \| `cyan` | Display color in task list / transcript. |
| `initialPrompt` | no | text | Auto-submitted first user turn when run as main agent via `--agent`. |

## Required vs optional

- **Required:** only `name` and `description`.
- `model` is optional and defaults to `inherit` (uses the parent session's model).
- Every other field is optional.

## `prompt` is not a file-frontmatter field

In file-based shims the markdown body is the system prompt, so there is no
`prompt` frontmatter key. The `--agents` CLI/JSON path uses a `prompt` field
to carry the system prompt instead. Do not add `prompt` to a
`.claude/agents/<name>.md` file.

## Canonical doc URL moved

`https://docs.anthropic.com/en/docs/claude-code/sub-agents` now
301-redirects to `https://code.claude.com/docs/en/sub-agents`. The
`code.claude.com` host is the authoritative Tier-1 source. (Redirect
re-confirmed 2026-05-28.)

## Harness fit

Our 12 harness shims (`adapters/claude/agents/<slug>.md`) use only `name`,
`description`, and `tools` — fully spec-compliant; `model` is omitted
everywhere, so all default to `inherit`. (Detailed audit lives in the session
log.)

## Source

- Tier 1 (canonical Claude Code docs): https://code.claude.com/docs/en/sub-agents — checked 2026-05-28.
