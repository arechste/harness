---
id: wikilink-port-backlog
status: open
priority: P2
required-expertise: [librarian]
assignee: unassigned
filed_by: TOWER
filed_at: 2026-05-28T20:39:10Z
links: []
---

# Wikilink PORT backlog — author the unwritten SOPs & Guidelines

## Context

VAULT ran a wikilink-health audit across the content layer (`Team/`, `Team Knowledge/`, `PKM/`) on 2026-05-28. Result: 148 wikilink occurrences → 75 unique targets, **27 resolve, 48 dangle**, zero rename drift, zero basename collisions. The danglers are forward-references, not breakage — they are the **Phase-2 PORT worklist**. Each dangling target is a file that should exist once Phase 2 PORTs content in from the product repos.

Target slugs below are written **without wikilink brackets on purpose** so this worklist does not itself register as dead links in CI. Add the brackets (and the `NNN` number for Guidelines) when each file is authored.

## Inventory — grouped by origin

### SOP origin — 27 unwritten SOPs (32 references)

Author-first candidates (most-referenced, and the only two originating from non-agent canon rather than `Team/*/AGENTS.md` "SOPs I follow" lists):

| slug | refs | example source |
|---|---|---|
| `SOP-generate-claude-shim` | 2 | `Team Knowledge/SOPs/SOP-hire-agent.md` |
| `SOP-ship-release` | 2 | `Team/CASCADE - GitOps Engineer/AGENTS.md` |

Remaining 25 (one reference each, all from agent contracts):

| slug | example source |
|---|---|
| `SOP-add-brew-formula` | `Team/FORGE - DevOps Engineer/AGENTS.md` |
| `SOP-add-hook` | `Team/RELAY - AI Tooling Engineer/AGENTS.md` |
| `SOP-add-mcp-server` | `Team/BRIDGE - Integrator/AGENTS.md` |
| `SOP-audit-conventions` | `Team/SENTRY - Auditor/AGENTS.md` |
| `SOP-audit-credentials` | `Team Knowledge/Guidelines/GL-002-credential-custody.md` |
| `SOP-audit-permissions` | `Team/SENTRY - Auditor/AGENTS.md` |
| `SOP-audit-wikilinks` | `Team/VAULT - Librarian/AGENTS.md` |
| `SOP-author-schema` | `Team/LATTICE - Schemar/AGENTS.md` |
| `SOP-bump-runtime` | `Team/FORGE - DevOps Engineer/AGENTS.md` |
| `SOP-fleet-maintenance` | `Team/RANGER - SysAdmin/AGENTS.md` |
| `SOP-merge-canonicals` | `Team/VAULT - Librarian/AGENTS.md` |
| `SOP-merge-pr` | `Team/CASCADE - GitOps Engineer/AGENTS.md` |
| `SOP-migrate-frontmatter` | `Team/LATTICE - Schemar/AGENTS.md` |
| `SOP-new-machine-setup` | `Team/RANGER - SysAdmin/AGENTS.md` |
| `SOP-research-topic` | `Team/RECON - Researcher/AGENTS.md` |
| `SOP-rotate-credential` | `Team Knowledge/Guidelines/GL-002-credential-custody.md` |
| `SOP-rotate-forge-token` | `Team/BRIDGE - Integrator/AGENTS.md` |
| `SOP-secret-scan` | `Team/SENTRY - Auditor/AGENTS.md` |
| `SOP-update-adapter-prompt` | `Team/RELAY - AI Tooling Engineer/AGENTS.md` |
| `SOP-update-reference` | `Team/RECON - Researcher/AGENTS.md` |
| `SOP-work-issue` | `Team/CASCADE - GitOps Engineer/AGENTS.md` |
| `SOP-write-adr` | `Team/QUILL - Tech Writer/AGENTS.md` |
| `SOP-write-python-tool` | `Team/SPARK - Developer/AGENTS.md` |
| `SOP-write-readme` | `Team/QUILL - Tech Writer/AGENTS.md` |
| `SOP-write-shell-tool` | `Team/SPARK - Developer/AGENTS.md` |

### GL origin — 14 Guidelines authored with the literal `NNN` placeholder, never numbered

High-water mark today is `GL-002`, so numbering resumes at `GL-003`. When each is authored, swap the `NNN` in every referencing link for the assigned number.

| slug | refs | example source |
|---|---|---|
| `GL-NNN-commit-format` | 3 | `Team Knowledge/Guidelines/GL-001-commit-autonomy.md` |
| `GL-NNN-label-taxonomy` | 2 | `Team Knowledge/Workstreams/WS-004-git-conventions.md` |
| `GL-NNN-release-versioning` | 2 | `Team Knowledge/Workstreams/WS-004-git-conventions.md` |
| `GL-NNN-agent-permissions` | 1 | `Team Knowledge/Workstreams/WS-003-fleet.md` |
| `GL-NNN-cross-project-architecture` | 1 | `Team Knowledge/Workstreams/WS-001-dotfiles.md` |
| `GL-NNN-fleet-context` | 1 | `Team Knowledge/Workstreams/WS-003-fleet.md` |
| `GL-NNN-git-workflow` | 1 | `Team Knowledge/Workstreams/WS-005-aitools-common.md` |
| `GL-NNN-merge-lifecycle` | 1 | `Team Knowledge/Workstreams/WS-004-git-conventions.md` |
| `GL-NNN-per-project-secrets` | 1 | `Team Knowledge/Workstreams/WS-001-dotfiles.md` |
| `GL-NNN-pr-review-tiers` | 1 | `Team Knowledge/Workstreams/WS-004-git-conventions.md` |
| `GL-NNN-secrets-conventions` | 1 | `Team Knowledge/Workstreams/WS-001-dotfiles.md` |
| `GL-NNN-test-framework-detection` | 1 | `Team Knowledge/Workstreams/WS-005-aitools-common.md` |
| `GL-NNN-wat-framework` | 1 | `Team Knowledge/Workstreams/WS-003-fleet.md` |
| `GL-NNN-workspace-layout` | 1 | `Team Knowledge/Workstreams/WS-004-git-conventions.md` |

### WS origin — 0 danglers

All concrete Workstream targets resolve (`WS-001`..`WS-005`, `WS-routing`). Nothing to author here.

## Acceptance criteria

- [ ] Each SOP slug above has a real `Team Knowledge/SOPs/<slug>.md` (or is consciously retired and its referencing links removed)
- [ ] Each `GL-NNN-<topic>` is authored with a real sequential number (resuming at `GL-003`) and every referencing link's `NNN` swapped for the assigned number
- [ ] Author-first: `SOP-generate-claude-shim` and `SOP-ship-release` before the one-off agent-contract SOPs
- [ ] Re-run the CI `wikilink-check` (`.github/workflows/validate.yml`) and confirm the dangling count drops as each file lands

## Notes

- **Placeholder hygiene already done this session.** The 7 illustrative wikilink examples in the audited content roots (the audit's "Other" group) were neutralized — fenced as code blocks (templates, WS-005 shim-body) or had their non-link brackets dropped (WS-002 globs, generic `wikilink` concept-refs). CI's `wikilink-check` was updated to strip fenced code blocks before extracting links, so fenced examples no longer count. This is NOT part of this backlog — it is complete.
- **3 out-of-scope stragglers remain**, outside the audit's three content roots and outside the template scope, so they were left for a principal decision: `ADAPTER-PROMPT.md:76` (a `SOP-...` shim-body wikilink example — arguably intentional instruction in the bootstrap prompt) and `docs/transformation/round-0.md:57,238` (`wikilink` and `SOP-XXX` examples — a historical transformation record). CI is informational (`exit 0`), so these warn but do not fail.
- **Scope note:** the audit scanned `Team/`, `Team Knowledge/`, `PKM/` (75 unique targets, 48 danglers). CI scans the whole tree (currently 54 danglers) — the delta is docs/ and root-level files. This worklist reflects the audit's three-root scope per the principal's framing of the audit as the backlog.

## Event log

- 2026-05-28T20:39:10Z — filed by TOWER from VAULT's wikilink-health audit; tagged `required-expertise: librarian`
