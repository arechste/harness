# Autonomy Contract

**Status:** LIVING — the written agreement of what the harness team (TOWER + callsigns) may do
**on the principal's behalf without per-instance approval.** This file is the *source of truth* for
autonomy. The enforcement surfaces — `.claude/settings.json` (allow/deny), sandbox, auto-mode, and
`[[GL-002-credential-custody]]` — are reconciled to *match* what is `approved` here.

**Owners:** principal (grants/denies/revokes) · TOWER (proposes + maintains) · SENTRY (audits drift
between this contract and the enforcement surfaces).

---

## How it works — the ratchet

- **The team proposes; the principal approves.** An entry is `proposed` until the principal marks it
  `approved` (or `denied` / `revoked`).
- **Nothing here enforces by itself.** Only `approved` entries are reconciled into the enforcement
  surfaces. A `proposed` entry grants nothing.
- When the team hits **repeated friction** or needs a capability for an already-approved task, it adds
  a `proposed` entry *with a rationale* instead of asking ad hoc every time.
- **Least privilege.** Entries are scoped (tool / command-class / path / secret). Narrow beats broad.
- **Revocation is immediate and always allowed.** The principal may strike any entry at any time.
- **Audit.** SENTRY periodically checks that enforcement matches `approved` entries — no drift in
  either direction — and files findings as tasks.

**Entry shape:** `id · scoped grant · status · since · rationale · enforcement surface`

---

## A. Approved baseline (already enforced — reflects `.claude/settings.json` today)

These describe the autonomy *already* in force. Listed here to make the implicit explicit and visible.
Principal: confirm or adjust.

| id | grant (scoped) | status | enforcement |
|---|---|---|---|
| A1 | Read-only inspection: `Read`/`Glob`/`Grep` + read-oriented bash (`cat ls head tail wc stat diff grep rg sed awk find jq yq sort uniq cut tr …`) | approved (existing) | settings.json `allow` |
| A2 | `git *` and `gh *` — full CLI **except** the standing denials in A6 | approved (existing) | settings.json `allow`/`deny` |
| A3 | `Write`/`Edit` **within the harness repo only** (`harness/**`) — product repos under `repos/**` are NOT writable | approved (existing) | settings.json `allow` |
| A4 | Secret access per GL-002: `op read op://harness-team/*`, `sops -d` / `sops --decrypt` | approved (existing) | settings.json `allow` + GL-002 |
| A5 | Subagent dispatch (`Agent`), `Skill`, `WebSearch`, and `WebFetch` to an allowlist of github.com / anthropic doc domains | approved (existing) | settings.json `allow` |
| A6 | **Standing DENY** (cannot be done even though broadly adjacent): `rm -rf`, `rm -r /*`, `git push --force`/`-f`, `git reset --hard`, `gh repo delete`/`archive`, `gh auth login`/`refresh`, `curl`, `wget`, keychain/`op`/ssh/aws/gnupg secret reads, writes to `~/.ssh ~/.aws ~/.gnupg ~/.config/op ~/.config/1Password ~/Library/Keychains` | approved (existing) | settings.json `deny` |

---

## B. Proposed (awaiting your approve / strike)

| id | grant (scoped) | status | rationale | enforcement |
|---|---|---|---|---|
| P1 | **One 1Password unlock per session.** Fetch the team age key once at first need per GL-002 and reuse it until close-session — no per-secret biometric re-prompt. | proposed | Your "no frequent 1P auth prompt" friction. `op read`/`sops -d` are already allowed (A4); the biometric is an OS-layer prompt — this records that **one unlock/session** is the agreed cadence and that I may cache the volatile age key for the session. | GL-002 session lifecycle (age key in `$SOPS_AGE_KEY_FILE`, shredded at close) |
| P2 | **Scoped, non-destructive `sudo` for fleet/host ops.** A *named* list of privileged commands (package install/query, service status) — I return with the exact command list per task before you approve each addition. | proposed | Fleet management needs privilege; today `sudo` isn't granted at all, so every privileged op prompts. Placeholder grant + per-command sign-off keeps it least-privilege. | settings.json `allow` (specific `Bash(sudo <cmd> …)` patterns), once you name them |
| P3 | **Auto-mode for harness-internal work.** Run low-friction (auto-mode) when work is confined to `harness/**`; keep per-instance prompts for anything touching product repos, the fleet, secrets-write, or destructive ops. | proposed | The riskiest writes are already harness-only (A3). This kills routine prompts for the safe inner loop while preserving gates at the real boundaries. | auto-mode + settings.json |

---

## C. Deliberately withheld (not granted by design — needs a future proposal)

- **Writes to product repos** (`repos/**`) — held by the Phase-2 freeze; will be proposed *per repo* at
  Phase-5a behind feature-branch + PR.
- **Creating 1P vault items** — GL-002: only the principal seeds credentials. The team requests a new
  credential via a task.
- **History rewrite / force-push / repo delete/archive** — standing deny (A6); not up for routine grant.
- **Arbitrary network fetch** (`curl`/`wget`) — denied; use `gh api` or the WebFetch allowlist instead.

---

## Related

- `[[GL-001-commit-autonomy]]` — commit/merge model (why the team needs these grants)
- `[[GL-002-credential-custody]]` — the secret-access mechanism P1 rides on
- `.claude/settings.json` — the primary enforcement surface (allow/deny)
- Future `[[SOP-audit-permissions]]` — SENTRY's recurring contract↔enforcement drift check

## Event log

- 2026-05-29 — drafted by TOWER at the principal's request. Baseline (A1–A6) transcribed from
  `.claude/settings.json`; P1–P3 proposed; awaiting principal approve/strike. Nothing new enforced yet.
