---
session: 2026-05-31-14-13
host: fragtnix
callsigns: [TOWER, CASCADE]
topic: credential-expiry-cron
---

# Session log — wire credential-expiry to weekly cron

## Worked on

- **Wired `ci/scripts/check-credential-expiry.sh` to weekly cron** via new `.github/workflows/credential-expiry.yml` (Mon 08:00 UTC + `workflow_dispatch`, `ubuntu-latest`, pinned `yq v4.44.3`, non-strict). Updated `ci/README.md` Workflows table and the `security-standards-track` in-flight notes. Commit `78a76c7`.
- **Verified end-to-end**: manual `workflow_dispatch` run [#26711658384](https://github.com/arechste/harness/actions/runs/26711658384) went green — yq installed, script printed `all tracked credentials outside the 14d window`.
- **Filed `checkout-node24-bump`** (`tasks/open/`, P3, `required-expertise: gitops`) — the verification run surfaced GitHub's Node-20 deprecation, fleet-wide. Commit `20898e4`.

## Decisions

- **GH Actions, not launchd/system cron** — the script depends on GNU `date -d`, absent on macOS BSD `date`; must run on Linux. Also matches the harness's established `doc-freshness.yml` pattern.
- **`yq` installed inline, pinned to v4.44.3** — ubuntu-latest doesn't ship yq (script exits 2 without it); reused the exact pin dotfiles' `machine-table-cron.yml` runs in production. Pin over `latest` per the supply-chain posture.
- **Non-strict / logs-only** — current inventory has zero timed credentials (all `n/a`/`never`), so strict mode would add no value; stays green like the other weekly checks. Issue-creating alerts + `--strict` deferred to when the PAT inventory is populated.
- **Checkout bump → separate P3 task, not fixed inline** — it's a fleet-wide change (all 5 workflows pin `checkout@v4`; `diagram-parse.yml` also `setup-node@v4`), out of scope for the cron wiring.

## Insights

- **ubuntu-latest has no `yq`** — any harness CI script using `yq` must install it; the canonical pinned-install snippet lives in dotfiles `machine-table-cron.yml`.
- **Node-20 actions deadline**: GitHub forces Node 24 on **2026-06-16**, removes Node 20 **2026-09-16**. All harness workflows currently pin `actions/checkout@v4` (Node 20). Tracked in `checkout-node24-bump`.
- `/usr/local/bin` is runner-writable on ubuntu-latest — no `sudo` needed for the yq install.

## Open threads

- `checkout-node24-bump` (`tasks/open/`) — bump first-party `actions/*` to v5 before 2026-06-16.
- `security-standards-track` (`tasks/open/`) stays open — the cron half of acceptance-criterion #3 is done; **PAT inventory still blocked** on `[[project_browser-profiles-prereq]]`. (The 7 standards decisions were resolved + authored in parallel this day — see that task's event log, commits `76687e9`..`93b7674`.)

## Next likely move

Pick up `checkout-node24-bump` (quick, mechanical) or resume `security-standards-track`'s remaining open items (supply-chain CI wiring, SOP-close-session cross-consistency gate) once browser profiles unblock the PAT walk.

## Wikilinks

- Predecessor thread: `[[2026-05-30-19-00_guidelines-audit-security-track]]` (filed the cron wiring as a resume option)
- `[[SOP-close-session]]`, `[[GL-001-commit-autonomy]]`
- Task: `security-standards-track`, `checkout-node24-bump`
