---
id: checkout-node24-bump
status: open
priority: P3
required-expertise: [gitops]
assignee: unassigned
filed_by: TOWER
filed_at: 2026-05-31T11:45:00Z
links:
  - .github/workflows/credential-expiry.yml
---

# Bump first-party GitHub Actions off Node 20 (checkout@v5 / setup-node@v5)

## Context

The `credential-expiry` workflow run on 2026-05-31 ([#26711658384](https://github.com/arechste/harness/actions/runs/26711658384)) succeeded but logged:

> Node.js 20 actions are deprecated. … Actions will be forced to run with Node.js 24 by default starting **June 16th, 2026**. Node.js 20 will be removed from the runner on **September 16th, 2026**.

This is a fleet-wide issue, not specific to credential-expiry — every harness workflow pins `actions/checkout@v4` (Node 20). `diagram-parse.yml` also pins `actions/setup-node@v4` (Node 20). Both have v5 releases that run on Node 24. Non-blocking today (GitHub auto-forces Node 24 on June 16); becomes a hard break when Node 20 is removed Sept 16, 2026.

## Scope

Bump first-party `actions/*` to Node-24-capable majors across all five workflows:

| Workflow | Action(s) to bump |
|---|---|
| `validate.yml` | `actions/checkout@v4` → `@v5` |
| `diagram-parse.yml` | `actions/checkout@v4` → `@v5`, `actions/setup-node@v4` → `@v5` |
| `credential-expiry.yml` | `actions/checkout@v4` → `@v5` |
| `doc-freshness.yml` | `actions/checkout@v4` → `@v5` |
| `link-check.yml` | `actions/checkout@v4` → `@v5` |

`lycheeverse/lychee-action@v2` (link-check) is third-party and out of scope for this bump — verify separately if its run logs a Node-20 warning.

## Acceptance criteria

- [ ] All first-party `actions/*` pins moved to a major that runs on Node 24 (v5 for checkout + setup-node); confirm the chosen majors are live releases before committing
- [ ] One workflow_dispatch run (e.g. `credential-expiry`) confirms the Node-20 deprecation warning is gone
- [ ] No behavior change — workflows still pass

## Event log

- 2026-05-31T11:45:00Z — filed by TOWER after the credential-expiry verification run surfaced the Node-20 deprecation warning fleet-wide.
