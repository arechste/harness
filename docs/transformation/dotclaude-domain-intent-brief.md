# dotclaude Domain — Intent Brief

**Status:** DRAFT / analysis — NOT ratified SSOT. Authored 2026-05-29 by RELAY.
**Baseline SHA:** dotclaude @ 4a01477 (recorded in `state/repo-baselines.yaml`).
**Phase:** Phase-2 intent-mine (step 1 of 3 — intent-mine → goals-interview → agnostic-author).
**Sources read:** `home/rules/`, `home/memory/`, `home/skills/`, `home/hooks/`, `home/agents/`,
`home/CLAUDE.md`, `home/settings.json.tmpl`, `.claude/rules/`, `scripts/`, `docs/decisions/` (count only).
Cross-referenced: `Phase-0-audit.md §2`, `Phase-2-operating-model.md §4`.

---

## What dotclaude IS

dotclaude is the **AI runtime configuration layer** for a single AI tool (Claude Code). It sits between
the principal's intent ("how Claude should behave across all machines") and the deployed runtime
(`~/.claude/`). It does three things: (1) encodes behavioral norms as loaded rules, (2) ships
capabilities (skills/hooks/agents) as chezmoi-deployed files, and (3) holds the governance model for
the multi-repo system (team hierarchy, delegation protocol, auto-merge policy).

The governance embedded in dotclaude is the highest-leverage content in the whole system — and also the
most Claude-coupled, most duplicated, and most in need of extraction.

---

## Area-by-Area Triage

### 1. `home/rules/` — 7 behavioral rule files

| File | Intent (why it exists) | Durable principle | Claude mechanic |
|---|---|---|---|
| `claude-operations.md` | Runtime hygiene: temp files, memory discipline, MCP scope, cross-repo working | Agent should not accumulate ambient state; ephemeral work is local, durable work is committed | `.tmp/` naming scheme, `@memory/MEMORY.md` load, `/dc:` plugin invocation, `--cache` flags |
| `code-of-conduct.md` | Security, attribution, supply-chain discipline for any AI-assisted work | Don't introduce unverified dependencies; declare AI involvement; honor licenses | None — already tool-agnostic prose |
| `coding-standards.md` | Good software craft: small functions, explicit naming, test behavior not impl | Universal engineering principles | None — already tool-agnostic |
| `execution.md` | Decision heuristic: when to plan vs act; bash one-command discipline | AI should not over-plan well-understood tasks; context is a limited resource | Skill invocation model (`/dc:<name>`); compound-command block (`pre-tool-use-bash-discipline.sh`); `uv run` preference |
| `git-conventions.md` | Consistent git identity, commit format, commit trailer, gh CLI discipline | Commits carry identity + rationale; API calls cache where possible; heredoc over inline strings | `commit-trailer.json` lookup, `gh --cache`, `git switch` not `git checkout`, `.tmp/` 3-step pattern |
| `safety.md` | Prevent credential leakage, destructive commands, runaway automation | Agent must operate at least-privilege; suppress raw secrets from output; confirm before destructive ops | `op account list` form, `&>/dev/null` pattern, settings.local.json audit, machine-mismatch flagging |
| `tone-concise.md` | Principal communication preference | Prefer direct, terse output with no preambles or emoji | None — already fully agnostic |

**Verdict for all 7:** move-to-harness as Guidelines (GL-NNN-*). The principles are entirely transferable.
The Claude mechanics (skill invocation paths, bash discipline hook name, commit-trailer file path) stay
in dotclaude as reference or are rendered by the adapter. The code-of-conduct, coding-standards, and
tone files are already 100% tool-agnostic — their Claude mechanic column is empty.

---

### 2. `home/memory/` — feedback (3) + source (9) + index files (2)

**Feedback files (`feedback_*.md`):** Encode principal-corrected behavior — the "I burned my hand,
don't touch the stove" record. `feedback_bash_no_compound.md` captures the compound-command rule;
`feedback_chrome_mcp.md` captures cross-machine risk of MCP; `feedback_op_syntax.md` captures
correct `op` CLI form.

- Intent: preserve experiential learning so the next session doesn't repeat the same mistake.
- Durable principle: durable principal feedback is system-level memory, not a per-tool config file.
- Claude mechanic: loaded via `@memory/MEMORY.md` at session start; file format (YAML frontmatter + prose).
- Verdict: move-to-harness as team-memory under `PKM/Reference/` or a `Team Knowledge/Guidelines/`
  subsection. The bash-no-compound rule is already partially encoded in `execution.md` — the feedback
  adds the "why it triggers approval" rationale that belongs in a GL.

**Source files (`source_*.md`):** Fetched reference cache — official docs index, Claude Code
permissions, compaction API, surfaces, settings, models, folder trust, agent patterns. These are
on-demand research snapshots, not behavioral rules.

- Intent: avoid redundant web fetches; keep authoritative doc index fresh.
- Durable principle: team should maintain a curated index of authoritative sources, updated on
  significant API/product changes.
- Claude mechanic: `REFERENCE.md` lazy-load pattern; frontmatter `type: reference`; staleness
  tracked in `aitools-common/data/references/source_memory_consolidation.json`.
- Verdict: move-to-harness as `PKM/Reference/<topic>.md` (per Phase-0-audit §2 mapping).
  The index/loader files (`MEMORY.md`, `REFERENCE.md`) are Claude-specific and stay in dotclaude
  as chezmoi artifacts.

---

### 3. `home/skills/` — 9 U-scope skills

Skills: `ci-check`, `commit`, `explain`, `gh-workflow`, `recover`, `research`, `review`, `test-gen`,
`test-run`. Each is a `SKILL.md` invoked as `/dc:<name>` from any project.

- Intent: reusable, parameterized procedures for common engineering tasks — commit without thinking
  about trailer format, run tests without knowing the framework, etc.
- Durable principle: recurring tasks should be encoded as executable procedures (SOPs) with defined
  inputs, steps, and outputs, independent of the tool that runs them.
- Claude mechanic: SKILL.md format (frontmatter + body); invoked via plugin `/dc:` prefix; body mixes
  prose instructions with Claude-specific patterns (tool calls, permission assumptions).
- Verdict: split — SOP body moves to `harness/Team Knowledge/SOPs/SOP-<name>.md`; Claude shim stays
  in `dotclaude` (or moves to `harness/adapters/claude/commands/`) as the invocation wrapper.
  The split is the same as the aitools-common skills treatment.

---

### 4. `.claude/skills/` — 7 project-scope skills

Skills: `canary`, `drift`, `scout`, `skill-create`, `skill-manage`, `sync`, `upstream`.
These operate at dotclaude-the-repo scope (drift detection, skill authoring, upstream Claude version
tracking, convention sync to fleet).

- Intent: dotclaude self-management — keeping the runtime fresh, detecting drift, syncing conventions
  across the fleet.
- Durable principle: the AI runtime layer must have a self-audit / refresh loop. Tool-config drift
  is a category of infrastructure drift and should be tracked like any other.
- Claude mechanic: project-scoped SKILL.md; `drift` uses `session-start-deferred-*` hooks;
  `scout` reads `references/*.md` colocated data files; `sync` invokes convention-sync against fleet.
- Verdict: split — bodies to SOPs; shims stay in dotclaude (they are genuinely dotclaude-self-ops).
  Exception: `skill-create` and `skill-manage` encode the SOP for authoring skills generically —
  those bodies belong in harness as `SOP-create-skill.md` and `SOP-manage-skill.md`.

---

### 5. `home/hooks/` — 17 hook scripts

Hooks: `session-start.sh`, `session-end.sh`, `pre-tool-use-bash-discipline.sh`,
`pre-tool-use-home-write-guard.sh`, `pre-tool-use-remote-exec-guard.sh`,
`pre-tool-use-git-advisory-lock.sh`, `post-compact.sh`, `pre-compact.sh`,
`config-change.sh`, `notification.sh`, `stop-summary.sh`, `session-start-deferred-git.sh`,
`session-start-deferred-sandbox-health.sh`, `session-start-deferred-settings-local.sh`,
`worktree-create.sh`, `worktree-remove.sh`.

- Intent (grouped by concern):
  - **Safety guards** (`home-write-guard`, `remote-exec-guard`, `bash-discipline`): enforce the
    safety and execution rules at the tool call boundary — not just as text rules but as actual
    blockers. Intent: rules without enforcement are aspirational; hooks make them invariants.
  - **Session lifecycle** (`session-start`, `session-end`, `stop-summary`, `post-compact`):
    provide git context on start, clean up temp files on end, surface in-progress state.
    Intent: every session begins with correct situational awareness; residue doesn't accumulate.
  - **Drift detection** (`settings-local`, deferred git, sandbox-health`): surface config drift
    passively without blocking. Intent: configuration debt is visible before it causes problems.
  - **Advisory locking** (`git-advisory-lock`): prevent parallel sessions from clobbering each
    other on git operations. Intent: concurrent agent sessions require explicit coordination.
  - **Worktree lifecycle** (`worktree-create`, `worktree-remove`): manage git worktrees with
    clean setup/teardown. Intent: worktrees are an isolation unit; lifecycle should be automated.

- Durable principle: safety invariants (destructive-op guards, write-path guards, credential
  suppression) must be enforced at the execution boundary, not just stated in rules. Session
  context injection and state cleanup are infrastructure concerns, not behavioral rules.
- Claude mechanic: Claude Code hook events (`PreToolUse`, `PostToolUse`, `SessionStart`, etc.);
  `hooks.json` registration; bash scripts with specific exit-code semantics.
- Verdict: stays-as-repo-artifact. Hooks are inherently tool-specific (Claude Code hook events
  are not a generic concept). The *intent* of each guard moves to harness as a Guideline or
  SOP principle. The scripts themselves stay in dotclaude. Note: `home-write-guard` and
  `remote-exec-guard` also exist in aitools-common — Phase-3 reconciliation point (pick one
  canonical, regenerate both deployments).

---

### 6. `home/agents/` — 2 subagent definitions

`planner.md` (read-only exploration + trade-off analysis, returns written plan to lead) and
`implementer.md` (inferred: focused execution subagent).

- Intent: enable multi-agent orchestration — isolate plan-phase context from implementation
  context; allow lead agent to delegate work while keeping its own context clean.
- Durable principle: complex tasks benefit from context isolation; planning and execution are
  distinct cognitive modes that should not share a context window.
- Claude mechanic: Claude Code `Agent` tool; frontmatter `tools:`, `model:`, `maxTurns:`,
  `isolation:`; invoked by lead agent's orchestration logic.
- Verdict: stays-as-repo-artifact for now (they are U-scope / dotclaude-context agents).
  Phase-3 action: evaluate whether the *roles* (planner, implementer) should become harness
  callsigns (or callsign sub-modes) and regenerate shims from harness contracts.

---

### 7. `home/CLAUDE.md` + `home/settings.json.tmpl`

**`home/CLAUDE.md`:** The loader — 7 `@rules/` includes + `@memory/MEMORY.md` + environment
context (shell, editors, terminal, package managers, chezmoi boundary reminder, routines caveat).

- Intent: assemble the behavioral rules into a single loaded document; provide stable environment
  context so Claude doesn't need to discover it.
- Durable principle: each tool adapter needs a single entry-point file that loads the agnostic
  content layer. The environment context (shell, editors) is tool-agnostic reference data.
- Claude mechanic: `@path` include syntax; `~/.claude/CLAUDE.md` as the global config entry point.
- Verdict: drop (regenerate). Phase-0-audit says DROP — replaced by thin pointer generated by
  ADAPTER-PROMPT. The environment facts belong in `PKM/.user.yaml` or a reference file;
  the `@rules/` loading list is replaced by the harness adapter's CLAUDE.md generation.

**`home/settings.json.tmpl`:** chezmoi template rendering `~/.claude/settings.json`. Encodes:
- Permission allow-list (Read/Glob/Grep universal; Bash scoped to specific commands + repo paths;
  Write/Edit scoped to known repo directories; Agent/Skill/WebFetch to known domains).
- Permission deny-list (destructive git ops, credential-reading commands, sensitive home dirs).
- `deniedMcpServers` (cloud-synced Gmail, Drive blocked by default).
- Machine-conditional blocks (`{{ if not .isWork }}`).
- Plugin marketplace registration for aitools-common.

- Intent: enforce permission policy at the tool configuration level (not just as text rules);
  adapt scope to machine type (work vs personal). The deny list operationalizes the safety rules.
- Durable principle: AI tool permissions should be explicitly scoped to known paths and operations,
  not left open. Work machines may require tighter scope than personal machines.
- Claude mechanic: Claude Code `settings.json` schema; chezmoi template variables; `deny` array
  semantics; `deniedMcpServers` key.
- Verdict: stays-as-repo-artifact. This is quintessentially deployment-runtime. The *principle*
  (explicit allow + deny, machine-conditional scope) moves to harness as a Guideline.
  The template stays in dotclaude. The deny-list values should be cross-checked against
  GL-002-credential-custody when that GL is extended.

---

### 8. `.claude/rules/` — 6 project-scope rules

Files: `delegation.md`, `monorepo-conventions.md`, `planning-artifacts.md`,
`session-protocol.md`, `team-model.md`, `workflow.md`.

- Intent: project-level operating context for working *on* dotclaude itself — delegation
  mechanics, branch/PR/merge policy, team hierarchy, agent modes, auto-merge criteria.
- Key observation: these are the most governance-dense files in the repo. `team-model.md` defines
  the 4-repo hierarchy. `workflow.md` encodes agent mode taxonomy, auto-merge policy, handoff
  state machine, permission tiers. `delegation.md` is a pointer to the canonical protocol in
  git-organizer (already shows intent: delegation is cross-repo, not dotclaude-owned).
- Durable principle: the operating model (team structure, delegation state machine, agent modes,
  merge policy) is tool-agnostic governance that should live in a single SSOT, not per-repo.
- Claude mechanic: `.claude/rules/` project scope loading; pointers to git-organizer canonical
  via raw GitHub URLs (a smell — cross-repo governance should live in harness, not in
  GitHub-URL references scattered across project rule files).
- Verdict: all 6 PORT to harness — but at different destinations:
  - `team-model.md` → superseded by `AGENTS.md` + `Team/agent-index.md` (already exists)
  - `workflow.md` → body to SOP(s): `SOP-agent-modes.md`, `SOP-auto-merge.md`,
    `SOP-handoff-state-machine.md`; or consolidate into a `WS-ai-runtime-workflow.md` Workstream
  - `delegation.md` → confirms delegation SOP belongs in harness (not a dotclaude concern)
  - `planning-artifacts.md` → Guideline `GL-NNN-planning-artifacts.md`
  - `session-protocol.md` → Guideline `GL-NNN-session-protocol.md` (thin; references harness)
  - `monorepo-conventions.md` → stays-as-repo-artifact (dotclaude-specific naming + data rules)

---

### 9. `scripts/` + `docs/decisions/` (boundary only)

- `scripts/`: CI validation, dashboard, session-log-parser, skill-eval — repo tooling. Stays.
- `docs/decisions/`: 28 ADRs (pre-030 boundary per round-0). Stays in dotclaude as repo-local
  historical record. Selected cross-cutting ones may be mirrored as harness historical references.

---

## Cross-Repo Entanglements

1. **`git-conventions.md` sourced from git-organizer:** The file header says
   "Source: git-organizer (domain expert), deployed via dotclaude#281." Dotclaude is a
   distribution vehicle for git-organizer's canonical. After Phase 2, this GL lives in harness;
   both repos consume from harness, no more copying.

2. **Delegation protocol split across 3 repos:** Canonical lives in git-organizer
   (`docs/conventions/delegation-protocol.md`). Dotclaude `.claude/rules/delegation.md` is a
   pointer + local extension. aitools-common `skills/shared/delegation-protocol.md` is a
   skill-embedded copy. All three should collapse to one `SOP-file-delegation.md` in harness +
   a thin adapter shim per tool.

3. **`command-map.yaml` triplicated:** dotclaude/data, aitools-common/data, git-organizer/data
   all hold routing maps. One WS-routing.md in harness replaces all three.

4. **`home-write-guard` + `remote-exec-guard` in both dotclaude and aitools-common:**
   Two distribution paths (chezmoi vs plugin marketplace), same script. Phase-3 action:
   one canonical in `harness/adapters/claude/hooks/`; both repos regenerate from it.

5. **`team-model.md` (.claude/rules) vs AGENTS.md (harness):** The repo-local team model is
   the old hierarchy. It is already superseded by harness AGENTS.md. Post-carve it should be
   a one-line pointer. Nothing to author — the new SSOT already exists.

6. **`source_*.md` staleness tracking** lives in `aitools-common/data/references/
   source_memory_consolidation.json` — a data file in a different repo governs refresh policy
   for memory files in dotclaude. That coupling should become a harness-held reference.

---

## What dotclaude Keeps After Carve (the runtime residual)

After Phase-5a, dotclaude retains only what must physically live there to deploy:

- `home/settings.json.tmpl` — chezmoi-rendered permission policy
- `home/hooks/` — 17 hook scripts (Claude-specific execution boundary enforcement)
- `home/agents/` — subagent definitions (until superseded by harness callsign shims)
- `home/skills/` — shim halves of split skills (thin wrappers pointing at harness SOPs)
- `home/CLAUDE.md` — regenerated thin pointer (ADAPTER-PROMPT output)
- `home/commit-trailer.json`, `home/keybindings.json`, `home/statusline-command.sh` — UI config
- `home/scripts/` — session-support scripts (`tmp-clean.sh`, etc.)
- `data/` runtime artifacts (move-list.yaml retires post-migration)
- `scripts/`, `tools/` — repo CI and ops tooling
- `templates/` — project scaffold templates (repo-local)
- `docs/decisions/` — 28 pre-030 ADRs (repo-local historical)
- `docs/` (remainder) — operator + developer docs for dotclaude itself
- `.claude/` runtime state + `monorepo-conventions.md`
- Repo infra: LICENSE, README, CI, CHANGELOG, etc.

Estimated post-carve size: ~500 lines of governed content vs ~2000+ today. The repo becomes a
deployment vehicle, not a governance document.

---

## Provenance

All source paths under `/Users/arechste/airepos/common/harness/repos/dotclaude/`.
Cross-ref: `Phase-0-audit.md §2`, `Phase-2-operating-model.md §4 (dotclaude worked example)`.
Baseline SHA: dotclaude @ 4a01477 per `state/repo-baselines.yaml`.
