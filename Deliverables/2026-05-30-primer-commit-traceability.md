---
form: explanation
last-verified: 2026-05-30
owner: RECON (research); TOWER (synthesis)
status: draft
audience: principal
---

# Commit Traceability + Signing — Orientation Primer

**Purpose:** Build shared vocabulary so we can jointly decide a commit-traceability and signing standard for harness. Nothing here is implemented yet. Every section ends with what it buys you and what it costs.

---

## 1. Conventional Commits 1.0.0

### What it is

A standard for how a commit *message* is structured — purely text, nothing to do with keys or signatures. Think of it as a grammar rule for the subject line and body of every commit.

The canonical source is [conventionalcommits.org/en/v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

### The structure

```
<type>(<scope>): <subject>
                              ← blank line
<body>
                              ← blank line
<footer(s)>
```

**Type** — a fixed verb that categorises the change. The spec names two that have SemVer consequences:

| Type | Meaning | SemVer effect |
|---|---|---|
| `feat` | new capability | bumps MINOR |
| `fix` | bug patch | bumps PATCH |

All other common types (`docs`, `chore`, `refactor`, `ci`, `test`, `build`, `style`, `perf`) are convention, not spec-mandated — use them consistently and tooling (release-please, changelogs) picks them up.

**Scope** — optional, in parentheses. Names *what* area of the codebase. Examples: `feat(session-log):`, `chore(team):`, `fix(sentry):`. This is the field we'll use for callsign traceability.

**Subject** — short present-tense description, no period, immediately after the colon-space.

**Body** — one blank line after the subject, then free prose explaining *why* (not what — the diff shows what). May be multiple paragraphs.

**Footer(s)** — one blank line after the body (or subject if no body). Each footer is a `Token: value` pair. Two with formal meaning:

- `BREAKING CHANGE: <description>` — must be uppercase exactly; marks a MAJOR SemVer bump. Tooling like release-please keyes on this.
- `Fixes #N` / `Closes #N` — auto-closes a GitHub issue on merge.
- Any other token is valid and carries no automated meaning unless a tool is configured to read it.

An alternative shorthand for a breaking change: append `!` to the type, as in `feat!: rename core API`. This is equivalent to the footer form.

**Examples:**

```
feat(forge): add repo-bootstrap SOP

Replaces the ad-hoc shell notes in the team wiki.
Includes dry-run flag for safe first-pass.

Closes #42
```

```
fix!(session-log): remove deprecated date field

BREAKING CHANGE: session-log schema v2 drops the `ts_legacy` key.
Consumers on the old schema must migrate before upgrading.
```

### What GL-001 currently covers

GL-001 specifies `<type>(<scope>): <subject>` — the first line only. It does not mention:

- Body usage or the blank-line separator rule
- `BREAKING CHANGE:` footer
- `Fixes #N` / `Closes #N` closure tokens
- Any custom trailers (the lineage gap we address in section 2)

The upcoming `GL-006-commit-format` will close these gaps. Nothing needs to change in day-to-day practice for most commits — body and footer fields are optional. The spec just clarifies when and how to use them correctly.

**Buys you:** machine-readable commit history; release-please can auto-draft changelogs and version bumps from the message alone; reviewers see intent at a glance.

**Costs you:** discipline to type the right type and scope. Tooling (commitlint, a pre-commit hook) can enforce it automatically.

---

## 2. Git Trailers

### What a trailer is

A *trailer* is a structured key-value line at the very bottom of a commit message, separated from the body by one blank line. Git has a built-in parser (`git interpret-trailers`) that reads them. The format comes from RFC 822 email headers by convention, but git does not enforce the full RFC — it just recognises `Token: value` lines in the footer zone.

Reference: [git-scm.com/docs/git-interpret-trailers](https://git-scm.com/docs/git-interpret-trailers)

### Co-Authored-By: what GitHub does with it

`Co-Authored-By: Name <email>` is the GitHub-recognised trailer that credits a second author on a commit. GitHub surfaces this in the commit view and counts it as a contribution for the co-author.

**Critical rule:** the email in the trailer must be one that is *associated with a real GitHub account* — either the account's public email or its GitHub-issued no-reply address (`<username>@users.noreply.github.com`). If the email matches no account, GitHub renders the name as plain text with no profile link and no contribution credit.

Source: [GitHub Docs — Creating a commit with multiple authors](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors)

**Why the current template breaks down:**

GL-001 specifies:

```
Co-Authored-By: Claude/Opus/harness@<hostname> <noreply@anthropic.com>
```

This has two problems:

1. `noreply@anthropic.com` is not linked to a GitHub account. GitHub will not register a contribution or show a profile.
2. `Claude/Opus/harness@<hostname>` is not a valid GitHub username format, so even if the email matched something, the display would be wrong.
3. Hostname is now considered low-value signal (the roadmap's north star) — encoding it in the name field adds noise, not clarity.

The trailer is not wrong per se — it is a visible text record — but it does not deliver what it implies (a live profile link, a contribution count, a verified identity).

### The custom trailer approach

Because git will parse any `Token: value` line in the footer zone, we are free to define a custom trailer carrying exactly the lineage we care about:

```
Harness-Agent: claude-sonnet-4-6/RECON@harness
```

Anatomy: `model-id/callsign@system`. This is human-readable, machine-parseable with `git log --grep` or `git interpret-trailers --parse`, and honest — it claims no GitHub identity it does not have.

We can keep a `Co-Authored-By:` line too if we point it at the principal's no-reply address, which *does* resolve to a GitHub account. That correctly credits the principal as co-author (since they set up the system), and the `Harness-Agent:` trailer carries the AI attribution separately.

Example complete footer block:

```
Co-Authored-By: Alex Rechsteiner <arechste@users.noreply.github.com>
Harness-Agent: claude-sonnet-4-6/RECON@harness
```

**Buys you:** rich, honest lineage; the callsign signal the north star asks for; searchable with standard git tooling; no dependency on GitHub account matching for the AI attribution.

**Costs you:** one new trailer token to define in GL-006; agents must include it consistently (a template + pre-commit lint is sufficient).

---

## 3. Commit Signing Options

### What signing is (and is not)

A commit *message* is just text. Anyone could write `author: Alice` — git trusts whatever name and email you configure locally. **Signing** adds a cryptographic proof, attached to the commit, that the holder of a specific key produced it. Verifiers can confirm the proof without trusting the committer's text claims.

Signing is *attestation*, not *authentication*. It answers "did the key-holder approve this?" not "did a human sit at a keyboard?".

GitHub marks signed commits with a "Verified" badge when the signing key is registered in the account settings.

Git supports two signing mechanisms today: **GPG** (the classic, increasingly avoided) and **SSH** (the practical modern path). **Sigstore/gitsign** is a third-generation keyless option.

### Option (a): Unsigned team + principal-signed squash-merge (status quo)

How it works: the team makes unsigned commits on feature branches. When the principal merges via GitHub's "Squash and merge" button, GitHub creates a new merge commit signed with the principal's GitHub account key (since branch protection requires signed commits on `main`).

What you can prove from `main`:
- Every commit on `main` was approved by the principal's GitHub account.
- The feature-branch history (visible via PR) shows the work, but those commits carry no signature.

What you cannot prove:
- That any specific feature-branch commit was produced by any particular agent or callsign (the trailer text claims it but is not signed).
- That a feature-branch commit was not tampered with after the agent pushed it (before the principal reviewed it).

Key-availability concern: no team key exists, so there is nothing to custody. Simple.

**Buys you:** zero key management overhead; works today; principal retains sole signing authority.

**Costs you:** traceability gap on feature branches — trailers are self-asserted text, not attested.

### Option (b): SSH commit signing with a dedicated team key

How it works: generate one ed25519 SSH key pair. The private key is the team's signing key. Every commit the team makes is signed with this key. The public key is registered in GitHub under an account (the principal's, or a bot account if one exists), so GitHub shows "Verified" on team commits.

Git configuration needed in `harness/.gitconfig`:

```
[gpg]
    format = ssh
[user]
    signingkey = /path/to/team-signing-key.pub
[commit]
    gpgsign = true
[gpg "ssh"]
    allowedSignersFile = /path/to/allowed_signers
```

The `allowed_signers` file maps an email to the public key for local verification:

```
team@harness.local ssh-ed25519 AAAA...publickey...
```

Sources: [dev.to/ccoveille — complete SSH signing guide](https://dev.to/ccoveille/git-the-complete-guide-to-sign-your-commits-with-an-ssh-key-35bg); [git-tower.com — SSH commit signing setup](https://www.git-tower.com/blog/setting-up-ssh-for-commit-signing/)

**Key-availability during principal absence:** this is the hard constraint. If the private key lives only on the principal's laptop, the team is stranded when that machine is unavailable.

Custody options, from GL-002's existing direction (age/sops/1Password):

- **1Password (recommended path):** store the private key as a Secure Note or SSH key item in a 1Password vault. The 1Password SSH agent can inject it at signing time without the raw key ever touching the filesystem. 1Password supports [team vaults](https://developer.1password.com/docs/ssh/git-commit-signing/) — the key stays accessible on any machine where the 1Password app is installed and authenticated. If the principal is absent but the agent has vault access (via a service account or the principal's account on the agent host), signing continues uninterrupted. Source: [developer.1password.com — Sign Git commits with SSH](https://developer.1password.com/docs/ssh/git-commit-signing/)
- **age-encrypted key in harness repo:** the private key is encrypted with `age` (or `sops`). The decryption key (age identity) is stored in 1Password. On any machine with the identity available, `age -d` yields the signing key. This is the GL-002 model.
- **Fallback:** if neither 1Password nor the age identity is reachable, the team cannot sign. This is the failure mode to document in the break-glass SOP (Track 3).

**Buys you:** every team commit is cryptographically attested; "Verified" badge on feature-branch commits; audit trail is tamper-evident, not just text-asserted.

**Costs you:** key custody setup; the key must be available on every host the team runs on (solved by 1Password or age/sops); one-time configuration per host; the key's GitHub registration must be maintained.

### Option (c): Sigstore / gitsign — keyless signing

How it works: instead of a long-lived private key, Sigstore uses your existing OIDC identity (e.g., your GitHub login) to obtain a short-lived certificate from Sigstore's public certificate authority (Fulcio). That certificate is used to sign the commit and is logged to a public transparency ledger (Rekor). No key to store, no key to lose.

Sources: [sigstore/gitsign on GitHub](https://github.com/sigstore/gitsign); [docs.sigstore.dev/cosign/signing/gitsign](https://docs.sigstore.dev/cosign/signing/gitsign)

**Why it is premature for harness right now:**

1. **GitHub does not show "Verified"** for gitsign signatures. The Sigstore CA is not in GitHub's trust root. You get cryptographic proof but no badge — you'd need `gitsign verify` locally.
2. **Public transparency log.** All signatures are published to Rekor, a public append-only log. For private repos, your repo name, branch names, and commit metadata can appear in a public ledger. Sigstore acknowledges this and recommends a self-hosted Rekor for private use — which is significant operational overhead.
3. **OIDC browser prompt.** Each signing event may trigger a browser redirect for OIDC auth. Manageable in CI, friction in interactive sessions.
4. **No offline / absence path.** The signing ceremony requires network access to Fulcio and Rekor.

**Buys you:** strongest cryptographic guarantees; no key management; identity-bound proof.

**Costs you:** operational complexity; no GitHub "Verified" badge (not yet); public metadata leakage risk for private repos; not suitable as the team's absence-safe signing path.

### Comparison table

| Property | (a) Unsigned team | (b) SSH team key | (c) Sigstore/gitsign |
|---|---|---|---|
| Feature-branch commits verified | No | Yes | Yes (locally only) |
| Main commits verified | Yes (via principal squash) | Yes | Yes (locally only) |
| GitHub "Verified" badge | Main only | Yes (if key registered) | No (GitHub doesn't trust Sigstore CA) |
| Key to manage | None | 1 ed25519 key pair | None (short-lived) |
| Works during principal absence | Yes (no key needed) | Yes, if key in 1Password/age | Requires network + OIDC session |
| Private repo metadata safety | Full | Full | Risk (public Rekor log) |
| Setup effort | None (already done) | Low-medium | High |
| Maturity for private repos | Proven | Proven | Emerging |

---

## 4. Recommended `GL-006-commit-format` Straw-Man

This is a draft proposal for adopt-or-drop — not yet in force.

### Commit message format

```
<type>(<scope>): <subject>

[body — one or more paragraphs explaining WHY]

[Fixes #N | Closes #N]
[BREAKING CHANGE: <description if applicable>]
Co-Authored-By: Alex Rechsteiner <arechste@users.noreply.github.com>
Harness-Agent: <model-id>/<callsign>@harness
```

### Rules

1. **Type** — use one of: `feat`, `fix`, `docs`, `chore`, `ci`, `refactor`, `test`, `build`, `style`, `perf`. No other types without a GL amendment.
2. **Scope** — required (not optional). Must be one of: a callsign slug (`recon`, `forge`, `tower`, etc.), a repo name, or a harness surface (`team`, `pkm`, `sop`, `gl`, `session-log`). This is the primary traceability signal.
3. **Subject** — 72 characters max; present tense; no trailing period.
4. **Body** — include when the *why* is not obvious from the subject. Skip for mechanical changes (`chore(session-log): 2026-05-30 16:32`).
5. **`Co-Authored-By:`** — always use the principal's GitHub no-reply address (`arechste@users.noreply.github.com`). This resolves to a real account and registers correctly.
6. **`Harness-Agent:`** — always present on team commits. Format: `<model-id>/<callsign>@harness`. The model-id should match the actual model in use (e.g., `claude-sonnet-4-6`). Callsign is the hat worn for this commit.
7. **`BREAKING CHANGE:`** — required in footer (uppercase, exact spelling) whenever a change breaks a downstream consumer. May also use `!` shorthand in the type line, but the footer description is preferred for explanation.
8. **`Fixes #N` / `Closes #N`** — include whenever a commit resolves a tracked issue.

### Example (team commit on a feature branch)

```
feat(recon): add commit-traceability primer to Deliverables

Covers Conventional Commits 1.0.0, Git trailers, and three signing
options with key-availability analysis. Intended as shared vocabulary
before principal decisions on GL-006.

Co-Authored-By: Alex Rechsteiner <arechste@users.noreply.github.com>
Harness-Agent: claude-sonnet-4-6/RECON@harness
```

### Validation gate

Before adopting GL-006, verify these items — do not assume:

1. **GitHub co-author registration:** make a test commit with `Co-Authored-By: Alex Rechsteiner <arechste@users.noreply.github.com>` and confirm GitHub shows the principal's profile linked in the commit view. (The no-reply address format for a given user can be found at `github.com/settings/emails`.)
2. **`Harness-Agent:` parseability:** run `git log --format='%(trailers:key=Harness-Agent)' | head` on a repo after adopting the trailer to confirm git's trailer parser extracts it correctly.
3. **Commitlint config:** if adding a pre-commit hook to enforce the format, test that it does not reject valid multi-line footers (some configs are brittle on multi-trailer blocks).
4. **SSH signing custody path (if option (b) is chosen):** generate a test ed25519 key, store it in 1Password, configure the SSH agent, make a signed test commit, verify the "Verified" badge appears on GitHub after registering the public key in account settings.
5. **Track 0 (GL-004 / release-please):** confirm that the `changelog-sections` configuration in release-please can remap `feat`/`fix`/etc. to Keep-a-Changelog categories before finalising type vocabulary. See the roadmap's Track 0 note.

---

## What I Recommend and Why

**On commit format:** adopt Conventional Commits 1.0.0 in full (body + footer rules), with scope required. The partial implementation in GL-001 leaves the body and footer undefined, which causes drift. Low cost, high payoff for changelog automation.

**On trailers:** replace the current `Co-Authored-By: Claude/Opus/harness@<hostname>` template with two clean trailers: `Co-Authored-By:` pointing at the principal's GitHub no-reply address (honest, resolves correctly), and `Harness-Agent:` carrying model/callsign (honest, machine-parseable, no false GitHub identity claim). Drop hostname from the trailer — it is low-value per the north star.

**On signing:** stay with option (a) — unsigned team, principal-signed squash-merge — until the custody infrastructure (1Password SSH agent or age/sops key) is confirmed in place. The honest reason: trailers with option (a) give you *readable* lineage; what they do not give you is *tamper-evident* lineage on feature branches. For harness today (private repo, principal is the sole reviewer), readable lineage is the practical need. Escalate to option (b) when either (1) a second principal is added, or (2) the team starts committing to repos where the principal cannot review every PR before merge. Do not implement option (c) until GitHub adds Sigstore to its trust root and Rekor has a clear private-repo story.

**Trade-offs stated plainly:**
- Staying with (a) means the team's trailers are self-asserted text, not cryptographically attested. A sophisticated attacker could forge them. For the current threat model (one principal, private repos, all pushes go through GitHub's access controls), this is acceptable.
- Moving to (b) adds real tamper-evidence but introduces a key custody dependency. If the key custody step is skipped or done poorly, the team loses signing ability during absence — which is worse than the status quo.
- Doing nothing on trailer format costs nothing today but locks in a growing divergence between three drifting templates in GL-001, `.gitconfig`, and agent practice.

---

## Decisions the Principal Needs to Make

1. **Trailer standard:** adopt the two-trailer block (`Co-Authored-By` → principal's no-reply + `Harness-Agent` → model/callsign)? Or a different attribution model?
2. **Scope required vs optional:** should scope be mandatory in every commit, or optional? (Mandatory is better for callsign traceability; optional reduces friction on trivial commits.)
3. **Signing now or later:** stay with option (a) until a custody path is ready, or accelerate option (b) as part of Track 3 (credential lifecycle)?
4. **Bot account for team identity:** create a GitHub bot/machine account for the team (e.g., `harness-team[bot]`) so that `Co-Authored-By:` can point to a dedicated identity rather than the principal's account? (This is a clean separation but adds account overhead.)
5. **Enforcement gate:** add a commitlint pre-commit hook now, or rely on agent discipline until the GL is ratified?

---

## Sources

- Conventional Commits 1.0.0: [conventionalcommits.org/en/v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) — official spec, tier 1
- GitHub — Co-Authored-By requirements: [docs.github.com — Creating a commit with multiple authors](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors) — official vendor docs, tier 1
- git-interpret-trailers: [git-scm.com/docs/git-interpret-trailers](https://git-scm.com/docs/git-interpret-trailers) — official git docs, tier 1
- SSH commit signing full guide: [dev.to/ccoveille](https://dev.to/ccoveille/git-the-complete-guide-to-sign-your-commits-with-an-ssh-key-35bg) — community, tier 2; corroborated by [git-tower.com](https://www.git-tower.com/blog/setting-up-ssh-for-commit-signing/)
- 1Password SSH signing + team sharing: [developer.1password.com/docs/ssh/git-commit-signing](https://developer.1password.com/docs/ssh/git-commit-signing/) — official vendor docs, tier 1
- gitsign keyless signing: [github.com/sigstore/gitsign](https://github.com/sigstore/gitsign) — official project, tier 1; private-repo concerns noted in [chainguard.dev](https://www.chainguard.dev/unchained/keyless-git-commit-signing-with-gitsign-and-github-actions)
- Git trailers background: [alchemists.io/articles/git_trailers](https://alchemists.io/articles/git_trailers) — community, tier 2
