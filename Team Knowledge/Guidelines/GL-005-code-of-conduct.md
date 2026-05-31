---
form: reference
last-verified: 2026-05-30
owner: SENTRY (policy enforcement); QUILL (authoring); principal (ratification)
status: authoritative
ported-from: dotclaude/home/rules/code-of-conduct.md @ baseline-sha 4a01477
port-verdict: adapted-from-source (intent-mined; fully tool-agnostic)
---

# GL-005 — Code of Conduct

**Status:** Authoritative. **Owner:** SENTRY (policy enforcement); QUILL (authoring); principal (ratification).

## Policy

Four pillars govern how the team handles security, AI attribution, licensing, and supply chain — for every commit, every dependency, every artifact produced.

## Security

- **Never execute code from untrusted sources.** No blind `curl | sh`, no `wget | bash`, no piping a remote script directly into a shell. If a vendor provides such a one-liner, read the source first or use a pinned, verified install path.
- **Validate all external inputs.** Sanitize before use. Treat *any* data crossing a trust boundary (network, user input, file from outside the repo) as adversarial until proven otherwise.
- **Pin dependency versions.** Floating versions are vulnerabilities waiting to land. Review lockfile changes line-by-line; a lockfile diff is part of the PR.
- **Verify package integrity.** Use checksums and signatures where available. If a package ships a `SHA256SUMS` or signed manifest, validate it before use.

## AI Attribution

- **Add `<!-- AI-assisted -->` markers** in generated docs where the host project, vendor, or law requires.
- **Declare AI involvement** where expected by project/org policy. When in doubt, declare — under-attribution is harder to undo than over-attribution.
- The team's commit trailer (per `[[GL-001-commit-autonomy]]`) is one form of attribution; project-level policies may require additional markers in the artifact itself.

## License & Attribution

- **Honor all licenses and copyrights.** Never strip license headers. If a file ships under a license, that license travels with the file.
- **Don't copy code without checking its license.** If it isn't yours and you can't show the license is compatible with the destination, don't paste it.
- **Attribute contributors; preserve authorship history.** `git log` is part of the project's record; rewrites that erase authorship without consent are a breach of this guideline.
- **When in doubt about license compatibility, ask** before proceeding. The cost of asking is a paragraph in a task; the cost of a wrong import is a rewrite of the whole feature.

## Supply Chain

- **Prefer well-known registries.** npm, PyPI, crates.io, Maven Central, the language's canonical hub. Vanity package URLs are red flags.
- **Review new dependencies before adding** — check maintainer reputation, download count, last update, open-issue health, signed releases. Five minutes of investigation prevents a typosquat.
- **Audit transitive dependencies for known vulnerabilities.** Use the language's standard tool (`npm audit`, `cargo audit`, `pip-audit`, …). Treat the report as input to a decision, not a checkbox.
- **Never add dependencies from forks** without a clear justification recorded in the PR or an ADR. A fork is a maintenance liability; if it's the right call, it's the right call documented.

## Operational tooling (ratified 2026-05-31)

`security-standards-track` #4 translates the Supply Chain and License pillars above into concrete, **informational** CI. Posture and rationale: `[[ADR-0002-supply-chain]]`. This is sized to harness's actual use — personal infra, homelab, the shared `ntnxlab.ch` lab — **not** a public-OSS provenance regime. The driving risks are the principal's: never run known-vulnerable code, never take on a legally-risky or badly-owned dependency.

| Concern | What runs | Blocking? |
|---|---|---|
| **Known vulnerabilities** | language-native audit (`npm audit` / `pip-audit` / `cargo audit`) + `grype` over the dependency set | no — surfaces, does not gate |
| **License & attribution** | dependency license scan (e.g. `syft` SBOM license fields); flag non-permissive licenses and any **license change** on update | no — flags for principal review |
| **Owner / project health** | new-dependency review per the pillars above (maintainer, recency, registry); OpenSSF Scorecard optional | no |

- **License is first-class**, not an afterthought: this work is used in a Nutanix PreSales context and must not expose the principal's employer to legal risk. A copyleft creep, an OSS→source-available relicense, or a stripped attribution is a **flag-and-decide** event, recorded in a task or ADR.
- **Prefer standard libraries; vendor a fork only with a recorded justification** — a vendored fork is a deliberate, documented choice.
- **Deferred** (not needed at this tier): SLSA build provenance, SBOM attestation, artifact/tag signing. Revisit only if a repo is published for outside consumption.

---

## Provenance

Ported from `dotclaude/home/rules/code-of-conduct.md` (baseline SHA `4a01477` per `state/repo-baselines.yaml`). The source file was tool-agnostic prose; the port preserves all four pillars, adds explicit rationale to each bullet, and integrates cross-links to the new harness framework (`[[GL-001-commit-autonomy]]`, `[[GL-002-credential-custody]]`, `[[GL-004-release-versioning]]`). See the dotclaude domain intent brief (`Deliverables/2026-05-29-dotclaude-domain-intent-brief.md`) §1.2 for the verdict.

## Related

- `[[GL-001-commit-autonomy]]` — commit signing, the AI-attribution trailer
- `[[GL-002-credential-custody]]` — operational security for secrets (the "treat inputs as adversarial" rule extends here)
- `[[GL-004-release-versioning]]` — dependency pinning + SemVer signaling
- Future `[[SOP-audit-credentials]]` (SENTRY), `[[SOP-secret-scan]]` (SENTRY)
