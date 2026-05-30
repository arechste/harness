# ci/

Validation that runs in GitHub Actions. Workflow YAML lives under `.github/workflows/` per GitHub convention; helper scripts and schemas live here.

## Workflows

| Workflow | Triggers | Checks |
|---|---|---|
| `validate.yml` | push + PR | Markdown lint · dead-wikilink detection · JSON schema validation (placeholder) |
| `link-check.yml` | push + PR + weekly cron | **lychee** — broken markdown links (internal + external). Phase 2: informational (`fail: false`) until forward-references resolve |
| `diagram-parse.yml` | push + PR | **mmdc** — every Mermaid block validated by extraction + render-to-SVG. Fails on parse error |
| `doc-freshness.yml` | weekly cron + workflow_dispatch | Front-matter `last-verified` ≤ MAX_AGE_DAYS (default 180); informational |

## Scripts

- `scripts/check-mermaid.sh` — extracts ```mermaid blocks from every `.md`, validates each via `mmdc -i ... -o /tmp/out.svg`. Run locally with `npm i -g @mermaid-js/mermaid-cli && bash ci/scripts/check-mermaid.sh`.
- `scripts/check-doc-freshness.sh` — scans front-matter `last-verified:` dates, reports files older than `${MAX_AGE_DAYS:-180}`. Run locally with `MAX_AGE_DAYS=30 bash ci/scripts/check-doc-freshness.sh`.

## Checks (Phase 2+ — planned)

- SOP-format lint (Purpose / When to call / Inputs / Steps / Worked example / Common mistakes)
- Front-matter `form:` validation against the Diátaxis enum per `[[GL-003-doc-authoring]]`
- Frontmatter schemas for tasks, delegations, agent contracts (LATTICE-authored under `schemas/`)
- Dead-wikilink becomes blocker once Phase 2 populates the SOP/GL set
- Dangling `state/delegations/` references (mirror exists but GH issue closed, or vice versa)
- Cross-repo dep audit per `[[GL-004-release-versioning]]` — flag any reference pinned to `main` or arbitrary SHA where a tag exists

## What lives here

- `scripts/` — CI helper scripts (bash)
- `schemas/` — JSON Schemas for tasks, delegations, front-matter contracts (Phase 2; LATTICE)
- This README
