# 5. The autonomy contract

The team's autonomy is **not fixed**. It grows over time as trust grows — but only via a written, explicit agreement between you and the team. That agreement lives at `PKM/autonomy-contract.md`.

## The rule, in one line

**The team proposes; you approve.** Nothing the team takes "on your behalf" exists outside the contract.

## What's in the contract

Three sections:

- **§A Approved baseline** — the standing approvals already in force. Today this reflects what `.claude/settings.json` enforces (read-only inspection, full `git`/`gh` minus destructive ops, harness-only writes, `op read`/`sops -d` for secrets per `[[GL-002-credential-custody]]`, plus the standing denials).
- **§B Proposed** — entries the team has added but you haven't yet approved/struck. Each is scoped, dated, with a one-line rationale.
- **§C Deliberately withheld** — things the team is NOT to do without a future explicit grant (product-repo writes during the freeze; 1P vault-item creation; force-push; raw `curl`/`wget`).

## How the ratchet works

1. The team notices repeated friction (a re-auth prompt, a blocked command it clearly needs for the approved task).
2. The team adds a new entry to §B with **scope** (tool / command / path / secret), **rationale**, and **enforcement surface** (`.claude/settings.json`, auto-mode, sandbox).
3. You read it, mark it `approved` or strike it. Conditions / scope tightening welcome — write them in.
4. Once `approved`, SENTRY checks `.claude/settings.json` matches and surfaces drift if not. RELAY/FORGE adjust the enforcement surface to match.

## What this gives you

- A single page you can read to see *exactly* what the team may do without asking. No surprise.
- A clear paper trail: every grant has a date, a rationale, and a path to revoke.
- Less friction *within* bounds: once a class of action is approved, you stop seeing per-instance prompts for it.
- Hard boundaries stay hard: §C and the standing denials are not subject to drift.

## How to grant or revoke

Open `PKM/autonomy-contract.md`. Find the entry. Change `status: proposed` to `status: approved` (or `denied` or `revoked`). Add a one-line note if you want. Commit. The team picks it up on the next session boot.

You can also just say "approve P2 with these conditions" — the team will make the edit and you'll see it in the next commit.
