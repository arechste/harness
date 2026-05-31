---
form: reference
last-verified: 2026-05-30
owner: SENTRY (audit + policy); FORGE (operational plumbing); principal (vault contents)
status: authoritative
---

# GL-002 — Credential Custody

**Status:** Authoritative. **Owner:** SENTRY (audit + policy); FORGE (operational plumbing); principal (vault contents).

## Policy

Team credentials follow a **two-tier custody model**:

| Tier | Where it lives | Encryption | Access pattern |
|---|---|---|---|
| **Canonical** | 1Password `harness-team` vault | 1P (AES-256-GCM, cloud-synced, biometric) | Principal manages; agents never write here |
| **Operational** | `harness/state/credentials/*.sops.yaml` | sops + age (committed to git) | Agents read on demand via `sops -d` |

The bridge between them is **the team's age secret key, held in 1P as a vault item**. Session unlocks the age key once via `op read`; the on-disk operational copies are then decryptable until 1P locks.

## Why two tiers

- **1P alone** = secrets aren't on disk, but every read requires an interactive 1P unlock — friction kills autonomy.
- **sops alone** = no central authority, no clean rotation, no cloud-synced recovery if the workshop dies.
- **Both** = 1P is the master copy + escrow; sops gives the team frictionless day-to-day access while ≥1 session is alive.

## Session lifecycle

```
session start
    ↓
TOWER (or any callsign that needs creds) runs:
    op read op://harness-team/age-key > $SOPS_AGE_KEY_FILE
    chmod 600 $SOPS_AGE_KEY_FILE
    ↓
Agents read individual creds on demand:
    GH_TOKEN=$(sops -d harness/state/credentials/github-pat.sops.yaml | yq .credential)
    ↓
On session close (SOP-close-session):
    shred -u $SOPS_AGE_KEY_FILE 2>/dev/null || rm -f $SOPS_AGE_KEY_FILE
    ↓
1P locks (auto, on macOS sleep / inactivity) → no further age-key fetches possible
    ↓
On-disk creds become opaque until next session unlocks 1P
```

The "session-scoped" property is emergent: there's no daemon watching session state. The age key is volatile (`/tmp/...` or `${HOME}/.cache/harness/`), wiped at close-session, only refetchable by re-unlocking 1P. When 1P auto-locks, the team can't get a new key — operational creds become inaccessible without a fresh principal-side unlock.

## Path layout

```
harness/state/credentials/         ← committed sops-encrypted operational creds
    github-pat.sops.yaml           ← GH fine-grained PAT for the 5 product repos
    github-team-pat.sops.yaml      ← (future) separate PAT for team commits
    docker-hub.sops.yaml           ← (future) if needed
    ...
harness/.sops.yaml                 ← sops creation rules: which age key encrypts what
```

`.sops.yaml` example (committed):

```yaml
creation_rules:
  - path_regex: ^state/credentials/.*\.sops\.yaml$
    age: age1XXXXXXXXXXXXX...  # the team age public key — safe to commit
```

The matching age **secret** key is in 1P as `op://harness-team/age-key`. Only the principal puts it there.

## Vault structure (1P)

```
harness-team (vault)
├── age-key                  ← Secure Note holding the age secret key
├── github-pat               ← API Credential, fine-grained, scoped to the 5 repos
├── github-team-pat          ← (future, if going to team-signed commits per GL-001)
└── <future tokens>
```

Vault sharing: principal-only by default. If a future scope needs multi-principal access (e.g., second seat), it shares to a 1P group, not to individuals.

## What agents must NOT do

- **Never** `op read` a credential and write it to a non-encrypted on-disk file (other than the volatile age-key file above)
- **Never** echo credentials to chat output or commit them by accident — pre-commit hooks should catch this; SENTRY audits prove it
- **Never** request credentials they don't need for the current task — least privilege
- **Never** create new vault items — only the principal can write to `harness-team`. Agents request a new credential via a task filed for the principal

## What agents MUST do

- Read credentials only when needed; do not preload them at session start unless an SOP explicitly says so
- Quote with `$SOPS_AGE_KEY_FILE` (the path) when invoking sops; never pass the key inline on a command line
- Audit log: every credential read is recorded in `Team Knowledge/session-logs/` (just the *fact* of the read, never the value)
- On unexpected access failures (1P locked, key missing, sops decryption error), call `[[SOP-escalate-blocked]]` — do not retry with a different credential

## Seeding flow (principal-side, one-time per credential)

```bash
# 1. Principal generates a new fine-grained PAT at github.com/settings/tokens
# 2. Stores it in 1P (use the interactive form so the value is never on the shell history):
op item create --vault harness-team --category 'API Credential' \
    --title 'github-pat' \
    --tags 'scope:5-product-repos,expires:2026-12-31'
# Then in the 1P UI add a field named 'credential' with the PAT value.

# 3. Mirrors to sops on disk (encrypted to the team age public key):
op read op://harness-team/github-pat/credential \
    | yq -P '{credential: .}' \
    | sops --encrypt --age "$(cat harness/.sops.yaml | yq .creation_rules[0].age)" \
        --input-type yaml --output-type yaml /dev/stdin \
    > harness/state/credentials/github-pat.sops.yaml

# 4. Commit the encrypted file. Safe — only the age secret key decrypts it.
cd harness && git add state/credentials/github-pat.sops.yaml && \
    git commit -m 'chore(creds): seed github-pat'
```

The seeding step uses `op` directly because the principal is interactive. Agents never seed.

## Rotation policy (ratified 2026-05-31)

`security-standards-track` #5. **No fixed cadence yet** — set it only after the inventory is complete and each credential's blast-radius is assessed. Rotating blind, on a calendar, over an unknown inventory is theatre.

Sequence:

1. **Inventory + blast-radius first.** `state/credentials/INVENTORY.yaml` is the surface; `ci/scripts/check-credential-expiry.sh` (weekly cron) warns at T-14/T-7. The PAT walk is still blocked on `[[project_browser-profiles-prereq]]`.
2. **Rotate highest-blast-radius first**, deliberately, once the inventory exists.
3. Candidate cadence to ratify later: 90d high-blast / 180d low-blast — **not adopted now**.

**Recoverability rule (hard).** harness is operated *by* the team; an in-flight credential change carries real lock-out risk. Therefore: **never rotate or revoke the last working credential without a tested fallback in hand** — a second valid credential, or a verified ability to re-mint. The principal must have full confidence the team can be recovered (or recover itself) before any rotation proceeds. If no fallback is verified, stop and escalate (`[[SOP-escalate-blocked]]`).

## Rotation procedure

When a credential rotates:

1. Principal generates new value, updates 1P vault item
2. Principal re-seeds the sops file (re-run the seeding flow's step 3)
3. Commits the updated sops file
4. Old credential should be revoked at the source (GitHub, etc.) once the new one is verified working

SENTRY periodically audits: vault items with `expires:` tags approaching their date, sops files older than N months. Findings → tasks for the principal.

## Break-glass (interim posture, 2026-05-31)

`security-standards-track` #5. Emergency access if normal credential paths fail. The interim posture is the principal's existing setup — **no new artifacts required**:

- Principal retains interactive 1Password account access; 1P **master-password recovery codes** exist.
- Recovery keys for important credentials the team and principal use are **stored in 1P** itself.
- As long as the principal can reach 1P interactively, full recovery is possible.

**Single point of failure:** total loss of 1P *account* access (not merely a lost device). That is the one scenario the interim posture does not cover.

**Deferred mitigation:** a printed 1Password Emergency Kit in a physical safe would close that gap. The principal is reluctant to keep paper and may adopt it later — it is *recommended, not required* now. Until then the residual risk is accepted and recorded here.

Agents never self-serve from any break-glass path; recovery is principal-executed.

## Bootstrap order

1. Principal generates age keypair: `age-keygen -o team-age.key.txt` (offline, one machine)
2. Principal stores the *private* key in 1P (`harness-team/age-key`)
3. Principal copies the *public* key into `harness/.sops.yaml` and commits
4. Principal deletes the local `team-age.key.txt`
5. `bootstrap/setup-host.sh` on each workshop verifies the vault is reachable and prints the unlock command

After bootstrap, the public key is on disk (in `.sops.yaml`) and the secret key is only in 1P. Loss of 1P access = loss of operational creds. Recovery: principal generates a new keypair, re-encrypts all sops files (one-time pain).

## Related

- `[[GL-001-commit-autonomy]]` — establishes WHY the team needs credentials in the first place
- `[[SOP-close-session]]` — final step shreds the volatile age key
- Future `[[SOP-rotate-credential]]` — when rotation needs to be standardized
- Future `[[SOP-audit-credentials]]` — SENTRY's recurring audit
