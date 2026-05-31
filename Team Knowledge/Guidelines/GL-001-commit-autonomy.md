---
form: reference
last-verified: 2026-05-30
owner: principal (policy); CASCADE (operational enforcement)
status: authoritative
---

# GL-001 — Commit Autonomy

**Status:** Authoritative. **Owner:** principal (policy); CASCADE (operational enforcement).

## Policy

The team commits **without principal approval per commit** on feature branches. The principal owns merges to `main` and signs them via GitHub's UI. No 1P-popup-per-commit. No paste-output-and-wait. No agent-blocking-on-human.

This trades commit-level review for **PR-level review**. The principal reviews complete changes as PRs; agents make small, frequent commits that document their thinking inline.

## The model

```
team work        →  feature branch (unsigned commits)  →  PR
                                                          ↓
                                               principal review
                                                          ↓
                              Squash and merge on github.com (signed by principal)
                                                          ↓
                                                       main
```

## Signing decision (ratified 2026-05-31)

The unsigned-team / principal-signs-at-merge model above is a **deliberate, ratified choice** (`security-standards-track` #1) — not a transitional gap. Rationale: it removes the per-commit 1Password approval friction the principal explicitly rejected, while the squash-merge signature on `main` still carries provenance. The `Harness-Agent` trailer (see `[[GL-006-commit-format]]`) records *which callsign* produced each commit — the "who/where" signal the principal reviews by.

**Revisit trigger:** stand up a dedicated team/bot signing key (held in 1P per `[[GL-002-credential-custody]]`) when work begins on shared repos outside harness — specifically the `ntnxlab.ch` / `github.com/ntnxlab-ch` org, where commits are collaborated on with humans who have no harness access and need verifiable provenance.

## Enforcement layers

### Layer 1: `harness/.gitconfig` (per-repo override)

Committed to harness root; auto-applied via the `[includeIf]` block that `bootstrap/setup-host.sh` writes to `~/.gitconfig`. Sets:

- `commit.gpgsign = false`
- `tag.gpgsign = false`
- `push.default = current`
- `pull.ff = only`
- `fetch.prune = true`

**Outside harness, signing is unchanged.** The principal's identity in dotfiles / dotclaude / git-organizer / fleet-organizer / aitools-common still signs normally.

### Layer 2: Branch protection on `main` (GitHub)

For every repo where the team commits:

- ✓ Require PR before merge
- ✓ Require at least 1 approving review (the principal)
- ✓ Require status checks to pass (CI)
- ✓ **Require signed commits on `main`** — the unsigned feature-branch commits get squashed into a single principal-signed merge commit
- ✓ Restrict force pushes
- ✓ Restrict deletions

### Layer 3: agent discipline

CASCADE (and any callsign filing a delegation) follows:

- Always work on a feature branch — never push directly to `main`
- Branch names: `team/<topic>` or `<callsign-lower>/<topic>` (e.g., `cascade/port-git-conventions`)
- Conventional commit format: `<type>(<scope>): <subject>` — see `[[GL-NNN-commit-format]]` once PORTed in Phase 2
- One logical change per commit; multiple small commits over one giant squash
- Commit trailer: `Co-Authored-By: Claude/Opus/harness@<hostname> <noreply@anthropic.com>` (the principal's commit-trailer convention, applied to team commits too — preserves authorship lineage even without signing)
- PR body from `harness/state/delegations/open/<repo>-<N>.md` mirror (the local SSOT); `gh pr create --body-file <mirror>`

## When the team CAN push directly

- Branch is the team's own feature branch (`team/*`, `<callsign>/*`)
- Branch is not `main` of any product repo
- Inside harness itself: the team may push directly to `main` of harness only after a `[[SOP-close-session]]` log entry exists for the change — harness is the workshop; over-process there is counterproductive
- Tag pushes follow whatever signing policy that repo wants (release tags on product repos = signed by principal)

## When the team CANNOT push

- `main` or `master` of any product repo (always PR)
- Any branch where the principal is the sole committer (e.g., `principal/*` if it ever exists)
- Force-push to any shared branch (`team/*` is fine to force-push while the PR is in draft; once review starts, only additive commits)

## Why "team unsigned" is safe

The signature on `main` is what matters for provenance. Branch protection on `main` requires signed commits — the merge commit (squashed) is signed by the principal's key, attesting "I, the principal, reviewed this and merge it." The feature-branch history is unsigned but is *evidence*, not authority. If a feature branch is ever cherry-picked or rebased onto main without re-signing, branch protection blocks it.

The team's commit *identity* still claims the principal as author (via the committed `~/.gitconfig` chain). The team's commit *attestation* (the signature) does not. This matches the truth: the team did the typing; the principal does the merging.

## Rollback / change

If the policy changes (e.g., principal wants team-signed commits with their own key):

1. Update `harness/.gitconfig` to re-enable signing and configure the team key
2. Update branch protection accordingly
3. Update this GL (don't delete; supersede)
4. New SOP entry under `PKM/Journal/` describing the change rationale

See `[[GL-002-credential-custody]]` for how team signing keys would be held if that direction is taken later.
