# ci/

Validation that runs in GitHub Actions on every PR. Workflow lives at `.github/workflows/validate.yml`.

## Checks (Phase 1 — informational)

- **Markdown lint** — `markdownlint-cli` via `npx`. Catches malformed markdown.
- **Dead-wikilink detection** — simple shell: extract `[[name]]` from every `.md`, check that a file with that stem exists somewhere under `Team/`, `Team Knowledge/`, `Principal/`, `docs/`. **Failures are warnings, not blockers** in Phase 1 because the scaffold is full of stubs pointing at not-yet-authored SOPs.
- **JSON schema validation** — placeholder; `ci/schemas/` is empty until LATTICE authors schemas in Phase 2.

## Checks (Phase 2+ — planned)

- SOP-format lint (Purpose / When to call / Inputs / Steps / Worked example / Common mistakes)
- Frontmatter validation for tasks, delegations, agent contracts (LATTICE schemas)
- Dead-wikilink becomes blocker once Phase 2 populates the SOP/GL set
- Dangling `state/delegations/` references (mirror exists but GH issue closed, or vice versa)

## What lives here

- `schemas/` — JSON Schemas for tasks, delegations, frontmatter contracts (Phase 2)
- This README

The workflow YAML itself lives under `.github/workflows/` per GitHub convention.
