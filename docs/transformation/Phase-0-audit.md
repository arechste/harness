# Phase 0 Audit — Personal Infra Assistant Transformation

**Status:** Phase 0 complete (read-only inventory). No product-repo writes.
**Authored:** 2026-05-27 on merktnix, from `~/airepos/common/harness/`.
**Anchor:** `arechste/aitools-common#22`.
**Source plan:** [`round-0.md`](round-0.md) — applies its conversion taxonomy (§ "Conversion taxonomy", lines 92-108).

## Classification scheme

- **PORT** — content moves into `harness/`. Destination given.
- **KEEP-CLAUDE** — stays in its source repo as Claude-runtime / domain-expert content.
  - In `aitools-common`: the Claude plugin wrapper (skill shims, hooks runtime registration, plugin manifest).
  - In `dotclaude`: chezmoi-deployed runtime (settings.json.tmpl, hook scripts, agent shims, scheduled tasks).
  - In `git-organizer`: the git/forge domain-expert root (deep CLI patterns, tooling implementation).
  - In `mac-organizer` / fleet-organizer: per-machine inventory YAMLs, OS-specific scripts/plists, packages catalogue.
- **DROP** — obsolete, duplicate, ephemeral, or replaced by ADAPTER-PROMPT output.
- **REPO-LOCAL** — stays in source repo as repo infrastructure (LICENSE, README, CHANGELOG, CI, contributor templates) or repo-specific tooling.

Skill bodies are **split**: SOP body → `harness/Team Knowledge/SOPs/SOP-…`; Claude shim → `harness/adapters/claude/commands/<skill>.md`. Hooks are **dual**: file lives in `harness/adapters/claude/hooks/` (PORT), runtime registration stays in source repo (KEEP-CLAUDE).

## Repo-by-repo totals

| Repo | PORT | KEEP-CLAUDE | DROP | REPO-LOCAL | Items |
|---|---:|---:|---:|---:|---:|
| aitools-common | 28 | 16 | 5 | 6 | ~55 |
| dotclaude | 30 sources / 42 dest rows | 43 | 1 | ~185 | ~271 |
| dotfiles | 17 | 0 | 6 | ~130 | ~153 |
| git-organizer | ~12 clean + 8 SPLIT | ~8 | 0 | ~110 | ~140 |
| mac-organizer | 33 | 71 | 21 | 42 | 167 |

**Combined volume reduction projection** (round-0 § "Repo shape projections"): aitools-common ~70% smaller, dotclaude ~85% smaller (most content ports), git-organizer ~35% smaller, mac-organizer ~25% smaller, dotfiles unchanged.

---

## 1. aitools-common

Source: `~/airepos/common/aitools-common/`. Future rename → `aitools-claude` post-Phase 5.

| Path | Classification | Destination (if PORT) | Notes |
|---|---|---|---|
| **Top-level** | | | |
| `LICENSE`, `README.md`, `CHANGELOG.md`, `.gitignore` | REPO-LOCAL | — | Repo infra |
| `.claude/settings.local.json` | KEEP-CLAUDE | — | Local Claude session overrides |
| `.claude-plugin/plugin.json` | KEEP-CLAUDE | — | Plugin manifest; template copy → `adapters/claude/plugin-manifest.template` |
| `.claude-plugin/marketplace.json` | KEEP-CLAUDE | — | Private marketplace descriptor |
| `.github/pull_request_template.md`, `.github/workflows/validate.yml` | REPO-LOCAL | — | CI |
| `agents/.gitkeep`, `bin/.gitkeep`, `commands/.gitkeep`, `scripts/.gitkeep`, `skills/.gitkeep` | DROP | — | Empty placeholders |
| **data/** | | | |
| `data/command-map.yaml` | PORT | `harness/Team Knowledge/Workstreams/WS-routing.md` | TOWER routing per R0 taxonomy |
| `data/repo-inventory.json` | PORT | `harness/Team Knowledge/Templates/repo.template.md` + `harness/state/inventory/<repo>.md` (per entry) | Fleet metadata wrap |
| `data/delegated-issues.json` | PORT | `harness/state/delegations/open/` (one MD per issue) | Active delegation state |
| `data/fleet-context.md` | PORT | `harness/Team Knowledge/Guidelines/GL-NNN-fleet-context.md` | Shared fleet rules |
| `data/home-write-guard-paths.json` | PORT | `harness/adapters/claude/hooks/` (companion data) | Travels with hook |
| `data/sync-conventions-config.json` | KEEP-CLAUDE | — | Plugin-local sync target config |
| `data/references/source_memory_consolidation.json` | PORT | `harness/Principal/Reference/source-memory-consolidation.md` | Source ref per taxonomy |
| `data/schemas/delegated-issues.schema.json` | PORT | `harness/ci/schemas/delegated-issues.schema.json` | Validation in harness CI |
| `data/schemas/delegation-inbox.schema.json` | PORT | `harness/ci/schemas/delegation-inbox.schema.json` | |
| `data/schemas/repo-inventory.schema.json` | PORT | `harness/ci/schemas/repo-inventory.schema.json` | |
| `data/schemas/sync-conventions-config.schema.json` | KEEP-CLAUDE | — | Pairs with config |
| **hooks/** | | | |
| `hooks/hooks.json` | KEEP-CLAUDE | — | Claude Code hooks registration manifest |
| `hooks/pre-tool-use-home-write-guard.sh` | PORT (verbatim) | `harness/adapters/claude/hooks/` | Original also KEEP-CLAUDE |
| `hooks/pre-tool-use-remote-exec-guard.sh` | PORT (verbatim) | `harness/adapters/claude/hooks/` | Same |
| `hooks/session-start-deferred-claude-ai-drift.sh` | PORT (verbatim) | `harness/adapters/claude/hooks/` | Same |
| `hooks/session-start-deferred-fleet.sh` | PORT (verbatim) | `harness/adapters/claude/hooks/` | Same |
| **skills/** (all F-tier — split body + shim) | | | |
| `skills/audit/SKILL.md` | PORT (split) | body → `SOPs/SOP-audit-conventions.md`; shim → `adapters/claude/commands/audit.md` | |
| `skills/batch/SKILL.md` | PORT (split) | body → `SOPs/SOP-batch-issues.md`; shim → `adapters/claude/commands/batch.md` | |
| `skills/delegate/SKILL.md` | PORT (split) | body → `SOPs/SOP-file-delegation.md`; shim → `adapters/claude/commands/delegate.md` | Maps to Phase 1 seed SOP |
| `skills/delegation-respond/SKILL.md` | PORT (split) | body → `SOPs/SOP-respond-delegation.md`; shim → `adapters/claude/commands/delegation-respond.md` | |
| `skills/health/SKILL.md` (+ references/config-checks.md, references/repo-checks.md) | PORT (split + appendices) | body → `SOPs/SOP-check-health.md`; references → SOP appendices or `Guidelines/GL-NNN-health-*.md`; shim → `adapters/claude/commands/health.md` | |
| `skills/ship/SKILL.md` | PORT (split) | body → `SOPs/SOP-ship-release.md`; shim → `adapters/claude/commands/ship.md` | |
| `skills/suggest/SKILL.md` | PORT (split) | body → `SOPs/SOP-suggest-tooling.md`; shim → `adapters/claude/commands/suggest.md` | |
| `skills/sync-conventions/SKILL.md` | PORT (split) | body → `SOPs/SOP-sync-conventions.md`; shim → `adapters/claude/commands/sync-conventions.md` | |
| `skills/triage/SKILL.md` | PORT (split) | body → `SOPs/SOP-triage-issues.md`; shim → `adapters/claude/commands/triage.md` | |
| `skills/work/SKILL.md` | PORT (split) | body → `SOPs/SOP-work-issue.md`; shim → `adapters/claude/commands/work.md` | |
| **skills/shared/** (per R0 taxonomy explicit mapping) | | | |
| `skills/shared/delegation-protocol.md` | PORT | `harness/Team Knowledge/SOPs/SOP-file-delegation.md` (merge/include) | Taxonomy: delegation-protocol → SOPs |
| `skills/shared/label-taxonomy.md` | PORT | `harness/Team Knowledge/Guidelines/GL-NNN-label-taxonomy.md` | Taxonomy: → GL |
| `skills/shared/test-framework-detection.md` | PORT | `harness/Team Knowledge/Guidelines/GL-NNN-test-framework-detection.md` | Taxonomy: → GL |
| `skills/shared/git-workflow.md` | PORT | `harness/Team Knowledge/Guidelines/GL-NNN-git-workflow.md` | Cross-skill fragment |
| `skills/shared/repo-root.md` | PORT | `harness/Team Knowledge/Guidelines/GL-NNN-repo-root.md` | |
| `skills/shared/repo-standards.md` | PORT | `harness/Team Knowledge/Guidelines/GL-NNN-repo-standards.md` | |

---

## 2. dotclaude

Source: `~/airepos/common/dotclaude/`. Post-Phase-5a target: ~500 lines (chezmoi runtime + pre-030 ADRs + thin CLAUDE.md pointer).

### High-volume PORT clusters

**`home/rules/*.md`** — all 7 PORT to `harness/Team Knowledge/Guidelines/GL-NNN-<topic>.md`:
`claude-operations.md`, `code-of-conduct.md`, `coding-standards.md`, `execution.md`, `git-conventions.md`, `safety.md`, `tone-concise.md`.

**`home/memory/feedback_*.md`** — all 3 PORT to `harness/Team Knowledge/Guidelines/GL-NNN-feedback-<topic>.md`:
`feedback_bash_no_compound.md`, `feedback_chrome_mcp.md`, `feedback_op_syntax.md`.

**`home/memory/source_*.md`** — all 9 PORT to `harness/Principal/Reference/<topic>.md`:
`source_agent_patterns.md`, `source_claude_code_features.md`, `source_claude_code_permissions.md`, `source_claude_models.md`, `source_compaction_api.md`, `source_folder_trust.md`, `source_official_docs.md`, `source_settings_permissions.md`, `source_surfaces.md`.

**`home/skills/<skill>/SKILL.md`** — all 9 U-tier PORT (split: body → SOPs/, shim → adapters/claude/commands/):
`ci-check`, `commit`, `explain`, `gh-workflow`, `recover`, `research`, `review`, `test-gen`, `test-run`.

**`.claude/skills/<skill>/SKILL.md`** — 7 project-scope skills, all PORT (split):
`canary`, `drift`, `scout` (+ 7 `references/*.md` stay KEEP-CLAUDE colocated with shim), `skill-create`, `skill-manage`, `sync`, `upstream`.

**`data/command-map.yaml`** — PORT to `harness/Team Knowledge/Workstreams/WS-routing.md`.

### Other notable items

| Path | Classification | Destination (if PORT) | Notes |
|---|---|---|---|
| `home/CLAUDE.md` | DROP | — | Replaced by thin pointer generated by ADAPTER-PROMPT |
| `home/settings.json.tmpl`, `home/commit-trailer.json`, `home/keybindings.json`, `home/statusline-command.sh`, `home/version-baseline`, `home/claude_desktop_config.json.tmpl` | KEEP-CLAUDE | — | chezmoi runtime |
| `home/agents/implementer.md`, `home/agents/planner.md` | KEEP-CLAUDE | — | U-scope subagent defs; no skill split (not SKILL.md). Re-evaluate in Phase 3 — likely shim regen in adapters/claude/agents/ |
| `home/hooks/*.sh` (16 hook scripts) | KEEP-CLAUDE | — | chezmoi-deployed runtime hooks; stay in dotclaude. Counterpart hooks in aitools-common ARE ported (different distribution model) |
| `home/memory/MEMORY.md`, `home/memory/REFERENCE.md` | KEEP-CLAUDE | — | Loader/index files, not content |
| `home/scripts/*` (bootstrap-dotclaude.sh, claude-container.sh, claude-session.sh, dotclaude-deploy.sh, layouts/*.kdl) | KEEP-CLAUDE | — | chezmoi deploy machinery |
| `docs/decisions/001-…029-….md` (29 ADRs, pre-030) | KEEP-CLAUDE | — | Migration boundary per R0 |
| `docs/{conventions,guides,initiatives,patterns,plans,reference,research,upstream,workflows}/*` (~120 files) | REPO-LOCAL | — | dotclaude-specific dev/operator docs |
| `docs/reference/chezmoi-conventions.md` | KEEP-CLAUDE | — | chezmoi runtime docs |
| `scripts/`, `tools/` (CI + ops scripts, ~30 files) | REPO-LOCAL | — | dotclaude-specific tooling |
| `tools/settings-render.sh` | KEEP-CLAUDE | — | chezmoi-adjacent |
| `templates/*` (~85 files: autonomous/, container/, data-science/, default/, monorepo/, new-project/, retrofit/, routine-prompt/, strict/, wat/) | REPO-LOCAL | — | Project scaffold templates |
| `data/move-list.yaml` | KEEP-CLAUDE | — | Phase 0 transformation artifact; retire post-migration |
| `.claude/settings.json`, `.claude/settings.local.json`, `.claude/scheduled_tasks.lock` | KEEP-CLAUDE | — | Project Claude state |
| `.claude/rules/*.md` (delegation, monorepo-conventions, planning-artifacts, session-protocol, team-model, workflow) | REPO-LOCAL | — | dotclaude project-scope rules (dev context) |
| `.devcontainer/`, `.github/`, `.pre-commit-config.yaml`, `.actrc`, `LICENSE`, `README.md`, `CHANGELOG.md`, `CODEOWNERS`, `CONTRIBUTING.md`, `SECURITY.md`, `REQUIRES`, `mise.toml` | REPO-LOCAL | — | Repo infra |

---

## 3. dotfiles

Source: `~/airepos/common/dotfiles/`. Round-0 says: largely unchanged. The PORT list below is the "few rule-doc files" called out.

### PORT items (cross-cutting knowledge that other repos depend on)

| Path | Destination | Notes |
|---|---|---|
| `.claude/CROSS_PROJECT_ARCHITECTURE.md` | `harness/Team Knowledge/Guidelines/GL-NNN-cross-project-architecture.md` | Read/write boundaries, delegation pattern, permission model across all repos |
| `.claude/rules/delegation.md` | `harness/Team Knowledge/Guidelines/GL-NNN-delegation.md` (or merge with delegation SOPs) | Cross-cutting delegation state machine |
| `docs/conventions/workspace-management.md` | `harness/Team Knowledge/Guidelines/GL-NNN-workspace-management.md` | Marked as mirrored from git-organizer (canonical lives there — see git-organizer SPLIT for workspace-and-fleet.md) |
| `docs/decisions/ADR-002-three-repo-ownership-model.md` | `harness/docs/decisions/historical/dotfiles-ADR-002.md` (or Reference) | Cross-stack ownership boundaries |
| `docs/decisions/ADR-007-credential-management-ownership.md` | `harness/docs/decisions/historical/dotfiles-ADR-007.md` (or `Principal/Reference/`) | Canonical credential stack (op, 1Password, gh, sops) |
| `docs/decisions/ADR-009-session-broker-pattern.md` | `harness/docs/decisions/historical/dotfiles-ADR-009.md` | OP_SESSION broker / 12h TTL — affects all Claude sessions. Pre-030 → boundary applies; mirror as historical reference in harness |
| `docs/decisions/ADR-010-per-project-secrets.md` | `harness/docs/decisions/historical/dotfiles-ADR-010.md` | Per-project secrets convention (op vs sops) |
| `docs/reference/dotclaude-pin-lifecycle.md` | `harness/Principal/Reference/dotclaude-data-contract.md` | dotfiles↔dotclaude convergence model |
| `docs/reference/glossary.md` | `harness/Principal/Reference/glossary.md` (merge with harness glossary) | Shared vocabulary; extends dotclaude glossary |
| `docs/reference/permission-tiers.md` | `harness/Principal/Reference/permission-tiers.md` | Autonomy levels apply to all repos |
| `docs/reference/repo-ownership.md` | `harness/Principal/Reference/repo-ownership.md` | Canonical repo authority table |
| `docs/guides/git-worktrees.md` | `harness/Team Knowledge/Guidelines/GL-NNN-git-worktrees.md` | Cross-repo worktree lifecycle and multi-session safety |
| `docs/guides/session-coordination.md` | `harness/Team Knowledge/Guidelines/GL-NNN-session-coordination.md` | Multi-session coordination, claiming, cross-machine |
| `docs/security/access-matrix.md` | `harness/Principal/Reference/access-matrix.md` | Interactive vs headless actor model |
| `docs/security/claude-code-permissions.md` | `harness/Principal/Reference/claude-code-permissions.md` | Permission layer model |
| `docs/security/per-project-secrets.md` | `harness/Team Knowledge/Guidelines/GL-NNN-per-project-secrets.md` | Cross-cutting (paired with ADR-010) |
| `docs/security/secrets-conventions.md` | `harness/Team Knowledge/Guidelines/GL-NNN-secrets-conventions.md` | Storage/scanning/.env/deny patterns |

**Note on ADRs:** Per R0, "pre-Round-0 ADRs stay in dotclaude" — but dotfiles also holds ADRs. Treat dotfiles' ADRs as REPO-LOCAL canonical; PORT items above are *mirrored references* in harness (read-only copies under `docs/decisions/historical/` or `Principal/Reference/`) to keep cross-stack discoverability. To revisit in Phase 2 when ADR migration boundary is finalized.

### DROP

| Path | Notes |
|---|---|
| `data/delegated-issues.json`, `data/delegation-inbox.json` | Runtime state; supplanted by `harness/state/delegations/` |
| `plans/README.md` | Pointer-only; use GitHub issues |
| `docs/roadmap.md` | Ephemeral; use GitHub milestones |
| `scripts/sync-to-umbrella.sh`, `tools/ci/test-sync-to-umbrella.sh` | One-time migration artifacts |
| `.claude/settings.local.json`, `.claude/scheduled_tasks.lock` | Machine-local ephemeral |

### REPO-LOCAL (~130 items)

All chezmoi templates (`dot_*`, `private_dot_*`, `private_Library/`, `private_Pictures/`, `run_once_*`, `symlink_dot_*`, `.chezmoi*`), `Brewfile`, `mise.toml`, `vscode-extensions.txt`, `VERSION`, packages/{debian,rhel}.list, all scripts/ (bootstrap, doctor, sync, brew-reconcile, fleet/*, lib/*, workspace/ws, etc.), all docs/{getting-started,guides,images,machines,reference,security,tools}/ except the PORT list above, `.config/fabric/*`, `.github/workflows/*`, repo infra (LICENSE/README/CHANGELOG/etc.), `.claude/{rules/fleet-ssh.md,settings.json,agents/.gitkeep,skills/.gitkeep}`.

**No KEEP-CLAUDE in dotfiles** — dotfiles isn't a Claude-specific repo; all chezmoi machinery is REPO-LOCAL.

---

## 4. git-organizer

Source: `~/airepos/common/git-organizer/`. Post-Phase-5a target: ~35% smaller. Strategy: SPLIT each convention doc — extract cross-repo orchestration to harness; retain git/forge-specific depth as KEEP-CLAUDE.

### Clean PORT (data + templates)

| Path | Destination | Notes |
|---|---|---|
| `data/label-definitions.json` | `harness/state/inventory/label-definitions.json` (or `Team Knowledge/Templates/`) | 38 canonical labels — cross-repo SSOT |
| `data/repo-inventory.json` | `harness/state/inventory/<repo>.md` per entry (R0-Q8) | Fleet metadata |
| `data/delegated-issues.json` | `harness/state/delegations/` per-issue MD (R0-Q8) | 184 tracker entries |
| `data/delegation-inbox.json` | `harness/state/delegations/open/` | Inbound delegations |
| `data/command-map.yaml` | `harness/Team Knowledge/Workstreams/WS-routing.md` | Routing SSOT per R0 taxonomy |
| `data/agent-roles.json` | `harness/Team/agent-index.md` | Maps to harness agent roster |
| `data/machine-groups.json` | `harness/state/inventory/machine-groups.json` | Fleet topology |
| `docs/contracts/dotclaude.md`, `docs/contracts/dotfiles.md` | `harness/Team Knowledge/Workstreams/WS-004-git-conventions.md` (or pointers) | Cross-repo boundary contracts |
| `templates/github/community-health/{CODE_OF_CONDUCT,CONTRIBUTING,SECURITY}.md` | `harness/Team Knowledge/Templates/github-community-health/` | Synced canonicals |
| `templates/github/issue-templates/{bug_report,feature_request,config}.yml` | `harness/Team Knowledge/Templates/github-issue-templates/` | Synced canonicals |
| `templates/github/pull_request_template.md` | `harness/Team Knowledge/Templates/github-pull_request_template.md` | Synced canonical |

### SPLIT (each convention doc — cross-repo extract + git-specific retain)

| Convention doc | PORT extract → harness | KEEP-CLAUDE retain |
|---|---|---|
| `docs/conventions/cross-repo.md` | Delegation protocol + fleet sync → `SOPs/SOP-delegate-issue.md`; CI validation → `Guidelines/GL-NNN-cross-repo-ci-validation.md` | Read-path rules, gh patterns |
| `docs/conventions/labels-and-issues.md` | Label taxonomy (38 labels) → `Guidelines/GL-NNN-label-taxonomy.md`; machine-label resolver → `Guidelines/GL-NNN-machine-labels.md`; issue hierarchy → `Guidelines/GL-NNN-issue-hierarchy.md` | Ledger issues, Projects v2 details |
| `docs/conventions/merge-lifecycle.md` | Merge policy table + escalation triggers + PR-as-gate → `SOPs/SOP-merge-pr.md` | patch-id algorithm, complete-merge.sh, squash detection |
| `docs/conventions/pr-review.md` | Review tiers (Skim/Read/Verify/Block) + PR banner + pause triggers → `Guidelines/GL-NNN-pr-review-tiers.md` | govern-closure.sh, wired signals |
| `docs/conventions/planning.md` | Working loop (Plan→Release) + artifact tiers + per-repo placement → `SOPs/SOP-working-loop.md` | `/schedule` governance specifics |
| `docs/conventions/meta-governance.md` | Commit format + trailer + squash rule → `Guidelines/GL-NNN-commit-format.md`; forge abstraction generic → `Guidelines/GL-NNN-forge-abstraction.md` | Adoption modes, promotion protocol |
| `docs/conventions/release-pipeline.md` | Semver bump + release-parity (tag↔release↔CHANGELOG) → `Guidelines/GL-NNN-release-versioning.md` | Deploy-from-tags, consumer flow |
| `docs/conventions/repo-standards-security.md` | Maturity dimensions → `Guidelines/GL-NNN-repo-maturity.md`; security baseline → `Guidelines/GL-NNN-security-baseline.md`; secrets audit → `Guidelines/GL-NNN-secrets-audit.md` | Permission matrix, Renovate governance |
| `docs/conventions/scheduling.md` | Schedule governance decision matrix → `Guidelines/GL-NNN-schedule-governance.md` | CLI execution standard (git/gh/API depth) |
| `docs/conventions/workspace-and-fleet.md` | Directory layout (`~/repos/` vs `~/airepos/`) → `Guidelines/GL-NNN-workspace-layout.md`; fleet distribution model → merge with cross-repo extract | Worktree lifecycle, temp-files, `ws` tooling |

### KEEP-CLAUDE (git-organizer as domain expert)

`docs/conventions/{ci-and-tooling,github-platform,code-style}.md`, `docs/conventions/README.md`, all of `workflows/*.md` (audit, ci, delegation, forge-portability, gists, issues, label-sync, milestones, projects, prs, releases, repos), all of `actions/`, all of `data/schemas/*` (schema authority), `data/{forge-index,ci-budget,ci-workflow-audit,reference-index,gist-inventory,*-report,*-cycles,repo-health-checks}.json` (operational state), `data/references/source_*.json` (git domain research cache), `renovate/default.json` preset, all `.claude/{settings,agents,rules,skills,scheduled_tasks.lock}` runtime configs.

### REPO-LOCAL

All `tools/{audit,ci,git-hooks,labels,lib,maintenance,workspace}/*.sh`, `tools/install-hooks.sh`, `tools/lib/tests/*`, all of `docs/{audit,checklists,decisions,guides,initiatives}/` (per-repo ADRs d1–d3, e, internal guides), `docs/{README,OVERVIEW,COLLABORATING,inventory,permissions-reference,wat-framework,workflow-lifecycle}.md`, `templates/routine-prompt/monthly-self-audit.md`, repo infra files.

---

## 5. mac-organizer (→ fleet-organizer in Phase 5a)

Source: `~/airepos/common/mac-organizer/`. Rename + `os:` field scope expansion happen in Phase 5a per R0-Q7.

### PORT — orchestration SOPs and standards

**docs/ (top-level):**
| Path | Destination |
|---|---|
| `docs/age-key-setup.md` | `harness/Team Knowledge/SOPs/SOP-age-key-setup.md` |
| `docs/attended-runbooks.md` | `harness/Team Knowledge/SOPs/SOP-attended-runbooks.md` |
| `docs/browser-policy.md` | `harness/Team Knowledge/Guidelines/GL-NNN-browser-policy.md` |
| `docs/delegation-map.md` | `harness/Team Knowledge/Workstreams/WS-003-fleet.md` (or SOPs/) |
| `docs/fleet-assessment-2026-03.md` | `harness/Team Knowledge/session-logs/` (or `Principal/Journal/`) |
| `docs/fleet-overview.md` | `harness/Team Knowledge/Workstreams/WS-003-fleet.md` |
| `docs/github-auth.md` | `harness/Team Knowledge/SOPs/SOP-github-auth.md` |
| `docs/permissions.md` | `harness/Team Knowledge/Guidelines/GL-NNN-agent-permissions.md` |
| `docs/remote-delivery.md` | `harness/Team Knowledge/SOPs/SOP-remote-delivery.md` |
| `docs/role.md` | `harness/Team/RANGER - SysAdmin/AGENTS.md` |
| `docs/startup-protocol.md` | `harness/Team Knowledge/SOPs/SOP-startup-protocol.md` |
| `docs/trusted-sources.md` | `harness/Team Knowledge/Guidelines/GL-NNN-trusted-sources.md` |
| `docs/wat-framework.md` | `harness/Team Knowledge/Guidelines/GL-NNN-wat-framework.md` |

**docs/standards/** — all 3 PORT to `harness/Team Knowledge/Guidelines/`:
`maintenance-baseline.md`, `security-baseline.md`, `update-policy.md`.

**docs/research/claude-signing-keys.md** → `harness/Principal/Reference/claude-signing-keys.md`.

**docs/plans/fleet-readiness.md** → `harness/Team Knowledge/tasks/done/<YYYY>/<MM>/` (completed task wrap).

**data/** — all 3 PORT:
| Path | Destination |
|---|---|
| `data/delegated-issues.json` | `harness/state/delegations/` (per-issue MD) |
| `data/delegation-inbox.json` | `harness/state/delegations/open/` |
| `data/runbook-log.jsonl` | `harness/state/` or `Team Knowledge/session-logs/` |

**workflows/** — 6 of 12 PORT (cross-machine orchestration):
| Path | Destination |
|---|---|
| `workflows/corp-laptop-auth-checklist.md` | `harness/Team Knowledge/SOPs/SOP-corp-laptop-auth.md` |
| `workflows/corp-laptop-onboard.md` | `harness/Team Knowledge/SOPs/SOP-corp-laptop-onboard.md` |
| `workflows/decommission-machine.md` | `harness/Team Knowledge/SOPs/SOP-decommission-machine.md` |
| `workflows/maintenance.md` | `harness/Team Knowledge/SOPs/SOP-fleet-maintenance.md` |
| `workflows/new-machine-setup.md` | `harness/Team Knowledge/SOPs/SOP-new-machine-setup.md` |
| `workflows/rename-machine.md` | `harness/Team Knowledge/SOPs/SOP-rename-machine.md` |
| `workflows/security-audit.md` | `harness/Team Knowledge/SOPs/SOP-security-audit.md` |

### KEEP-CLAUDE — stays in fleet-organizer as OS/inventory/tooling domain expert (~71)

- `inventory/{CR61790DFV,fragtnix,jk23gwgwp0,machtnix,merktnix,tutnix}.yaml` — per-machine facts; `harness/state/inventory/<host>.md` wraps each
- `tools/*.py` and `tools/*.sh` (all 29 — app/disk/storage/security/privacy audits, brew_sync, fleet_compare, fleet_dashboard, notify, runbook executor, reencrypt-inventory, etc.); `tools/lib/{__init__,remote}.py`; `tools/machine-registry.yaml`
- `packages/{ai,apps,containers,data,dev,fonts,git,infra,media,networking,security,shell,system}.yaml` — package catalogue
- `infra/*.plist`, `infra/maintenance-runner.sh`, `infra/mirror-backup/{*.plist,refresh.sh,verify.sh,coverage.txt,README.md}`
- `docs/{app-config-inventory,hostname-registry,inventory-schema,mirror-backup,sops-workflow,tool-choices}.md`
- `docs/conventions/dc-fleet-state-schema.md`
- `docs/references/privacy-tcc.md`, `docs/research/macos-security-model.md`
- `docs/troubleshooting/{tailscale-name-inversion,upgrade-drift}.md`
- `workflows/{inventory-update,logi-flow-recovery,nixadmin-setup,subnet-router-setup,tailscale-bootstrap}.md`
- `Brewfile`, `.sops.yaml`

### DROP (~21)

- `docs/conventions/{adopting-ci,commit-format,cross-repo-automation,dependency-management,forge-abstraction,label-taxonomy,local-ci,repo-standards,security-baseline,semver,skill-architecture,temp-files,triage-skill,workspace-management}.md` — **15 convention files duplicated from git-organizer**; replaced by harness references to git-organizer canonicals via the SPLIT extracts above
- `.mypy_cache/`, `.pytest_cache/`, `.ruff_cache/`, `.tmp/`, `.venv/`, `tests/__pycache__/`, `tools/__pycache__/` — build artifacts

### REPO-LOCAL (~42)

- All `tests/*.py` (24 test files + conftest.py)
- Repo infra (`LICENSE`, `README.md`, `CHANGELOG.md`, `CODEOWNERS`, `CONTRIBUTING.md`, `SECURITY.md`, `mise.toml`, `pyproject.toml`, `uv.lock`, `renovate.json`, `.actrc`, `.gitignore`, `.pre-commit-config.yaml`)
- `CLAUDE.md`, `.claude/` (replaced by harness adapter pointer in 5a, but content stays REPO-LOCAL meanwhile)
- `.github/{ISSUE_TEMPLATE,pull_request_template.md}`
- `scripts/git-hooks/pre-push`, `tools/ci/local-check.sh`
- `docs/roadmap.md`

---

## Cross-repo observations & open questions

1. **Three `command-map.yaml` files** (aitools-common, dotclaude/data, git-organizer/data) all PORT to the same destination `harness/Team Knowledge/Workstreams/WS-routing.md`. Phase 2 must reconcile — likely git-organizer is canonical (R0-Q10 forge-as-mirror), other two are mirrors that get deleted in Phase 5a.
2. **Four `delegated-issues.json`** (aitools-common, dotfiles/data, git-organizer/data, mac-organizer/data). Same — converge to single harness state tree (R0-Q8). 184 tracker entries.
3. **Hook duplication:** dotclaude/home/hooks and aitools-common/hooks both contain `pre-tool-use-home-write-guard.sh` and `pre-tool-use-remote-exec-guard.sh`. Distinct distribution paths (chezmoi vs plugin) but same content. Phase 3: pick one as canonical in `harness/adapters/claude/hooks/`, regenerate both deployments from it.
4. **15 git-organizer convention files duplicated in mac-organizer/docs/conventions/** — all DROP. Cleanest single win in the audit.
5. **dotfiles ADR boundary:** Round-0 sets the pre-030 boundary at *dotclaude*. dotfiles also holds ADRs (001–010). Decision needed in Phase 2: either widen the boundary to include all pre-existing ADRs across all repos, OR allow dotfiles ADRs to remain REPO-LOCAL canonical with selected ones mirrored into `harness/docs/decisions/historical/` (current Phase 0 default).
6. **Skill conflict — `delegate` vs `file-delegation`:** aitools-common/skills/delegate → SOP-file-delegation.md. The shared fragment `delegation-protocol.md` should merge into the same SOP rather than create a sibling.
7. **`canary` skill destination unverified:** dotclaude `.claude/skills/canary` classified PORT (split) but content unread; confirm U-tier vs project-scope in Phase 2 before splitting.
8. **`home/agents/{implementer,planner}.md`** — not skills, but subagent definitions. Phase 3 should regenerate equivalents under `adapters/claude/agents/` from the 13 harness agent contracts (per R0 agent roster); keep originals KEEP-CLAUDE until then.
9. **CLAUDE.md at every repo root** is REPO-LOCAL for now; Phase 5a may replace each with a thin pointer to harness via ADAPTER-PROMPT output.
10. **No KEEP-CLAUDE in dotfiles** — confirms dotfiles is a chezmoi/system-config repo, not a Claude-runtime repo. Distribution stays via chezmoi.

## Phase 0 exit criteria

- [x] All 5 repos inventoried (1 sample for `aitools-common`, full or near-full for others).
- [x] Every item assigned PORT / KEEP-CLAUDE / DROP / REPO-LOCAL.
- [x] PORT destinations specified per round-0 conversion taxonomy.
- [x] Cross-repo duplicates flagged for reconciliation.
- [x] Open questions surfaced for Phase 2 resolution.
- [x] Existing repos untouched (read-only audit).

Phase 1 prerequisite: clean-slate fragtnix per [`Phase-1-prep-fragtnix-clean-slate.md`](Phase-1-prep-fragtnix-clean-slate.md).
