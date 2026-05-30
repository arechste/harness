---
form: explanation
last-verified: 2026-05-30
owner: SENTRY
status: authoritative
---

# Session — 2026-05-30 17:00 — Guidelines corpus audit (GL-001–GL-005)

SENTRY hat. Read-only critique pass across all 5 authored Guidelines. Two passes: internal consistency + gold-standard benchmark.

## Scope

GL-001-commit-autonomy · GL-002-credential-custody · GL-003-doc-authoring · GL-004-release-versioning · GL-005-code-of-conduct

## Verdict

PASS with minor fixes. No blocker-severity findings. Corpus is internally coherent; delegation pattern between files is sound. 12 findings (0 blocker, 2 major, 7 minor, 3 nit).

## Findings summary

| ID | Sev | GL(s) | Type | Description | Assignee |
|---|---|---|---|---|---|
| AUD-001 | major | GL-001 | hygiene | No YAML front matter (form/last-verified/owner/status) — required by GL-003's own schema | QUILL |
| AUD-002 | major | GL-002 | hygiene | No YAML front matter — same schema gap | QUILL |
| AUD-003 | minor | GL-001 | gap | `[[GL-NNN-commit-format]]` is a live dangling wikilink in the corpus; GL-001 defines only the envelope (`type(scope): subject`) without body/footer/breaking-change rules | QUILL |
| AUD-004 | minor | GL-001 | standard-deviation | Commit trailer format (`Claude/Opus/harness@<hostname>`) conflicts with actual commits (`Claude/Opus/harness@fragtnix`) and product-repo convention (`Claude/{model}/{identity}@{hostname}`) — no canonical SSOT trailer template in this corpus | QUILL + CASCADE |
| AUD-005 | minor | GL-001 | gap | AI attribution rule is only a trailer; GL-003 mandates `<!-- AI-assisted -->` doc markers. GL-001 never mentions doc-level markers even though it owns commit discipline | QUILL |
| AUD-006 | minor | GL-002 | gap | No rotation period / credential-age SLA stated. OWASP SM-GS2 / NIST SSDF RV.1 require a defined maximum lifetime. "periodically" and the `expires:2026-12-31` tag example are ad hoc | SENTRY → principal |
| AUD-007 | minor | GL-002 | gap | No break-glass procedure when 1P is unavailable and ops are urgent — the "escalate-blocked" path just stalls | SENTRY → principal |
| AUD-008 | minor | GL-003 | gap | Diátaxis `tutorial` form is mapped to no folder in harness. If a tutorial surface ever ships, there is no canonical home for it | QUILL |
| AUD-009 | minor | GL-004 | standard-deviation | GL-004 conflates Keep-a-Changelog 1.1.0 categories with release-please's output. release-please generates its own format (type-grouped, not Added/Changed/…), so automated CHANGELOG will not match the prescribed shape | CASCADE |
| AUD-010 | minor | GL-005 | standard-deviation | "Supply Chain" pillar lacks SLSA / OpenSSF Scorecard / NIST SSDF alignment: no build-provenance requirement, no artifact signing outside the release pipeline, no SBOM mention | SENTRY → principal |
| AUD-011 | nit | GL-003 · GL-004 · GL-005 | hygiene | `owner:` field uses `·` separator in GL-003, `;` in GL-004 and GL-005 — no canonical delimiter specified in GL-003's front-matter schema | QUILL |
| AUD-012 | nit | tasks/open/wikilink-port-backlog.md | hygiene | Backlog line 63 still reads "high-water mark GL-004 … numbering resumes at GL-005" — stale; GL-005 was authored 2026-05-30 | TOWER |

## Key wikilink resolution check

| Wikilink | Resolves? |
|---|---|
| `[[GL-NNN-commit-format]]` (GL-001:54) | NO — dangling; on backlog as AUD-003 |
| `[[GL-002-credential-custody]]` | YES |
| `[[SOP-close-session]]` | YES |
| `[[SOP-escalate-blocked]]` | YES |
| `[[ADR-0001-doc-system]]` | YES (stem `0001-doc-system`) |
| `[[SOP-rotate-credential]]` (GL-002, marked Future) | NO — known Phase-2 dangler |
| `[[SOP-audit-credentials]]` (GL-002/GL-005, marked Future) | NO — known Phase-2 dangler |
| `[[SOP-secret-scan]]` (GL-005, marked Future) | NO — known Phase-2 dangler |

Future-marked danglers are pre-declared; not re-reported per SENTRY contract.

## Overlap zone verdicts

- AI attribution (GL-001 vs GL-005): CONTRADICTS — GL-001 specifies only the commit trailer; GL-005 adds `<!-- AI-assisted -->` doc markers and cross-refs GL-001 as "one form of attribution," but GL-001 never mentions doc markers. The policy is split across two files with no explicit delegation.
- Dependency pinning (GL-004 vs GL-005): DELEGATES-CLEANLY — GL-005 states "pin dependency versions" (supply-chain hygiene); GL-004 specifies the exact mechanism (tagged version, repo-baselines.yaml, SENTRY weekly audit). No conflict.
- Secrets/adversarial-input (GL-002 vs GL-005): DELEGATES-CLEANLY — GL-005 states the principle ("treat inputs as adversarial"); GL-002 operationalises credential mechanics. GL-005's Related section explicitly delegates to GL-002.
- Numbering & cross-ref hygiene: MINOR-FIXES — GL-001 and GL-002 lack required front matter; `[[GL-NNN-commit-format]]` is one known live dangler; wikilink-port-backlog high-water line is stale (nit). No duplicate or out-of-sequence numbers; GL-001 through GL-005 are sequential with no gaps.
- Other contradictions/drift: No additional contradictions found. Terminology is consistent across the corpus (same terms: "harness," "principal," callsign names, "Conventional Commits").
