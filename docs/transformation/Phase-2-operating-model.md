# Phase 2 — Operating Model (proposal)

**Status:** PROPOSAL for principal review — **not ratified**. Drafted 2026-05-29 by TOWER,
grounded in `round-0.md` (design), `Phase-0-audit.md` (inventory), and a deep read of
dotclaude's `home/rules/`, `home/memory/`, `.claude/rules/`. It **supersedes the file-by-file
"PORT" framing** of Phase 2 with an intent-first, domain-organized model.

**Why this exists:** The principal asked the team to first demonstrate it *understands how the
current system is built*, then propose *how harness will work* and *what to remove / change /
delete in the repos* — with **minimal disruption** during ramp-up. Trust precedes execution.

**Ratified (2026-05-29):**
- §3d **delegation reorg APPROVED** — harness task/delegation system becomes the coordination plane;
  GitHub issues become the external mirror only when work lands in a product repo.
- §6 Q5 **pilot domain = dotclaude** (AI runtime / `~/.claude`). The team runs the
  intent-mine → goals-interview → agnostic-author loop here first as the reference implementation.

---

## 1. How it works today (as-is)

**Coordination — a "chief of staff" hierarchy** (`dotclaude/.claude/rules/team-model.md`):
`Human (master) → dotclaude (Claude infra, governance, orchestration) → domain-expert repos`:

- **dotfiles** — machine foundation: shell, packages, chezmoi deployment
- **git-organizer** — git/GitHub domain expert: conventions, labels, CI, audits (the real convention SSOT)
- **mac-organizer** — macOS domain expert: system mgmt, app config, health
- **aitools-common** — the Claude Code plugin that distributes skills + hooks to every machine

**Governance lives *in the repos, as Claude-specific content*:**
- Behavioral rules: `dotclaude/home/rules/*.md`, loaded via `~/.claude/CLAUDE.md` `@rules`
- Memory: `dotclaude/home/memory/` (`feedback_*`, `source_*`)
- Conventions: `git-organizer/docs/conventions/*` is canonical; others mirror it — hence the
  duplication the audit found (15 convention files copied into mac-organizer; 3 `command-map.yaml`;
  4 `delegated-issues.json` trackers)
- Delegation: **GitHub issues are the coordination plane.** Cross-repo work = file an issue in the
  target repo (`delegate-issue.sh`), state machine `filed→ack→wip→review→done`, tracked per-repo,
  labels `delegation/*` + `agent/*`. dotclaude/dotfiles auto-merge; organizers are co-op (human merges).

**Distribution:** chezmoi pushes dotfiles + dotclaude to all machines; the plugin marketplace pushes
aitools-common; the organizers are cloned only where their tooling runs.

The whole operating model is **coupled to Claude** — rules, memory, hooks, settings, `/dc:` skills,
the commit-trailer convention, the decision heuristics. It works, but it cannot govern a non-Claude
tool, and "who decides what" is spread across four repos.

---

## 2. The shift (thesis)

Move the **operating model** — identity, roles, decision rules, conventions, delegation, memory —
*out of the repos and into harness, expressed tool-agnostically*. Repos demote to what must
physically live there to be deployed: **scripts, config/templates, runtime, and how-it-works docs.**
Organize the team by **domain of expertise** (callsigns / workstreams), not by repo.

> **Today:** governance is Claude-specific and repo-distributed.
> **Target:** governance is tool-agnostic and harness-central; repos hold artifacts only.

---

## 3. To-be operating model

### 3a. Organize by domain of expertise, not repo
A domain is owned by a callsign and may draw artifacts from several repos.

| Domain (workstream) | Expertise owner | Repos storing its artifacts |
|---|---|---|
| Homedir + user environment across machines | FORGE (DevOps) | dotfiles |
| Tool config & AI runtime (`~/.claude`, prefs, settings) | RELAY (AI Tooling) | dotclaude, aitools-common |
| Fleet — mac / linux / containers / VMs | RANGER (SysAdmin) | mac → fleet-organizer |
| Forge — git / gh / other | CASCADE (GitOps) | git-organizer |
| Future: network/tailscale, homelab, browser | hire via SCOUT | new repos as needed |

### 3b. harness holds the operating model (the "why / how-we-decide" layer)
- **Identity + roles:** `AGENTS.md`, the 13 callsigns
- **SSOT:** SOPs (procedures), Guidelines (standing rules — tool-agnostic), Workstreams (multi-domain flows), Templates
- **State:** tasks, delegations, inventory — file-primary
- **Memory:** durable principal/team knowledge (replacing `dotclaude/home/memory/`)
- **Adapters:** the *only* tool-specific layer — `adapters/claude/` renders harness SSOT into what
  Claude needs (CLAUDE.md pointer, subagent shims, command shims, hooks). Future: `adapters/cursor/`, …

### 3c. Repos hold the artifact / deployment layer (the "what physically ships")
chezmoi sources + templates (dotfiles); `settings.json.tmpl` + runtime hooks (dotclaude); per-machine
inventory YAML + OS scripts (fleet); domain tooling + CI templates (git-organizer); plugin manifest +
skill shims (aitools-common). Plus minimal docs describing the artifacts themselves.

### 3d. Control & delegation reorganizes
The GitHub-issue-between-repos model is replaced by **harness's task/delegation system as the
coordination plane** (file-primary SSOT). TOWER routes a task to a callsign by required expertise;
GitHub issues become the **external mirror** only when work actually lands in a product repo
(forge-as-mirror, R0-Q10). "Repo A delegates to repo B" becomes "TOWER assigns the task to the right
expertise." *This is the largest behavioral change and needs explicit sign-off.*

---

## 4. What moves / stays / deletes in the repos

The split is **by layer, not by file**:

- **Move OUT → harness** (intent/governance): behavioral rules, cross-repo conventions, delegation
  protocol + label taxonomy, decision heuristics, feedback/source memory, SOP bodies, routing.
- **STAYS in repo** (artifact/deployment): chezmoi templates, `settings.json.tmpl`, runtime hooks,
  per-machine inventory, domain scripts/tools, plugin manifest, repo infra (LICENSE/CI/README).
- **DELETE** (duplication/obsolete): 15 git-convention files duplicated in mac-organizer; 3
  `command-map.yaml` → 1; 4 `delegated-issues.json` → harness state; one-time migration scripts;
  Claude docs superseded by harness SSOT.

**Worked example — dotclaude (the principal's own example):** `home/rules/`, `home/memory/`,
`home/CLAUDE.md` move to harness (rules → Guidelines; memory → `Principal/Reference/` + team memory;
CLAUDE.md → generated thin pointer). dotclaude keeps `settings.json.tmpl`, the chezmoi runtime, the
deploy scripts, and pre-030 ADRs. Net: dotclaude shrinks to runtime + a pointer.

---

## 5. Minimal-disruption ramp

The build-then-carve safety property (R0-Q11) is what makes "take over operations" safe:

1. **Additive first.** harness gains the governance (we author the agnostic SSOT) while every repo
   keeps working *exactly* as today. Nothing is removed.
2. **Validate on one host.** fragtnix proves harness can run real work and substitute the old regime
   (round-0 Phase 4).
3. **Subtractive later, per repo, behind the gate.** Only after validation does Phase 5a carve a repo
   — remove what moved, leave a pointer. Rollback = `git checkout main` in harness; repos stay
   authoritative until their carve merges.

Control shifts gradually: harness leads, repos follow, no machine's daily use breaks mid-ramp.

---

## 6. Open questions for the principal

1. **Domain map (§3a):** agree the 5 domains + expertise owners? Any to split/merge?
2. **Delegation reorg (§3d):** comfortable replacing cross-repo GitHub-issue delegation with harness
   tasks (GitHub as mirror)? Biggest behavioral change.
3. **Memory home (§4):** confirm dotclaude memory (feedback/source) becomes harness
   `Principal/Reference/` + team memory, not a repo concern.
4. **Ramp pace (§5):** is "additive now, carve only after fragtnix validation" the disruption budget
   you want — or even more conservative?
5. **Go deep first:** pick one domain and the team runs the intent-mine → goals-interview →
   agnostic-author loop end-to-end as the reference implementation.
