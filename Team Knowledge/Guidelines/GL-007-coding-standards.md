---
form: reference
last-verified: 2026-05-31
owner: SPARK (engineering domain); QUILL (authoring); principal (ratification)
status: authoritative
ported-from: dotclaude/home/rules/coding-standards.md @ baseline-sha 4a01477
port-verdict: adapted-from-source (intent-mined; fully tool-agnostic)
---

# GL-007 — Coding Standards

**Status:** Authoritative. **Owner:** SPARK (engineering domain); QUILL (authoring); principal (ratification).

## Policy

Three pillars govern how the team writes software — general craft, testing, and architecture. They apply to every artifact the team produces in any product repo, regardless of language or tool.

## Craft

- **Follow existing project conventions over personal preferences.** The codebase's idiom wins; consistency is worth more than any single "better" style.
- **Use consistent indentation** — detect it from the file, never mix tabs and spaces.
- **Prefer explicit over implicit.** No magic, no hidden behavior; the reader should not have to guess.
- **Keep functions small and focused on a single responsibility.**
- **Name things clearly** — code should read like prose.
- **Don't comment the obvious; do comment the non-obvious "why."** Rationale ages well; restating the code does not.
- **Prefer composition over inheritance.**
- **Handle errors at the appropriate level**, not everywhere — let them propagate to where there's enough context to act.
- **Write code that's easy to delete, not easy to extend.** Deletability is the truest measure of low coupling.

## Testing

- **Test behavior, not implementation details** — tests that assert on internals break on every refactor.
- **Prefer real dependencies over mocks; mock only at system boundaries.**
- **Write a regression test for every bug fix** — the test is the proof the bug is gone and stays gone.
- **Name tests to describe the expected behavior.**
- **Keep tests independent** — no shared mutable state between tests.
- **One assertion per concept** — multiple assertions in a test are fine when they cover one behavior.

## Architecture

- **Dependencies point inward** — core logic has no external dependencies.
- **Keep interfaces thin;** hide implementation behind clear contracts.
- **Configuration at the edges,** not scattered through business logic.
- **Separate pure logic from side effects** (IO, network, filesystem).
- **Prefer explicit wiring over framework magic.**
- **Design for deletion** — each module should be removable without cascading changes.

## Provenance

Ported from `dotclaude/home/rules/coding-standards.md` (baseline SHA `4a01477` per `state/repo-baselines.yaml`). The source was tool-agnostic prose with no Claude mechanics (see `Deliverables/2026-05-29-dotclaude-domain-intent-brief.md` §1 — classified "already 100% tool-agnostic"). The port preserves all three pillars and every rule, adds rationale to the non-obvious ones, and integrates harness cross-links. Second port in the dotclaude rule set after `[[GL-005-code-of-conduct]]` (the calibration sample).

## Related

- `[[GL-005-code-of-conduct]]` — security, attribution, supply-chain discipline (the calibration PORT sample)
- `[[GL-003-doc-authoring]]` — the authoring standard these Guidelines themselves follow
- `[[GL-001-commit-autonomy]]` — commit message + trailer rules for landing code
