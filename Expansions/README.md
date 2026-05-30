---
form: explanation
last-verified: 2026-05-30
owner: SCOUT (install/uninstall); SENTRY (security review)
status: authoritative
---

# Expansions

This folder holds **optional add-ons** for the harness scaffold. Each Expansion is a folder. Drop it in, and SCOUT walks you through the install on the next session — confirms the manifest, hands it to SENTRY for the security review, merges the new agents/SOPs/Guidelines/Templates into the active scaffold, wires any connectors, and validates the result. Uninstall whenever — SCOUT runs the symmetric flow and your harness returns to its prior shape.

> **The scaffold runs without anything here.** Expansions are how the team **grows beyond the 10 pre-hired callsigns** — new agents, new domains (tailscale, homelab, browser, …), new connectors, new runtimes — never capability the scaffold lacks.

## How it works

```
Drop folder under Expansions/
    ↓
SCOUT reads expansion.yaml manifest
    ↓
SENTRY runs the security review (declared env_vars, mcp_servers, hooks)
    ↓
Principal approves (per [[autonomy-contract]])
    ↓
SCOUT merges agents → Team/, SOPs → Team Knowledge/SOPs/, Guidelines → Team Knowledge/Guidelines/, Templates → Team Knowledge/Templates/
    ↓
RELAY wires any tool-specific shims (adapters/<tool>/) the Expansion declares
    ↓
SCOUT validates: agent-index updated, INDEX entries added, smoke-tested
    ↓
Status added to Expansions/INDEX.md
```

Uninstall: symmetric reverse — connectors unwired, files reverted, INDEX entry removed. Reversible because every install commits granularly per `[[GL-001-commit-autonomy]]`.

## What lives here

- `Expansions/INDEX.md` — the list of currently-installed Expansions (regenerated each session by TOWER's librarian-pass)
- `Expansions/<name>/` — one folder per Expansion
- `Expansions/docs/expansion-spec.md` — the spec for what an Expansion folder must contain (manifest schema, file layout, conventions)

## Future domains shipped as Expansions

Per the operating-model proposal, new domains land as Expansions, **not** core callsigns:

- `Expansions/tailscale/` — Tailscale network management
- `Expansions/homelab/` — homelab infrastructure
- `Expansions/browser/` — browser-automation
- Any future vendor adapter (a new forge type, a new SaaS integration, …)

See `[[ADR-0001-doc-system]]` for the framework choices each Expansion's docs follow.

---

## Trust model

**Expansions are code you choose to run.** When you drop one in, you are choosing to run software written by its author with access to your harness. Read the Expansion's `LICENSE`, `README.md`, and the `expansion.yaml` `env_vars:` and `mcp_servers:` declarations before SCOUT files the install task. **SENTRY reviews; the principal grants.** No third-party Expansion runs without your explicit per-install nod, recorded in `[[autonomy-contract]]`.

Official Expansions (if/when harness publishes any) ship from a trusted source and are hash-pinned; treat them per the same review flow.
