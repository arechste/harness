---
form: reference
last-verified: 2026-05-30
owner: CASCADE (operational); TOWER (policy); SENTRY (cross-repo dep audit)
status: authoritative
---

# GL-004 — Release & Versioning Discipline

**Status:** Authoritative. **Owner:** CASCADE (operational); TOWER (policy); SENTRY (cross-repo dependency audit).

## Policy

Every repo harness governs (today: harness itself + the 5 product repos) follows the same release discipline:

1. **SemVer 2.0.0** (semver.org). Format `MAJOR.MINOR.PATCH`. Floor `0.y.z` until the repo's public API is committed.
2. **CHANGELOG.md** in **Keep-a-Changelog 1.1.0** format at repo root.
3. **Conventional Commits 1.0.0** drive both the version bump and the CHANGELOG entries.
4. **release-please** automates the bump, the CHANGELOG entry, the tag, and the GitHub Release.
5. **Cross-repo dependencies pin to a tagged version** — never `main`, never floating. Recorded in harness state.
6. **Public API is declared explicitly** in each repo's README.

## Why this guideline exists

Historically, the product repos drifted on all five of these — SemVer was used inconsistently, CHANGELOGs were sparse or absent, cross-repo dependencies tracked `main` instead of tags, and "what is in this version" was often unclear. The Phase-2 reset to `0.y.z` is the clean slate; this guideline is what prevents recurrence.

## Public API — what counts

Each repo's README §Usage names its **public API surface**. A change to the public API requires a MAJOR bump (or stays under 0.y.z if pre-1.0.0). Examples:

| Repo | Public API ≈ |
|---|---|
| dotfiles | Env vars exported to `~/.zshrc`; scripts under `bin/`; chezmoi-managed paths in `~/`; `Brewfile` package names |
| dotclaude | Skill names (`/dc:<name>`); hook event handlers in `hooks/hooks.json`; settings.json schema; chezmoi-managed paths under `~/.claude/` |
| git-organizer | Tools under `tools/`; label taxonomy in `data/label-definitions.json`; schemas under `data/schemas/`; conventions cited from outside |
| mac-organizer (→ fleet-organizer) | `tools/` CLI flags; inventory schema in `data/`; runbook contracts in `workflows/` |
| aitools-common | Plugin manifest (`.claude-plugin/plugin.json`); skill names; hook contracts in `hooks/hooks.json` |
| harness | SOP names; Guideline numbers (GL-NNN); Workstream IDs (WS-NNN); ADR numbers; Template names |

If a downstream consumer (another repo, a deployed machine, a CI job) breaks because of your change, you touched the public API.

## Bump rules — driven by Conventional Commits

```
feat:                                  → MINOR bump
fix:                                   → PATCH bump
<any>!: ... OR BREAKING CHANGE: ...    → MAJOR bump
docs:, chore:, refactor:, test:, ci:,
build:, perf:, style:, revert:         → no version bump (CHANGELOG entry only when relevant)
```

`release-please` (`googleapis/release-please`) reads the commit history since the last tag and:
1. Computes the new version per the rules above.
2. Drafts a Release PR that updates `CHANGELOG.md` (Keep-a-Changelog format) and the version file (e.g., `VERSION` or `package.json`).
3. On PR merge, creates the git tag and the GitHub Release with notes mirrored from CHANGELOG.

## CHANGELOG.md — shape

```markdown
# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- new feature being worked on

## [0.3.0] - 2026-05-30

### Added
- Principal Handbook scaffold

### Changed
- renamed `Principal/` → `PKM/`

### Removed
- deprecated VAULT/RANGER/BRIDGE callsigns (folded into TOWER/FORGE/CASCADE)
```

Six categories per Keep-a-Changelog: **Added · Changed · Deprecated · Removed · Fixed · Security**. Each version dated; latest on top; `[Unreleased]` tracks next.

## release-please ↔ Keep-a-Changelog mapping (ratified 2026-05-31)

`security-standards-track` #6 (resolves audit AUD-009). release-please groups commits by Conventional-Commit `type`; its `changelog-sections` config renames each group to a Keep-a-Changelog heading so both standards coexist. **Locked mapping:**

| Commit `type` | Changelog section | Shown? |
|---|---|---|
| `feat` | Added | yes |
| `fix` | Fixed | yes |
| `refactor`, `perf`, `revert` | Changed | yes |
| `docs` | Changed | yes |
| `chore`, `test`, `ci`, `build` | — | hidden |

```jsonc
// release-please-config.json
"changelog-sections": [
  { "type": "feat",     "section": "Added"   },
  { "type": "fix",      "section": "Fixed"   },
  { "type": "refactor", "section": "Changed" },
  { "type": "perf",     "section": "Changed" },
  { "type": "revert",   "section": "Changed" },
  { "type": "docs",     "section": "Changed" },
  { "type": "chore",    "section": "Changed", "hidden": true },
  { "type": "test",     "section": "Changed", "hidden": true },
  { "type": "ci",       "section": "Changed", "hidden": true },
  { "type": "build",    "section": "Changed", "hidden": true }
]
```

**Breaking changes carry upgrade steps.** A `BREAKING CHANGE:` footer (or `type!:`) must say what a consumer has to *do* to adopt the release — the helper to run, the path to migrate, the setting to change. release-please surfaces it at the top of the release notes; this is the signal the fleet (the principal's machines) reads before pulling an artifact.

**Audience & scope.** The changelog/releases serve the **shipped artifacts** the principal consumes on his fleet (dotfiles, dotclaude) and any repo worked on **outside harness** — a standalone git repo should explain what it is and how it evolved, for future human collaborators with no harness access (e.g. `ntnxlab.ch`). `git-organizer` / `fleet-organizer` follow the same discipline; a repo that never releases simply has no changelog.

**Caveat.** Conventional Commits is type-oriented; Keep-a-Changelog is change-oriented. The KaC sections **Deprecated**, **Removed**, **Security** have no automatic commit-type source — surface them via a `BREAKING CHANGE:` footer or a manual changelog edit when they apply.

## Cross-repo dependency pinning

When one repo depends on another (a SOP cites a Guideline, a script consumes a config from a sibling repo, a chezmoi template embeds another repo's content):

- The dependency **pins to a tagged version**, not `main`, not a SHA on `main`.
- The pin is recorded in `harness/state/repo-baselines.yaml` (already in use for the Phase-2 freeze).
- When a dependency rotates, the consumer updates the pin in a deliberate commit. The bump is visible.
- SENTRY's weekly audit checks no consumer pins `main` or an arbitrary SHA where a tag exists.

## 1.0.0 promotion criteria

A repo declares `1.0.0` ("the API is committed") only when **all** of:

- README §Usage has a stable, documented public API surface.
- No breaking changes have shipped in ≥ 1 quarter.
- All known consumers have been updated to use the documented API (not undocumented internals).
- An ADR records the promotion (template: `NNNN-promote-<repo>-to-1.0.0.md`).

Until then, `0.y.z` is honest — MINOR can break, the spec allows it.

## Release cadence

No fixed cadence. Releases happen when work is ready, not on a calendar. release-please opens the Release PR; the principal (or CASCADE-mode TOWER, under the autonomy contract) decides when to merge.

## Hotfixes

- Critical fix on `main` → `fix:` commit → release-please bumps PATCH → ship.
- For a frozen older version (rare), branch from the tag, cherry-pick the fix, tag the new patch. Document in CHANGELOG under that minor's section.

## CI integration

| Workflow | What it does | Triggers |
|---|---|---|
| `release-please` | Drafts Release PR; tags + creates GitHub Release on merge | push to `main` |
| `commitlint` (recommended add) | Validates commit messages on PRs follow Conventional Commits 1.0.0 | PR |
| `cross-repo-pin-audit` (SENTRY) | Weekly: scans for un-pinned cross-repo references | weekly cron |

## Related

- `[[GL-001-commit-autonomy]]` — commit signing/trailer; releases are signed by the principal at merge
- `[[GL-002-credential-custody]]` — the secrets the release pipeline needs (gh tokens)
- `[[GL-003-doc-authoring]]` — Diátaxis discipline · references this guideline for the changelog convention
- `[[ADR-0001-doc-system]]` — the founding decision that called for this guideline
- `state/repo-baselines.yaml` — where cross-repo pins live
