---
status: DRAFT / research findings — not ratified SSOT
filed-by: RECON
source-access-date: 2026-05-30
task: build-doc-system
---

# Doc-System Research Brief

DRAFT / research findings — not ratified SSOT. For TOWER synthesis step only.

---

## Part A — Doc Frameworks

### 1. Diátaxis (diataxis.fr)

**The four quadrants — canonical definitions:**

| Form | Orientation | User need |
|---|---|---|
| Tutorial | Learning | Acquire skill through guided doing |
| How-to guide | Task | Accomplish a specific goal |
| Reference | Information | Look up facts, options, completeness |
| Explanation | Understanding | Grasp why, concept, background |

Key precision: a tutorial is not "how to do X" — it is a lesson that teaches *how to learn*. A how-to guide is directions for someone who already knows what they want. Reference is exhaustive and lookup-first; it omits instruction. Explanation is discursive, conceptual, never action-oriented.

The framework is stable. The diataxis.fr site shows no major spec changes in 2025-2026; it remains a living essay-form maintained by its author (Daniele Procida). Adoption is broad across the Python, Django, Canonical, and Write the Docs communities.

**Recommendation for harness:** Adopt. Map the Handbook to Diátaxis quadrants: Handbook pages are explanation + how-to; SOPs are how-to; Guidelines are reference; this research brief is explanation. The four-quadrant discipline prevents "explano-tutorial" mush. Single-principal context means tutorials are rare (TOWER onboarding docs are the exception); emphasis is on how-to and reference.

Source: [diataxis.fr](https://diataxis.fr) — Tier 1 (official/authoritative, author-maintained). Accessed 2026-05-30.

---

### 2. C4 Model (c4model.com)

**Four levels confirmed:**

| Level | Abstraction | Shows |
|---|---|---|
| System Context | Highest | Your system + external actors/systems |
| Container | High | Apps, data stores, microservices within the system |
| Component | Mid | Building blocks inside one container |
| Code | Lowest | Classes, functions, modules |

The C4 model is tool-agnostic. The author (Simon Brown) distinguishes *diagramming* (boxes and lines) from *modelling* (a queryable data structure that generates views). Structurizr is the reference modelling tool. For lightweight use, diagram-only (Mermaid or PlantUML C4 notation) is accepted.

**Mermaid C4 support status (2026):** Mermaid has a `C4Diagram` diagram type. It covers Context and Container levels adequately. v11 added `$lineStyle` parameter to `UpdateRelStyle` in C4 diagrams. Layout occasionally needs nudging; sprite/icon support lags PlantUML. For a personal infra orchestrator (not enterprise microservices), Mermaid C4 is sufficient for L1 (Context) and L2 (Container).

**Recommendation for harness:** Adopt C4 vocabulary (Context + Container levels only; skip Component/Code for a personal orchestrator). Use Mermaid for rendering; Structurizr is overkill here. One L1 "harness + its product repos + external services" diagram and per-repo L2 container diagrams are the right scope.

Source: [c4model.com](https://c4model.com) — Tier 1 (author-maintained). Accessed 2026-05-30.

---

### 3. arc42 vs C4 for harness

**arc42 structure — 12 sections:**

1. Introduction & Goals
2. Constraints
3. Context & Scope
4. Solution Strategy
5. Building Block View
6. Runtime View
7. Deployment View
8. Crosscutting Concepts
9. Architectural Decisions
10. Quality Requirements
11. Risks & Technical Debt
12. Glossary

arc42 is designed for *communicating with stakeholders* in enterprise contexts. It is comprehensive by design; most sections assume a team audience, formal quality requirements, and multi-stakeholder sign-off. It is not document-as-code-first and does not mandate any diagram notation.

**Verdict:** arc42 is over-engineered for a personal infra orchestrator. Its strength is the breadth of sections — which is also its weakness here. For harness, the relevant arc42 material collapses to: context + scope, building blocks, deployment view, and architectural decisions. C4 covers the diagram side of those. The ADR format (see Q4) handles the decisions section separately. There is no value in carrying the other 8 arc42 sections.

**Recommendation for harness:** Do not adopt arc42 as the primary template. Borrow its vocabulary selectively (especially "context & scope" and "deployment view" for Handbook architecture pages). C4 diagrams + a lightweight Handbook structure are the right substitutes.

Source: [arc42.org/overview](https://arc42.org/overview) — Tier 1 (official). Accessed 2026-05-30.

---

### 4. ADR Format: Nygard vs MADR

**Nygard original (2011):**
Sections: Title, Status, Context, Decision, Consequences. Ultra-minimal. Widely adopted (most popular template by GitHub repo count: 723 repos). Statuses: proposed / accepted / deprecated / superseded.

**MADR 4.0.0 (current):**
Required: Context and Problem Statement, Considered Options, Decision Outcome.
Optional: Decision Drivers, Pros and Cons of Options, Consequences, Confirmation, More Information.
YAML front matter: status, date, decision-makers, consulted, informed (RACI).

Key relationship: MADR is a strict superset of Nygard. Every Nygard ADR is valid MADR. MADR adds structure for multi-option tradeoffs, which is exactly what harness needs when choosing between e.g. Mermaid vs D2.

**Superseding chains:** Both formats support superseded status + link. Best practice is two-way links: the old ADR says "superseded by ADR-0012" and the new one says "supersedes ADR-0005." The adr-log tool (npryce/adr-tools) can generate a chronological index.

**Recommendation for harness:** Adopt MADR 4.0.0 (abbreviated — omit RACI fields for a single-principal context). Use the three required sections plus Considered Options and Pros/Cons. Keep ADRs in `docs/decisions/NNNN-title.md`. This is the cleaner decision log for infra choices where option comparison is the main value.

Sources: [adr.github.io/madr](https://adr.github.io/madr/) — Tier 1 (official MADR site). [adr.github.io](https://adr.github.io/) — Tier 1 (ADR GitHub organization). Accessed 2026-05-30.

---

## Part B — Repo-Level Doc Conventions

### 5. README Best Practices

**GitHub's official guidance (2026):** README files are the first entry point. Required content: what the repo is for, how to install/use it, how to contribute, license. GitHub explicitly says "longer documentation is best suited for wikis" — READMEs should not be comprehensive docs.

**Standard Readme spec (RichardLitt/standard-readme):** Defines required sections as: Title, Short description; optional but common: Background, Install, Usage, API, Contributing, License. Provides a linter (`standard-readme-lint`) and a generator. The spec encourages keeping the README squarely user/operator-facing and deferring governance material elsewhere.

**2026 pattern for operator-facing repos:** Badge + one-liner description, then: Install (copy-paste-ready), Usage (minimal working example), Configuration (env vars / flags), and a pointer to fuller docs. No changelog in the README. No governance. No project history.

**Recommendation for harness:** Each product repo (dotfiles, dotclaude, git-organizer, mac-organizer, aitools-common) gets a minimal README: title + one-liner, install command, usage example(s), link to harness Handbook for operator context. No duplication of harness SSOT in repo READMEs.

Sources: [GitHub Docs — About READMEs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes) — Tier 1 (official). [RichardLitt/standard-readme](https://github.com/RichardLitt/standard-readme) — Tier 2 (well-known maintainer). Accessed 2026-05-30.

---

### 6. Keep a Changelog 1.1.0

**Spec confirmed at keepachangelog.com:**

Six change categories: Added, Changed, Deprecated, Removed, Fixed, Security.

Seven guiding principles:
1. Changelogs are for humans, not machines.
2. Every version requires an entry.
3. Group same-type changes.
4. Versions and sections are linkable.
5. Latest version first.
6. Each version shows its release date.
7. Adherence to SemVer is stated.

An `[Unreleased]` section at the top tracks changes pending the next release.

**Automation integration (2026):** `standard-version` is deprecated. Current recommended tools:
- **release-please** (googleapis/release-please): parses conventional commits, opens a Release PR that updates CHANGELOG.md and version files; merging the PR creates the GitHub Release. Actively maintained as of 2026.
- **git-cliff**: changelog generator from conventional commits; more configurable template output than release-please; useful when you want the changelog separately from the release workflow.
- **changesets**: monorepo-focused; overkill for these repos.

**Recommendation for harness:** Adopt Keep a Changelog 1.1.0 format in all five product repos. Automate via release-please using the existing conventional commits. Each repo gets one CHANGELOG.md at root.

Sources: [keepachangelog.com/en/1.1.0](https://keepachangelog.com/en/1.1.0/) — Tier 1 (official spec). [googleapis/release-please](https://github.com/googleapis/release-please) — Tier 1 (Google OSS, actively maintained). Accessed 2026-05-30.

---

### 7. Semantic Versioning

**Current spec:** SemVer 2.0.0 (semver.org). MAJOR.MINOR.PATCH. MAJOR = incompatible API change; MINOR = backward-compatible new feature; PATCH = backward-compatible bug fix. Lower parts reset to 0 on increment.

**For infrastructure/config repos:** The official SemVer spec is silent on non-library repos. Community practice (confirmed in 2025-2026 GitOps discussions):
- Declare your "public API" explicitly (for a dotfiles repo: the shell env vars it exports; for mac-organizer: its CLI flags and config schema; for harness: the task/SOP interface).
- MAJOR = a consumer must change their usage to stay compatible.
- MINOR = new capability, existing usage unaffected.
- PATCH = fix, no behavior change.

For repos with no external consumers (internal infra), many teams use `0.y.z` permanently (spec allows it: "anything may change at any time before 1.0.0") or adopt CalVer (YYYY.MM.DD). This is a genuinely open decision for harness product repos.

**Recommendation for harness:** Use SemVer for the five product repos. Treat each repo's documented CLI/API surface as its public API. Keep at `0.y.z` until the interface is stable. Release-please handles the bump logic automatically from conventional commits.

Source: [semver.org](https://semver.org) — Tier 1 (official spec). Accessed 2026-05-30.

---

### 8. Conventional Commits 1.0.0

**Spec confirmed:** Format: `<type>[optional scope]: <description>`. Body and footers are optional. Required types in spec: `feat` (MINOR), `fix` (PATCH), `BREAKING CHANGE` in footer or `!` suffix (MAJOR).

Common additional types (not in spec, but universally accepted): `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, `test`.

**2026 tooling ecosystem:**
- **commitlint** (`@commitlint/cli` + `@commitlint/config-conventional`): lint commits in CI. Actively maintained.
- **release-please**: consumes conventional commits for version and changelog automation. The harness repos' existing `feat:`, `fix:`, `chore:`, `docs:` usage is fully compatible.
- **git-cliff**: generates changelogs from conventional commits; customizable Jinja templates.
- **cz-git / commitizen**: interactive commit message builder for local use.

**Harness status:** Harness already uses conventional commits (git log confirms `feat:`, `fix:`, `chore:`, `docs:` etc.). The existing usage is current-spec-compliant. No changes needed to the commit discipline itself — only automation (release-please) is missing.

Sources: [conventionalcommits.org/en/v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) — Tier 1 (official spec). Accessed 2026-05-30.

---

## Part C — Diagram-as-Code

### 9. Mermaid vs D2 vs PlantUML (2026)

| Criterion | Mermaid | D2 | PlantUML |
|---|---|---|---|
| GitHub native rendering | Yes (zero config) | No (build step) | No (server required) |
| C4 support | Limited but functional (L1/L2) | No native C4 | Yes (C4-PlantUML, mature) |
| Learning curve | Low (Markdown-like) | Low-medium (cleaner than PlantUML) | High (Java/UML heritage) |
| Layout quality | Adequate (dagre engine) | Better (TALA engine, proprietary) | Good (GraphViz) |
| LLM familiarity | High | Medium | Low |
| Active development | Yes (v11+ in 2025-2026) | Yes (active) | Slow cadence |
| VSCode integration | Yes (official extension) | Yes | Yes |
| Obsidian/Notion | Yes | Plugin only | No |

**Key 2026 facts:**
- Mermaid renders natively in GitHub, GitLab, Notion, and Obsidian with zero configuration — no other tool matches this.
- Mermaid v11 (2024-2025): added C4 line styles, improved quadrant charts, new shape types in flowcharts.
- D2's TALA layout engine produces better auto-layout for complex diagrams, but D2 requires a build step in any GitHub-hosted context.
- PlantUML remains the most mature for formal UML and enterprise C4, but requires a Java server or proxy — a significant friction cost for a markdown-only repo.

**Open question:** For harness architecture diagrams specifically, is Mermaid C4 sufficient (L1 + L2), or is the visual output quality gap significant enough to warrant D2 + a GitHub Action to render SVG artifacts? Given the principal's preference for visual-over-text, D2's layout quality is worth noting but the GitHub friction is real.

**Recommendation for harness:** Use Mermaid as the primary diagram tool. It renders natively in all contexts harness uses (GitHub PRs, issues, markdown files). Use C4 diagram type for architecture views. If output quality becomes a blocker for a specific diagram, D2 with a GitHub Actions render step is the fallback — not a primary standard. PlantUML is not worth the setup cost here.

Sources: [diagrams.so/learn/diagram-as-code-comparison](https://diagrams.so/learn/diagram-as-code-comparison) — Tier 2 (practitioner reference, 2026). [mermaid-js/mermaid releases](https://github.com/mermaid-js/mermaid/releases) — Tier 1 (official). [d2lang.com](https://d2lang.com) — Tier 1 (official). Accessed 2026-05-30.

---

## Part D — Living Docs

### 10. Living-Doc Patterns for Markdown-Only GitHub Repos

**Link checking:**
- **lychee** (`lycheeverse/lychee-action`): Rust-based, fast async link checker. Checks Markdown, HTML, text. A full repo scan of 576 links runs in ~1 minute. GitHub Action on Marketplace. Supports `.lycheeignore` for exclusions. Can open GitHub Issues when broken links are found. Active as of 2025-2026. **Clear best practice for CI link checking.**

**Mermaid parse CI:**
- No dedicated GitHub Action exists solely for Mermaid parse checking (as of 2026-05 research). The standard pattern is to run `mmdc` (mermaid-cli, `@mermaid-js/mermaid-cli`) in CI with `--outputFormat=svg` to catch parse errors. A failing render = a broken diagram. This can be added as a simple `npx mmdc` step in a GitHub Actions workflow.

**Last-verified timestamps:**
- No universal standard exists. Common patterns:
  1. YAML front matter `last-verified: YYYY-MM-DD` in markdown files, plus a CI script that warns on files older than N days.
  2. A `<!-- last-verified: YYYY-MM-DD -->` HTML comment in the file body.
  3. For SOPs/Guidelines: a `reviewed-by:` field in YAML front matter checked by a scheduled GitHub Action.
- Pattern 1 (YAML front matter) is the most parseable and already consistent with harness's front matter conventions.

**ADR superseding chains:**
- Best practice: bidirectional links in status fields. Old ADR: `status: superseded by [ADR-0012](0012-title.md)`. New ADR: `status: accepted, supersedes [ADR-0005](0005-title.md)`.
- `adr-tools` (npryce/adr-tools) or `phodal/adr` can generate an index table automatically.
- For harness: a hand-maintained `docs/decisions/INDEX.md` with a status column is sufficient and avoids a tool dependency.

**Content freshness flags:**
- GitHub's native "last commit date" on a file provides a coarse freshness signal visible in the UI.
- For finer control: a scheduled GitHub Action that reads front matter `last-verified` dates and opens an issue listing stale files (e.g., not re-verified in 180 days).

**Doc generators (mkdocs / sphinx / docusaurus):**
- Not warranted for harness. A markdown-only, GitHub-hosted repo already has free rendering (GitHub renders markdown natively, including Mermaid). Doc generators add build complexity, dependency management, and deployment overhead that is not offset by any benefit given a single-operator audience. If a public-facing site is ever needed, GitHub Pages with a minimal mkdocs-material theme is the lowest-friction upgrade path.

**Recommended lightweight CI stack for harness:**
1. **lychee-action** on `push` and weekly schedule: catches broken links.
2. **mmdc render step** on `push`: catches broken Mermaid diagrams.
3. **front-matter freshness script** on weekly schedule: reads `last-verified` dates, opens an issue for anything older than 180 days.
4. No doc generator. GitHub native rendering is sufficient.

Sources: [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action) — Tier 1 (official, GitHub Marketplace). [mermaid-js/mermaid](https://github.com/mermaid-js/mermaid) — Tier 1 (official). Accessed 2026-05-30.

---

## Open Decisions for Principal Sign-Off

1. **Mermaid vs D2 for architecture diagrams:** Mermaid wins on GitHub-native friction; D2 wins on layout quality. The right answer depends on how much the principal cares about visual polish of architecture diagrams vs. zero-config rendering. If visual > text is strong enough, D2 + a GitHub Actions render step may be worth it for the architecture docs specifically (not everywhere).

2. **SemVer version floor for product repos:** Use `0.y.z` until the interface is stable (recommended) vs. starting at `1.0.0` immediately. This is a personal/stylistic choice with no wrong answer; it only affects whether MAJOR bumps signal "this is now stable."

3. **ADR scope:** ADRs for harness-level decisions only, or also for per-product-repo decisions? If the product repos have their own `docs/decisions/` folders, they need their own numbering scheme. If all ADRs live in harness, cross-repo decisions are easy to find but the per-repo context is lost.
