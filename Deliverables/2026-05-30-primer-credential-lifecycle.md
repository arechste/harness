---
form: explanation
last-verified: 2026-05-30
owner: RECON (research); TOWER (synthesis); SENTRY (audit)
status: draft
audience: principal
graduates-to: GL-002 amendments · SOP-rotate-credential · SOP-break-glass · SOP-audit-credentials
---

# Credential Lifecycle Management — Plain-Language Primer & Handling Plan

**Status:** DRAFT. Produced by RECON/TOWER 2026-05-30. Anchored to GL-002 current state.

---

## 1. Concept glossary (one sentence each)

| Concept | Plain meaning |
|---|---|
| **Issuance** | The moment a credential (a token, key, or password) is created and handed to whoever will use it. |
| **Inventory** | A list of every credential that exists, who owns it, what it can access, and when it expires — without recording the actual secret value. |
| **Expiry** | A built-in countdown on a credential; when it hits zero the credential stops working and must be replaced. |
| **Rotation** | Swapping out a credential before it expires: generate the new one, verify it works, revoke the old one. |
| **Revocation** | Immediately killing a credential — no countdown — because it was exposed, stolen, or no longer needed. |
| **Least privilege** | Giving a credential permission to do exactly what is needed, nothing more; if it leaks, the damage is bounded. |
| **Blast radius** | How bad things get if a specific credential is stolen — a token scoped to one repo has a small blast radius; an org-admin token has a large one. |
| **Break-glass** | A pre-planned emergency path that grants access when normal routes (e.g., your password manager) are unavailable — used rarely, audited always. |
| **Short-lived / derived cred** | A credential that lives for minutes or hours, minted on demand, discarded after use; reduces the value of any given theft. |

---

## 2. Standards context

### OWASP Secrets Management Cheat Sheet

The OWASP cheat sheet is the closest thing to a practitioner standard for exactly this problem space. Key points relevant here:

- "You should regularly rotate secrets so that any stolen credentials will only work for a short time."
- Lifetime is risk-driven, not fixed: "Depending on a secret's function and what it protects, the lifetime could be from minutes to years."
- Dynamic / short-lived secrets are strongly preferred: "When an application starts, it could request its database credentials, which, when dynamically generated, will be provided with new credentials for that session. Dynamic secrets should be used where possible."
- "You should create secrets to expire after a defined time where possible."

The cheat sheet does not mandate a specific rotation period (e.g., 90 days). That figure is a reasonable operational default derived from common enterprise practice and NIST SP 800-53 recommendations for privileged credentials.

Source (Tier 1 — OWASP official): https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html

### NIST SSDF — PO.5 (Secure Environments for Development)

The NIST Secure Software Development Framework (SP 800-218) practice group PO.5 covers protecting development environments. PO.5.1 requires separating and protecting environments; PO.5.2 requires hardening development endpoints and "monitoring and auditing all use of privileged access."

Break-glass is not a separate SSDF practice by that name, but it falls directly under PO.5's mandate: emergency privileged access must be pre-authorized, documented, and fully audited — the access-control exception that proves the rule.

Note: The roadmap doc (2026-05-30-signing-and-security-standards.md) cites "NIST SSDF PW.7.2" as the emergency-access anchor. That is a misattribution; PW.7.2 is actually about code review. The correct SSDF anchor is PO.5 / PO.5.1. This conflict is flagged here rather than silently corrected; the roadmap doc should be amended on next edit.

Source (Tier 1 — NIST official): https://csrc.nist.gov/pubs/sp/800/218/final

---

## 3. Inventory-first plan

### Why inventory before rotation

You cannot rotate what you have not found. The principal already has long-lived PATs in circulation. An inventory pass surfaces what exists and what is about to expire, so rotation becomes planned rather than reactive.

### What the inventory record captures (per credential)

| Field | Purpose | Stores secret? |
|---|---|---|
| `name` | Human-readable label (e.g., "harness-github-pat") | No |
| `type` | Token class: PAT / age-key / API-key / service-account | No |
| `issuer` | Where it was issued: GitHub / 1Password / etc. | No |
| `scope` | What it can access: repo list, org, read-only, write, admin | No |
| `owner` | Who is responsible: principal / automated | No |
| `created` | ISO date when it was issued | No |
| `expires` | ISO date when it expires (or "no-expiry" for flagging) | No |
| `last-rotated` | ISO date of last rotation | No |
| `blast-radius` | Low / Medium / High — assessed by owner | No |
| `rotation-policy` | Which policy row applies (see Section 4) | No |
| `location-canonical` | Where the live value lives: 1P vault item name | No |
| `location-operational` | sops file path, if mirrored | No |
| `notes` | Any anomalies, manual steps, dependencies | No |

No secret value is stored here, ever.

### Where it lives in harness

Proposed path: `state/credentials/INVENTORY.yaml`

YAML is preferred over Markdown for this file because it is machine-readable and SENTRY scripts can parse it without fragile text extraction. The file is committed to git (it contains no secrets), which gives a change history and lets SENTRY's audit scripts diff it.

Example record:

```yaml
# state/credentials/INVENTORY.yaml
# Fields: see primer §3. No secret values.
credentials:
  - name: harness-github-pat
    type: PAT-fine-grained
    issuer: github.com
    scope: "5 product repos; contents:write, metadata:read"
    owner: principal
    created: "2026-01-01"
    expires: "2026-12-31"
    last-rotated: "2026-01-01"
    blast-radius: Medium
    rotation-policy: 90d-standard
    location-canonical: "op://harness-team/github-pat"
    location-operational: "state/credentials/github-pat.sops.yaml"
    notes: ""

  - name: harness-age-key
    type: age-secret-key
    issuer: age-keygen (local)
    scope: "encrypts all state/credentials/*.sops.yaml"
    owner: principal
    created: "2026-01-01"
    expires: "no-expiry"
    last-rotated: "2026-01-01"
    blast-radius: High
    rotation-policy: annual
    location-canonical: "op://harness-team/age-key"
    location-operational: "volatile session file only"
    notes: "Rotation requires re-encrypting all sops files"
```

### CLI commands to populate expiry metadata (value-free)

These commands emit metadata only. They do not print token values.

**GitHub — list PATs and their expiry via the web UI (no API gap):**

The GitHub REST API for fine-grained PAT expiry has a known reliability issue: the `github-authentication-token-expiration` response header has been reported to return the current server time instead of actual expiry for fine-grained tokens (confirmed open issue as of 2025). The correct inventory method for GitHub PATs is:

1. Visit `https://github.com/settings/tokens` to view expiry dates visually.
2. Record them manually in `INVENTORY.yaml`.
3. SENTRY's expiry-alert script then operates on the YAML dates, not the API.

For classic PATs, `gh api /user/installations` and related endpoints return metadata; expiry is not in the token list API either. The manual recording step is not avoidable for the initial inventory pass.

**1Password — list vault items and their tags (no values):**

```bash
# List all items in harness-team vault: title, id, last-modified only
op item list --vault harness-team --format json \
  | jq '.[] | {title, id, updated_at}'
```

```bash
# Show fields for a specific item (labels only, not values) using --format json
op item get github-pat --vault harness-team --format json \
  | jq '.fields[] | {label, type}'
```

```bash
# List items whose tags include an expires: prefix
op item list --vault harness-team --format json \
  | jq '.[] | select(.tags[]? | startswith("expires:")) | {title, tags}'
```

The `op item list` command does not print field values. The `op item get --format json` command does include field values in its output — do not use it for inventory purposes unless you pipe the output to `jq` and filter out `value` fields, or use `--fields label=...` for non-secret labels only.

**age key — there is no expiry; flag it with rotation-policy: annual in the YAML.**

---

## 4. Rotation policy

### Policy table

| Credential class | Example | Max age (default) | Max age (tuning) | Who rotates | Automation hook |
|---|---|---|---|---|---|
| GitHub fine-grained PAT — write scope | harness-github-pat | 90 days | Up to 180d if scope is narrow read-only | Principal (manual, browser) | SENTRY alert at T-14d; script prepares sops update after principal confirms new value |
| GitHub PAT (classic) — if any remain | legacy tokens | 90 days | Deprecate; migrate to fine-grained | Principal | SENTRY alert at T-14d; flag for migration |
| API keys — cloud providers | (future) | 90 days | Up to 180d if read-only, no billing access | Principal | SENTRY alert at T-14d |
| API keys — high blast radius | (future org-admin) | 30 days | Not tunable upward | Principal | SENTRY alert at T-7d |
| age secret key | harness-age-key | 12 months | Not tunable upward | Principal (full rotation: re-encrypt all sops files) | SENTRY annual reminder |
| Service account tokens / GitHub App installation tokens | (future) | 1 hour (auto-expire) | Not applicable; mint-and-discard | Automated | None needed; by design |
| Short-lived OIDC tokens | (future CI) | Job duration only | Not applicable | Automated | None needed; by design |

**Tuneability note:** The 90-day default is the safe starting point. Once the INVENTORY.yaml is populated, each credential can be re-assessed on blast-radius. Low blast-radius (read-only, single-repo scope) can move to 180d. High blast-radius should move to 30d. Change the `rotation-policy` field in the YAML to record the decision.

**The rotation procedure itself (GL-002 already describes this):** principal generates new value at source, updates 1P, re-seeds the sops file, commits, revokes old value. The principal owns all rotation steps end-to-end; agents assist with expiry alerts and file prep only.

---

## 5. Short-lived and throwaway credentials

### Where you are now

All current harness credentials are long-lived: a PAT set to expire up to a year out, and an age key with no expiry. These are manageable but require active rotation discipline.

### Options on the short-lived spectrum

**GitHub fine-grained PATs — current ceiling: 366 days**

Fine-grained PATs became generally available in March 2025 (GitHub changelog). The maximum lifetime on personal accounts is 366 days; organizations can enforce shorter maximums (down to 1 day). They are strictly scoped to named repos and named permissions — a meaningful improvement over classic PATs. They do not auto-rotate; the principal must regenerate before expiry.

**GitHub App installation tokens — ~8 hours, practical now**

A GitHub App registered to your account or org issues "installation access tokens" that expire in approximately 8 hours by default. The workflow: the App authenticates with a short-lived JWT (signed with the App's private key, 10-minute lifetime) and exchanges it for an installation token. The installation token is what does the actual API work.

This is feasible now for harness CI automation. The cost: you register a GitHub App, store its private key in 1P, and have FORGE's scripts mint installation tokens at task-start and discard them at task-end. No long-lived PAT in the sops files at all for CI operations. Blast radius drops dramatically: a stolen 8-hour token expires before most attackers can weaponize it.

**GitHub Actions OIDC — no stored credential at all, future state**

When a GitHub Actions workflow runs, GitHub's OIDC provider can issue a short-lived JSON Web Token for the job. Cloud providers (AWS, GCP, Azure) can be configured to trust this token and issue a short-lived cloud credential in exchange — no PAT, no stored secret. The job's `id-token: write` permission enables this; the exchange happens inside the workflow without any principal-held secret.

For harness, this is the end-state for any CI that targets cloud providers. It eliminates an entire class of credential from the inventory. It requires cloud-side configuration (trust policy setup), which is a one-time principal action.

**Feasibility summary:**

| Option | Feasible now | What it needs |
|---|---|---|
| Fine-grained PAT, short max-age | Yes | Principal sets 90d expiry at creation time |
| GitHub App installation tokens | Yes, with setup | Register App, store App private key in 1P, update FORGE scripts |
| GitHub Actions OIDC | Yes for cloud targets | Cloud-side trust policy setup; no harness secret needed |
| OIDC for GitHub-to-GitHub | Limited | GitHub-to-GitHub OIDC is not currently supported for PAT replacement |

---

## 6. Break-glass design

### The problem

Harness's entire operational credential chain runs through 1Password. If 1P is unavailable — account lockout, forgotten master password, 1P service outage, device loss — the age key cannot be fetched, and all sops-encrypted operational credentials become unreadable. During an incident, this could mean you cannot authenticate to GitHub or any other service to respond.

The break-glass path exists to avoid that outcome. It is used rarely, it is principal-only, and agents never self-serve from it.

### Options

**Option A — 1Password Emergency Kit (printed, physical safe)**

1P generates an Emergency Kit PDF containing your sign-in address, email address, and Secret Key. You write your master password on it. Printed and stored offline (safe, lockbox, bank safe-deposit box), this lets you sign in from any device to 1P.com and recover full vault access.

- Pro: Uses 1P's own recovery path; covers account lockout and device loss.
- Pro: No separate secret management problem — the Kit is the fallback, not a second vault.
- Con: Requires physical access to the storage location. Does not help during a remote incident if you cannot reach the safe.
- Con: If the Kit is stolen, your 1P vault is compromised.

**Option B — 1Password Recovery Code (digital, separate secure store)**

1P also issues a Recovery Code distinct from the Emergency Kit. It can be stored in a separately managed location (e.g., a different password manager, an encrypted file on a hardware security key, a printed code in a separate safe).

- Pro: Can be accessed remotely if you store it in a second credential store.
- Con: Adds a second credential store, creating a second inventory problem.

**Option C — Sealed offline backup of the age secret key**

Store a copy of the age secret key (the text exported by `age-keygen`) in a separately encrypted offline form — for example, encrypted with a GPG key or a Yubikey-protected passphrase, written to a USB drive, stored physically.

- Pro: Bypasses 1P entirely; you can decrypt sops files without 1P.
- Con: Harder to manage; adds a third custody surface; key rotation becomes more complex.
- Con: Does not recover 1P itself; you would still need to regenerate all credentials at source (GitHub, etc.) using break-glass procedures there.

### Recommendation: Option A with a documented runbook

Store the printed 1Password Emergency Kit in a physical location you control and can access during an emergency (home safe or equivalent). Write the master password on one copy and seal it.

Reasons:
1. It covers the most likely failure mode (device loss, forgotten password, account lockout) with a single artifact.
2. It uses 1P's native recovery path, which is well-documented and tested.
3. It does not introduce a new credential storage surface.
4. If 1P is unavailable due to a service outage rather than account lockout, wait for service restoration — 1P has published 99.9%+ uptime; an outage is unlikely to coincide with an incident requiring harness credentials.

Augment with: a short break-glass runbook filed at `Team Knowledge/SOPs/SOP-break-glass.md` (to be authored), covering:

```
BREAK-GLASS RUNBOOK (principal-only)

Trigger: 1Password vault inaccessible; incident response requires credentials.

Step 1. Retrieve printed Emergency Kit from [physical location].
Step 2. Sign in to 1password.com using sign-in address, email, Secret Key, and master password from the Kit.
Step 3. Retrieve the age secret key from op://harness-team/age-key.
Step 4. Manually place it at $SOPS_AGE_KEY_FILE (see GL-002 path).
Step 5. Proceed with normal session credential access.
Step 6. After incident, record the break-glass use in the session log.
Step 7. If the Kit was removed from secure storage for any period, treat it as potentially compromised and regenerate it.

Agents NEVER self-serve from break-glass paths. This runbook is principal-only.
```

---

## 7. Automation sketch

### What SENTRY (scripts) can do — within the no-exposure rule

| Task | How | Machine-safe? |
|---|---|---|
| Parse INVENTORY.yaml and report credentials expiring within N days | Read YAML, compare `expires` to today's date, emit report | Yes — no values accessed |
| Generate a rotation-due task file in `Team Knowledge/tasks/open/` | Write a task file with name, policy, expiry, and manual steps | Yes |
| Alert at T-14 days and T-7 days before expiry | Cron-triggered script reads INVENTORY.yaml, writes task or sends notification | Yes |
| Prepare the sops file update scaffold (empty yaml, correct encryption rule) | Write the destination path and sops config; stop before the value arrives | Yes |
| Audit session log for undocumented credential reads | Parse session logs for sops/op read events vs INVENTORY | Yes |
| Verify all sops files have a corresponding INVENTORY.yaml entry | Cross-reference `state/credentials/` directory against INVENTORY | Yes |

### What the principal must do (human steps)

These steps cannot be delegated to agents under the no-exposure rule. Where exact instructions are needed, they are listed here so the principal can copy-paste:

**Generate a new GitHub fine-grained PAT (browser):**
1. Go to https://github.com/settings/tokens?type=beta
2. Click "Generate new token."
3. Set name, expiry (e.g., 90 days), repository access (named repos only), and permissions (minimum needed).
4. Copy the token value immediately (shown once).
5. In 1Password, open the `harness-github-pat` item, update the `credential` field with the new value.
6. Update the `expires` tag on the item (format: `expires:YYYY-MM-DD`).

**Seed the sops file after updating 1P (terminal, run yourself):**
```bash
op read op://harness-team/github-pat/credential \
  | yq -P '{credential: .}' \
  | sops --encrypt \
      --age "$(yq '.creation_rules[0].age' harness/.sops.yaml)" \
      --input-type yaml --output-type yaml /dev/stdin \
  > harness/state/credentials/github-pat.sops.yaml
```

**Update INVENTORY.yaml after rotation:**
Update the `last-rotated` and `expires` fields for the relevant credential entry.

**Revoke the old PAT (browser):**
1. Go to https://github.com/settings/tokens?type=beta
2. Find the old token by name (add "-old" suffix before rotation, or note its ID).
3. Click "Delete."

**Regenerate 1P Emergency Kit after any credential rotation (browser):**
If the Emergency Kit contains a hand-written note of the age key or any credential value, update it after rotation.

### Clean separation summary

```
SENTRY/scripts can do:
  ✓ Read INVENTORY.yaml dates and compute days-to-expiry
  ✓ Create rotation-reminder task files
  ✓ Audit session logs
  ✓ Cross-reference sops files vs inventory

Principal must do:
  ✓ Generate new credential value at source (browser/CLI)
  ✓ Update 1P vault item
  ✓ Run the sops re-seed command (shown above)
  ✓ Update INVENTORY.yaml metadata
  ✓ Revoke old credential at source
  ✓ Any break-glass recovery
```

---

## Summary artifacts

### Recommended INVENTORY schema

File: `state/credentials/INVENTORY.yaml`

Fields per entry: `name`, `type`, `issuer`, `scope`, `owner`, `created`, `expires`, `last-rotated`, `blast-radius`, `rotation-policy`, `location-canonical`, `location-operational`, `notes`.

No secret values. Committed to git. SENTRY scripts parse it for expiry alerts.

### Rotation table (compact)

| Class | Default max age | Tunable upper limit | Who acts |
|---|---|---|---|
| GitHub PAT (any scope write) | 90 days | 180 days (read-only, narrow scope) | Principal |
| GitHub PAT (classic) | 90 days then migrate | — | Principal |
| API key, high blast-radius | 30 days | Not tunable upward | Principal |
| age secret key | 12 months | Not tunable upward | Principal |
| GitHub App installation token | ~8 hours (auto) | N/A | Automated |
| OIDC token | Job duration | N/A | Automated |

### Break-glass recommendation

**Print the 1Password Emergency Kit and store it in a physical safe.** This is the simplest, most reliable path that covers device loss, account lockout, and forgotten master password. Pair it with a SOP-break-glass runbook (to be authored) that the principal can execute without any agent assistance. Agents never self-serve from this path.

---

## Decisions for the principal

1. **Start the inventory now.** Visit https://github.com/settings/tokens?type=beta, record all existing PATs in `state/credentials/INVENTORY.yaml` (name, scope, expiry). This is the single highest-value first step — nothing else can be automated until the inventory exists.

2. **Print and store the 1P Emergency Kit.** Do this before the inventory work, not after. If 1P locks during the inventory process, you need a recovery path.

3. **Set a rotation policy.** Decide whether 90-day default applies to all current PATs, or whether any qualify for 180-day (read-only, narrow scope). Record the decision in `rotation-policy` in the INVENTORY.yaml.

4. **Decide on GitHub App migration for CI.** Using App installation tokens (8-hour expiry) instead of PATs for any automated operations is feasible now and dramatically reduces blast radius. If harness has or plans CI workflows that call the GitHub API, this is worth setting up in the next 30 days.

5. **Authorize SENTRY's expiry-alert script.** Once the inventory exists, task FORGE with building the T-14/T-7 day alert script. It is safe (reads YAML dates only, no secrets), and prevents the "credentials expired during an incident" scenario that this whole plan is designed to avoid.

---

## Source log

| Source | Tier | Date accessed |
|---|---|---|
| OWASP Secrets Management Cheat Sheet — https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | Tier 1 (OWASP official) | 2026-05-30 |
| NIST SP 800-218 SSDF overview — https://csrc.nist.gov/pubs/sp/800/218/final | Tier 1 (NIST official) | 2026-05-30 |
| GitHub fine-grained PAT GA announcement (March 2025) — https://github.blog/changelog/2025-03-18-fine-grained-pats-are-now-generally-available/ | Tier 1 (GitHub official) | 2026-05-30 |
| GitHub PAT rotation policies preview (Oct 2024) — https://github.blog/changelog/2024-10-18-new-pat-rotation-policies-preview-and-optional-expiration-for-fine-grained-pats/ | Tier 1 (GitHub official) | 2026-05-30 |
| GitHub token expiration documentation — https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/token-expiration-and-revocation | Tier 1 (GitHub official) | 2026-05-30 |
| GitHub OIDC for GitHub Actions — https://docs.github.com/en/actions/concepts/security/openid-connect | Tier 1 (GitHub official) | 2026-05-30 |
| 1Password Emergency Kit — https://support.1password.com/emergency-kit/ | Tier 1 (1Password official) | 2026-05-30 |
| GitHub fine-grained PAT expiry API bug — https://github.com/google/go-github/issues/3708 | Tier 2 (GitHub community issue, open) | 2026-05-30 |
| GL-002-credential-custody.md | Internal SSOT | 2026-05-30 |
| 2026-05-30-signing-and-security-standards.md (roadmap, Track 3) | Internal draft | 2026-05-30 |

### Conflict flag for roadmap owner

The roadmap doc `2026-05-30-signing-and-security-standards.md` cites "NIST SSDF PW.7.2" as the anchor for emergency-access procedures. Research confirms PW.7.2 is the code-review practice, not an emergency-access provision. The correct SSDF anchor is **PO.5 / PO.5.1** (Implement and Maintain Secure Environments; audit all privileged access). The roadmap doc should be corrected on next edit. This is a citation error, not a policy error — the intent of citing emergency-access standards is correct.
