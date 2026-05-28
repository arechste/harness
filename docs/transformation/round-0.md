# Personal Infra Assistant — Round 0 (Design)

**Status:** R0 design complete, R0 close-out executed (this file is the durable home — initial commit of arechste/harness). Phase 0 (audit) begins in a new session.

**Authored:** 2026-05-26 to 2026-05-27 in a multi-turn plan-mode session run from cwd `~/airepos/common/aitools-common/` on merktnix.

**Companion artifacts:**
- Anchor issue: `arechste/aitools-common` — `chore(arch): personal-infra-assistant transformation`
- ADR stub: `arechste/dotclaude` `docs/decisions/030-harness-transformation.md` (on `transformation/r0-anchor` branch)
- Phase 1 prep procedure: [`Phase-1-prep-fragtnix-clean-slate.md`](Phase-1-prep-fragtnix-clean-slate.md)

---

## Load-bearing architectural property: harness is CENTRAL, not distributed

**harness is the "office" where the team of agents works.** It lives on ONE machine at a time. Default primary = **fragtnix** (validation host). Default alternate = **merktnix** (current cwd, where R0 was authored). User can move primary by intent.

| Component | Distribution model |
|---|---|
| **harness** (the workshop) | Single-machine. Backup = `git push` to `arechste/harness` on GitHub. Recovery = `git clone` on a new host. **Not cloned to other fleet machines.** |
| **dotfiles** | Distributed via chezmoi to all Claude-using machines (merktnix, tutnix, machtnix, CR61790DFV) |
| **dotclaude** | Distributed via chezmoi to same set |
| **aitools-common (→ future aitools-claude)** | Distributed via Claude Code plugin marketplace; reusable artifacts for Claude-using machines |
| **fleet-organizer**, **git-organizer** | Operated centrally; cloned only on machines that need to run their tooling (workshop + maybe 1-2 others) |
| **Future product repos** | Each gets its own repo per its own distribution needs |

**Implication**: cross-machine sync of harness *state* is a non-problem — state is single-machine by design, with git as backup. The OUTPUTS of harness (commits to the 5 product repos) are what reach other machines via their existing distribution mechanisms (chezmoi for dotfiles/dotclaude, plugin marketplace for aitools-common, manual clone for the *-organizer repos as needed).

**Implication**: `harness/bootstrap/install.sh` is for the workshop machine only — clones the *-organizer repos as `repos/<name>/` working copies for cross-repo writes. Other machines don't run this; they use chezmoi + plugin marketplace as today.

## R0 Locks (final)

| ID | Decision | Locked value |
|---|---|---|
| R0-Q1 | Folder naming | myPKA conventions (Team/, Team Knowledge/SOPs|Guidelines|Workstreams|Templates|tasks/session-logs/, journal/) + Principal/ instead of PKM/ |
| R0-Q1.5 | Agent roster | 13 agents with callsigns + animals: TOWER/Eagle (COO), SCOUT/Wolf (Recruiter), RECON/Fox (Researcher), VAULT/Elephant (Librarian), QUILL/Magpie (Tech Writer), LATTICE/Spider (Schemar), BRIDGE/Octopus (Integrator), SENTRY/Mongoose (Auditor), FORGE/Beaver (DevOps Eng), RANGER/Border Collie (SysAdmin), SPARK/Raccoon (Developer), CASCADE/Salmon (GitOps Eng), RELAY/Chameleon (AI Tooling Eng). Folder pattern `Team/<CALLSIGN> - <Role>/`. Expansion via SCOUT's `SOP-hire-agent`. |
| R0-Q2 | Bootstrap | Fork myPKA's ADAPTER-PROMPT.md and adapt (~350 lines, tool-agnostic, generates per-tool shims) |
| R0-Q3 | PKM rename | `Principal/` |
| R0-Q4 | aitools-common future | Defer rename to `aitools-claude` until post-Phase 5. During Phases 0-3, move Claude-specific harness-bootstrap content into `harness/adapters/claude/`. aitools-common stays as distributable plugin wrapper. |
| R0-Q5 | Repo name | `harness` → `arechste/harness` at `~/airepos/common/harness/` |
| R0-Q6 | Repo layout | Hierarchy — orchestrator IS its own git repo; `repos/<name>/` are nested independent clones (NOT submodules); `repos/` in `.gitignore`; bootstrap script populates |
| R0-Q7 | Fleet rename + scope | `mac-organizer` → `fleet-organizer`, unified Mac/Linux/container; `os:` field per inventory entry; happens in Phase 5a |
| R0-Q8 | Tracker migration | 184 entries → MD per entry → `harness/state/delegations/{open,done/<YYYY>/<MM>,cancelled/<YYYY>/<MM>}/<repo>-<N>.md`; 4 per-repo trackers deprecated post-Phase 5a |
| R0-Q9 | Anchor issue | File in `arechste/aitools-common` initially; transfer to `arechste/harness` after Phase 1 |
| R0-Q10 | Forge model | File-primary SSOT; forge-as-mirror; sync at task boundary; offline-capable; some files (tagged) become GitHub issues, others stay file-only |
| R0-Q11 | Phasing | **Build-then-carve (Option B):** Phase 1-4 leave existing repos untouched; Phase 5a slims them only after fragtnix validates harness can substitute. **Critical safety property:** rollback = `git checkout main` in harness; existing repos always authoritative until Phase 5a. |

---

## What myPKA actually is (confirmed from source)

| Aspect | myPKA design |
|---|---|
| Bootstrap | `ADAPTER-PROMPT.md` (~350 lines, tool-agnostic prose). Pasted as message 1 into any AI tool. Tool-detection branches on Claude/Cursor/Gemini/ChatGPT/Codex. Idempotent. |
| Identity | Root `AGENTS.md` mandates: "you are now the orchestrator." Single primary identity. Specialists are "hats" the same model wears by reading the specialist's contract. |
| Agent contracts | `Team/<Name>/AGENTS.md`, 80-200 lines plain prose, no frontmatter. Operating procedures, not personality narrative. |
| SOPs | `Team Knowledge/SOPs/SOP-<verb>-<noun>.md`. Invoked by wikilink. Structure: header metadata, Purpose, When to call, Inputs, Steps, Worked example, Common mistakes. |
| Guidelines + Workstreams | `GL-NNN-<topic>.md` for static reference, `WS-NNN-<flow>.md` for multi-agent compositions. Same wikilink invocation. |
| Tasks | Rich frontmatter (`id`, `assignee`, `priority`, `status`, `linked_sops[]`, `linked_journal_entries[]`, ...). Lifecycle = folder moves. Task = "resumption point". |
| Journals | Durable insights only. `status: durable | superseded`. Superseded kept and linked, never deleted. |
| Delegation | No inbox folder. Hand-off = task file with `assignee:` set. Session boot walks `tasks/open/`. Assignee runs `SOP-claim-task` → `git mv`. |
| Tool shims | `.claude/agents/<slug>.md` generated by bootstrap. No `.cursor/rules/` etc. pre-shipped. |
| Templates | `Team Knowledge/Templates/` for entity types. Used at runtime, not for bootstrap. |
| No install script. | Bootstrap = clone + paste `ADAPTER-PROMPT.md`. |

---

## Agent model (role-based, not repo-based — BKM framing)

Agents = **roles with expertise**. Workstreams = projects (repos or topics). A task pulls multiple agents based on needed expertise. Same agent contributes across many workstreams.

| Layer | Callsign | Animal | Role |
|---|---|---|---|
| Leadership | **TOWER** | Eagle | COO / Orchestrator |
| Leadership | **SCOUT** | Wolf | Recruiter (hires new agents on scope expansion) |
| Research | **RECON** | Fox | Researcher |
| Knowledge ops | **VAULT** | Elephant | Librarian (SSOT, wikilinks) |
| Knowledge ops | **QUILL** | Magpie | Tech Writer |
| Knowledge ops | **LATTICE** | Spider | Schemar |
| Integration | **BRIDGE** | Octopus | Integrator (MCP, forges) |
| QA | **SENTRY** | Mongoose | Auditor (security, conflicts) |
| Eng | **FORGE** | Beaver | DevOps Engineer (chezmoi, mise, brew) |
| Eng | **RANGER** | Border Collie | SysAdmin (fleet ops, OS configs) |
| Eng | **SPARK** | Raccoon | Developer (shell, python, automation) |
| Eng | **CASCADE** | Salmon | GitOps Engineer (git, gh, branches, PRs) |
| Eng | **RELAY** | Chameleon | AI Tooling Engineer (Claude Code, plugins, adapters) |

Workstreams (initial): WS-001-dotfiles, WS-002-dotclaude, WS-003-fleet, WS-004-git-conventions, WS-005-aitools-common. Future: WS-FUTURE-browser, WS-FUTURE-network, WS-FUTURE-homelab.

---

## Conversion taxonomy (how existing content maps to harness)

| Source | Source type | Lands as | Naming |
|---|---|---|---|
| `dotclaude/home/rules/<topic>.md` | Universal rules | `harness/Team Knowledge/Guidelines/GL-NNN-<topic>.md` | One GL per rule |
| `dotclaude/home/memory/feedback_*.md` | Feedback | `harness/Team Knowledge/Guidelines/GL-NNN-feedback-<topic>.md` | Operationalized as Guidelines |
| `dotclaude/home/memory/source_*.md` | References | `harness/Principal/Reference/<topic>.md` | Principal-owned |
| `dotclaude/home/skills/<skill>/SKILL.md` (U-tier) | Universal skills | Split: body → `harness/Team Knowledge/SOPs/SOP-...md`; Claude shim → `harness/adapters/claude/commands/<skill>.md` | Audit determines split |
| `aitools-common/skills/<skill>/SKILL.md` (F-tier) | Fleet skills | Same split as above | |
| `aitools-common/skills/shared/<frag>.md` | Shared fragments | Per type: SOPs/ or Guidelines/ | delegation-protocol → SOPs; label-taxonomy → GL; test-framework-detection → GL |
| `aitools-common/hooks/<hook>.sh` | Runtime enforcement | `harness/adapters/claude/hooks/<hook>.sh` | Verbatim |
| `aitools-common/data/repo-inventory.json` | Fleet metadata | `harness/Team Knowledge/Templates/repo.template.md` + `harness/state/inventory/<repo>.md` | Per-repo MD wraps |
| `aitools-common/data/command-map.yaml` | Trigger→skill | `harness/Team Knowledge/Workstreams/WS-routing.md` | TOWER routing |
| `dotclaude/docs/decisions/*.md` | ADRs | **Stay in dotclaude.** New ADR 030+ live in `harness/docs/decisions/`. | Migration boundary |
| `dotclaude/home/CLAUDE.md` | Bootstrap loader | Thin pointer generated by ADAPTER-PROMPT.md | "Read harness/AGENTS.md first" |
| `mac-organizer/inventory/<host>.yaml` | Per-machine facts | **Stay in fleet-organizer.** harness/state/inventory/<host>.md wraps. | YAML stays, MD wraps |
| `git-organizer/docs/conventions/<topic>.md` | Git/forge | Split: cross-repo → harness/Team Knowledge; git-specific stays | Audit determines per-convention |

---

## Routing mechanics (Phase 1 seed SOPs)

- `SOP-route-task` — TOWER reads task, matches `required-expertise:` tags against `Team/agent-index.md`, assigns
- `SOP-claim-task` — agent moves task `open/ → in-progress/`, reads linked context, begins
- `SOP-handoff-task` — agent finishes their part, reassigns to next in workstream
- `SOP-close-task` — agent moves `in-progress/ → done/`, writes outcome, extracts journal insight if durable
- `SOP-escalate-blocked` — agent marks blocked, COO triages
- `SOP-hire-agent` — SCOUT drafts new `Team/<callsign>/AGENTS.md`, registers in `agent-index.md`, generates Claude shim
- `SOP-file-delegation` — file GitHub issue + create harness/state/delegations/open/<repo>-<N>.md mirror
- `SOP-cutover-machine` — Phase 5b: clone harness, run bootstrap, deprecate legacy paths, validate

---

## Repo shape projections (after Phase 5a — domain repos slim)

| Repo | Today | After Phase 5a |
|---|---|---|
| dotclaude | ~3000 lines | ~500: settings.json.tmpl, chezmoi runtime, pre-Round-0 ADRs, thin CLAUDE.md (pointer). Most content moved to harness. |
| dotfiles | chezmoi + Brewfile + shell rc + mise + dotenv | Largely unchanged; few rule-doc files may move out |
| git-organizer | git/gh/forge conventions + tools + CI templates | ~30-40% smaller: cross-repo conventions (delegation, labels) move to harness; git-specific stays |
| mac-organizer → fleet-organizer | inventory + scripts + docs | ~25% smaller: orchestration SOPs move out; inventory + OS scripts stay; rename + scope expansion + `os:` field added |
| aitools-common (→ aitools-claude later) | 10 skills + 4 hooks + shared/ + data/ + plugin | ~70% smaller: SOPs move to harness; hooks + slash-command shims + plugin manifest remain |

---

## Target tree

```
~/airepos/common/harness/                  ← arechste/harness (greenfield)
├── ADAPTER-PROMPT.md                       ← tool-agnostic init, paste into any LLM
├── AGENTS.md                               ← root identity: "you are TOWER, the COO"
├── README.md                               ← human entry point
├── Team/
│   ├── agent-index.md                      ← routing table (expertise → callsign)
│   ├── TOWER - COO/                        ← Eagle / Orchestrator
│   ├── SCOUT - Recruiter/                  ← Wolf
│   ├── RECON - Researcher/                 ← Fox
│   ├── VAULT - Librarian/                  ← Elephant
│   ├── QUILL - Tech Writer/                ← Magpie
│   ├── LATTICE - Schemar/                  ← Spider
│   ├── BRIDGE - Integrator/                ← Octopus
│   ├── SENTRY - Auditor/                   ← Mongoose
│   ├── FORGE - DevOps Engineer/            ← Beaver
│   ├── RANGER - SysAdmin/                  ← Border Collie
│   ├── SPARK - Developer/                  ← Raccoon
│   ├── CASCADE - GitOps Engineer/          ← Salmon
│   └── RELAY - AI Tooling Engineer/        ← Chameleon
├── Team Knowledge/
│   ├── INDEX.md
│   ├── SOPs/                               ← SOP-<verb>-<noun>.md
│   ├── Guidelines/                         ← GL-NNN-<topic>.md
│   ├── Workstreams/                        ← WS-NNN-<flow>.md (WS-001 through WS-005 + WS-routing)
│   ├── Templates/                          ← repo.template.md, machine.template.md, plugin.template.md, delegation.template.md, agent-contract.template.md
│   ├── tasks/                              ← open/, in-progress/, done/<YYYY>/<MM>/, cancelled/<YYYY>/<MM>/
│   └── session-logs/                       ← one per session, append-only
├── Principal/
│   ├── INDEX.md
│   ├── .user.yaml                          ← {{USER_NAME}}, preferences
│   ├── Machines/<host>.md
│   ├── Reference/                          ← migrated from source_*.md memories
│   ├── Goals.md, About-me.md
│   └── Journal/                            ← your insights (separate from agents')
├── state/
│   ├── delegations/                        ← open/, done/<YYYY>/<MM>/, cancelled/<YYYY>/<MM>/
│   ├── inventory/                          ← per-repo MD + per-machine MD wrappers
│   └── machines/<host>.md                  ← per-host pending work cache
├── adapters/
│   ├── claude/
│   │   ├── CLAUDE.md.template
│   │   ├── agents/<callsign>.md.template   ← Claude Code subagent shims (generated)
│   │   ├── hooks/                          ← migrated from aitools-common/hooks
│   │   ├── skills/                         ← thin SKILL.md shims → harness SOPs
│   │   └── plugin-manifest.template
│   └── (future: cursor/, gemini/, ...)
├── bootstrap/
│   ├── install.sh                          ← clones subrepos, runs chezmoi
│   └── README.md
├── docs/
│   ├── decisions/                          ← ADR 030 onwards
│   ├── transformation/
│   │   ├── round-0.md                      ← this plan
│   │   ├── round-1.md (Phase 0 audit deliverable)
│   │   └── ...
│   └── architecture/
├── ci/                                     ← validate JSON/YAML schemas, lint SOPs, wikilink check
└── repos/                                  ← gitignored; populated by install.sh
    ├── aitools-common/
    ├── dotclaude/
    ├── dotfiles/
    ├── fleet-organizer/                    ← renamed from mac-organizer in Phase 5a
    └── git-organizer/
```

---

## Phases (revised — build-then-carve / Option B)

### Phase 0 — Audit (read-only, ~1-2 sessions)
Per-repo classification of every item: PORT | KEEP-CLAUDE | DROP | REPO-LOCAL, with destination if PORT. Deliverable: `harness/docs/transformation/Phase-0-audit.md`. **Existing repos untouched.**

### Phase 1 — Scaffold (greenfield, ~1-3 sessions)

**Phase 1 Step 0 — Clean-slate fragtnix (PREREQUISITE before any harness work runs there).**

Goal: virgin Claude installation on fragtnix. Remove the currently chezmoi-deployed `~/.claude/` content (dotclaude regime) and any local clones (`~/airepos/common/dotclaude/`, `~/airepos/common/aitools-common/`) so that when ADAPTER-PROMPT.md is pasted into a fresh Claude session, harness can establish its own scaffold from scratch without interference. Procedure (executed at Phase 1 kickoff with user near fragtnix; each destructive step requires explicit approval):

1. **Probe state**: from fragtnix or via `ssh arechste@fragtnix-1`, inventory:
   - `ls -la ~/.claude/` (what chezmoi has deployed)
   - `ls -la ~/airepos/common/` and `~/airepos/claude/code/` (any existing repo clones)
   - `cat ~/.claude.json | jq 'keys'` (per-project trust state, enabled plugins, MCP connectors)
   - Active Claude sessions: `pgrep -af '[c]laude'` (must be zero)
2. **Stop chezmoi auto-apply for `home/dot_claude/`**: temporarily mark managed files as "ignored" via chezmoi's `.chezmoiignore`, OR commit a temporary fragtnix-specific override in dotfiles. Reason: prevent next chezmoi apply from re-deploying the regime we're about to remove.
3. **Archive then delete `~/.claude/`**: `tar -czf ~/claude-pre-harness-backup-$(date +%F).tar.gz ~/.claude && rm -rf ~/.claude` (the tar lives outside `~` if you want extra safety). Backup retained for ~30 days post-Phase-1.
4. **Reset `~/.claude.json`**: write a minimal `{}` (or remove entirely; Claude regenerates on first launch). Loses per-project trust state on fragtnix; user will re-trust the harness directory once on first launch.
5. **Remove local clones** of `dotclaude`, `aitools-common` on fragtnix (the regime-supporting clones — they're re-cloneable from GitHub if ever needed). Keep `dotfiles` (chezmoi-managed) and any non-Claude repos. **Do NOT remove the dotfiles clone** — chezmoi needs it; we only want to stop it from spoiling `~/.claude/`.
6. **Verify clean state**: `ls ~/.claude/ 2>/dev/null` returns nothing; `cat ~/.claude.json` returns `{}`; `ls ~/airepos/common/` shows dotfiles intact, dotclaude/aitools-common gone.
7. **Document the procedure** in `harness/docs/transformation/Phase-1-prep-fragtnix-clean-slate.md` (committed during R0 close-out, executed when Phase 1 begins).

After clean-slate confirmation, proceed to Phase 1 Step 1: clone arechste/harness to fragtnix at `~/airepos/common/harness/`, paste ADAPTER-PROMPT.md into a fresh Claude session, watch it build its own shim layer from scratch. **If anything in the regime turns out to be needed, harness can re-establish it inside `harness/adapters/claude/` — that's exactly the test.**

**Phase 1 Step 1+: Build harness shell.** Folder tree, root AGENTS.md, ADAPTER-PROMPT.md, 13 agent contracts (Team/<callsign>/AGENTS.md), seed SOPs (routing + lifecycle), entity templates, install.sh, CI workflow. Bootstrap validation: paste ADAPTER-PROMPT in Claude, confirm shim generation works. **Existing 5 product repos still untouched.**

### Phase 2 — Populate harness (~2-4 sessions, bulk of work)
Write PORT content into harness from Phase 0 audit. WS-001 through WS-005 workstream files. Memory migration to Principal/. Migrate 184 tracker entries to harness/state/delegations/. **Existing repos still untouched** — harness is being filled, not the others emptied.

### Phase 3 — Claude adapter (~1-2 sessions)
harness/adapters/claude/ populated. aitools-common skills rewritten as thin pointers to harness SOPs (skill body = "Read SOP-XXX and follow it"). Hooks migrate. Plugin manifest reviewed. **aitools-common touches only.**

### Phase 4 — Validate end-to-end on fragtnix (~1-2 sessions)
Run real delegations through harness on fragtnix. Iterate on SOPs/contracts until smooth. ADR 030 written. **If anything breaks, only harness changes — existing repos still authoritative.**

### Phase 5a — Carve existing repos (~1 session per repo)
On `transformation/` branches in each of 5 repos: REMOVE content that ported, ADD pointers to harness, KEEP what stays. Merge each only when fragtnix-validated.

### Phase 5b — Deploy slimmed products per machine (~1 session per machine)
**Revised name** (was "cutover per machine"). Each non-workshop machine pulls the slimmed dotfiles + dotclaude that resulted from Phase 5a. Mechanism = existing distribution: chezmoi pulls latest dotfiles + dotclaude branches; Claude Code plugin marketplace auto-updates aitools-common. **harness is NOT cloned to non-workshop machines.** Workshop continues to run on fragtnix (primary) with merktnix as alternate. Order: fragtnix already validated → deploy slimmed dotfiles/dotclaude to one trial machine (tutnix or container) → confirm Claude sessions work normally with the new thin setup → roll forward to machtnix, CR61790DFV, merktnix.

---

## What we missed in earlier rounds (now addressed)

- **Conversion taxonomy**: explicit table mapping every source file type to its destination. Above.
- **Routing mechanics**: 8 routing SOPs named. Above.
- **Memory migration**: feedback → GL, source → Principal/Reference, user → Principal/.user.yaml. Above.
- **ADR migration boundary**: pre-Round-0 ADRs stay in dotclaude; ADR 030+ live in harness. Above.
- **Per-machine state**: `SOP-cutover-machine` standardizes. Above.
- **GitHub label drift**: audit covers it; Phase 3 ensures uniform label set across all 5 repos.
- **harness CI**: schema validation, SOP linting, dead-wikilink detection. Phase 1 deliverable.
- **Build-then-carve sequencing**: existing repos untouched through Phase 4; Phase 5a is the slim.
- **Rollback safety**: at every phase before 5a, `git checkout main` in harness is the rollback. Existing repos always authoritative until Phase 5a.

---

## Future concern (deferred — captured so it isn't lost)

**Concurrency & parallelism in the workshop.** Multiple Claude sessions can run simultaneously on the workshop machine, each booting into TOWER identity. Parallel work must not stomp each other.

Areas to design SOPs for, post-Phase-5:
- **Task-claim race**: `SOP-claim-task` already uses `git mv` (atomic per filesystem); two simultaneous claims = one wins, the other gets a non-zero exit and re-routes. Verify this assumption holds when multiple sessions are active.
- **State writes**: `harness/state/delegations/`, `harness/state/inventory/` — concurrent writes from parallel sessions need a discipline. Options: per-session worktree, file locks via `.lock` files at session-start, write-then-merge protocol.
- **Harness self-worktree**: each Claude session may create `.claude/worktrees/session-<id>/` of harness itself for isolation. Routing SOP defines when this is required (e.g., when editing shared Team Knowledge content).
- **Product-repo worktrees**: when a task touches `repos/<name>/`, the assigned agent creates a per-task worktree of that repo at `.claude/worktrees/task-<id>/`. Routing SOP names this protocol.
- **Branch ownership**: branches across the 5 product repos must be session-bound or task-bound to avoid two sessions pushing to the same branch.

Not blocking R0 close. Becomes a Phase 5+ SOP set. Flagged in the anchor issue.

## R0 close-out: execution sequence

The 5 execution steps for closing R0 (proposed):

1. **Create `arechste/harness` empty repo on GitHub.**
2. **Clone to `~/airepos/common/harness/` on merktnix** (this machine) — committing initial scaffold seed files. Real Phase 1 build happens on fragtnix later.
3. **File anchor issue** in `arechste/aitools-common`: `chore(arch): personal-infra-assistant transformation` with full R0 plan summary + link to harness repo.
4. **Commit ADR 030 stub** to dotclaude on a `transformation/` branch, linking to anchor issue and harness repo.
5. **Move plan** from `~/.claude/plans/...` to `harness/docs/transformation/round-0.md` (first commit on harness main).

Phase 0 begins in a new session.
