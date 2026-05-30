# 1. How harness works

Harness is your management brain for your whole IT estate — homedir & environment across machines (dotfiles), the AI runtime (`~/.claude`), the fleet (mac/linux/containers/VMs), git & forges, local repos, and whatever comes next (tailscale, homelab). You bring a goal; the team plans, specs, builds, and ships it across whatever domains it touches.

## What harness is

A **markdown-only orchestrator scaffold** that lives in one git repo on your workshop machine. It holds:

- **The operating model** — identity, roles, decision rules, conventions (`AGENTS.md`, `Team/`, `Team Knowledge/`).
- **The tool-agnostic SSOT** — SOPs (procedures), Guidelines (standing rules), Workstreams (multi-domain flows), Templates.
- **State** — tasks, delegations, inventory, machine baselines.
- **Tool adapters** — `adapters/claude/` is the only tool-specific layer (CLAUDE.md, subagent shims, command shims, hooks). Future: `adapters/cursor/`, `adapters/gemini/`, etc.

The product repos (dotfiles, dotclaude, git-organizer, mac-organizer, aitools-common) **stay around as artifact stores** — they hold what physically ships (chezmoi templates, runtime hooks, per-machine inventory, plugin manifests). They no longer hold *governance*.

## The loop

You bring a goal → the team **discusses, plans, specs** it → you **review/approve** → the team **delivers** → ships to the fleet where needed. Once the team clearly knows what you want, it shifts from "ask at each step" to "implement and report," within the [[05-the-autonomy-contract|autonomy contract]].

## What's authoritative right now

- `AGENTS.md` (root) — the team's identity contract; first read every session.
- `Team/agent-index.md` — the routing table from expertise → callsign.
- `Team Knowledge/SOPs/` and `.../Guidelines/` — the procedures and rules already authored.
- `state/repo-baselines.yaml` — the frozen-as-of SHAs of the five product repos for the duration of Phase 2.
- This Handbook — reflects the current shape; if reality diverges, the Handbook is wrong and should be fixed.

## Where to look first

| You want… | Start here |
|---|---|
| A list of who does what | [[02-the-team]] |
| To drop something for the team to deal with | [[03-the-inbox]] |
| To find a fact, a doc, a rule | [[04-pkm-and-bkm]] |
| To grant me a new permission | [[05-the-autonomy-contract]] |
| To understand a session | [[06-sessions-and-tasks]] |
| To understand where harness came from | `docs/transformation/round-0.md`, `Phase-0-audit.md` |
