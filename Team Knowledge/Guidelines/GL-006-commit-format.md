---
form: reference
last-verified: 2026-05-31
owner: TOWER (policy); CASCADE (operational); principal (ratification)
status: authoritative
---

# GL-006 — Commit Format

**Status:** Authoritative. **Owner:** TOWER (policy); CASCADE (operational); principal (ratification).

Resolves the long-dangling commit-format reference (formerly an unnumbered placeholder). Extends `[[GL-001-commit-autonomy]]` (which defines only the subject envelope) with the body and trailer contract. Adopted 2026-05-31 (`security-standards-track` #2).

## Purpose

The commit message is the principal's **review and feedback surface**. When the team works autonomously (no principal in the loop), the message is how the principal later understands *what* changed, *which callsign* did it, and *what drove it* — so they can hint, course-correct, or file a fix against the right owner. The format optimizes for that, not for tooling ceremony.

## Subject (required)

Conventional Commits 1.0.0 envelope, per `[[GL-001-commit-autonomy]]`:

```
<type>(<scope>): <subject>
```

- `type` ∈ `feat fix docs chore refactor test build ci perf revert`
- `scope` — the area touched (a callsign, repo, or surface like `GL-001`, `ci`, `creds`)
- imperative mood, no trailing period, ≤ ~72 chars
- breaking change: `type!:` **and** a `BREAKING CHANGE:` footer (drives the changelog upgrade note — see `[[GL-004-release-versioning]]`)

## Body (recommended)

What changed and **why** — the diff already shows *how*. Skip it for trivially obvious mechanical commits. One blank line after the subject.

## Trailers (recommended, not enforced)

A trailer block at the foot, after a blank line:

```
Refs: <task-id | issue-url>
Harness-Agent: <CALLSIGN>
Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

- **`Harness-Agent:`** — the callsign that produced the commit (TOWER, CASCADE, …). This is the primary "who/where" signal the principal asked for: it tells them which hat to address when giving feedback or requesting a fix.
- **`Refs:`** — the driving task or delegation, when one exists.
- **`Co-Authored-By:`** — honest AI attribution. Names the model; uses a `noreply` address (it is disclosure, not a GitHub identity claim).

The old `Co-Authored-By: Claude/Opus/harness@<hostname> …` convention is **retired** — hostname is low-value (see the north star in `security-standards-track`) and the format was malformed for GitHub.

## Enforcement

**None in CI.** Trailers and body are recommended, not gated — the principal does not want CI cycles spent re-verifying trailers, and the team is **free to omit them in corner cases** (a one-line fixup, a mechanical sweep) without asking. The only hard expectation is the Conventional-Commit *subject*, because release-please consumes it (`[[GL-004-release-versioning]]`).

If trailer discipline ever proves too loose to review by, revisit — but the default bias is low friction.

## Related

- `[[GL-001-commit-autonomy]]` — autonomy, identity, signing model
- `[[GL-004-release-versioning]]` — how subjects drive the changelog and release notes
- `[[GL-005-code-of-conduct]]` — AI-attribution as a conduct obligation
