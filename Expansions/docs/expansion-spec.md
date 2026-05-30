---
form: reference
last-verified: 2026-05-30
owner: SCOUT (install authority); LATTICE (manifest schema)
status: authoritative
---

# Expansion Spec

What an Expansion folder must contain. Authors target this spec; SCOUT validates against it on install.

## Folder layout

```
Expansions/<name>/
├── expansion.yaml          (required) manifest
├── README.md               (required) what it is, why, how to use post-install
├── LICENSE                 (required) the Expansion's license
├── agents/                 (optional) new callsign contracts to merge into Team/
│   └── <CALLSIGN> - <Role>/AGENTS.md
├── SOPs/                   (optional) new SOPs to merge into Team Knowledge/SOPs/
│   └── SOP-<verb>-<noun>.md
├── Guidelines/             (optional) new Guidelines to merge into Team Knowledge/Guidelines/
│   └── GL-NNN-<topic>.md   (NNN is a placeholder; LATTICE assigns at install time)
├── Templates/              (optional) entity templates → Team Knowledge/Templates/
│   └── <entity>.template.md
├── Workstreams/            (optional) multi-domain flows → Team Knowledge/Workstreams/
│   └── WS-NNN-<topic>.md   (NNN assigned at install time)
├── adapters/               (optional) tool-specific shims RELAY wires up
│   └── <tool>/...
├── docs/                   (optional) Expansion-specific docs not graduated to SSOT
├── hooks/                  (optional) hook scripts (declared in manifest)
├── connectors/             (optional) MCP servers, forge integrations, etc.
└── tests/                  (optional) smoke tests SCOUT runs post-install
```

Only `expansion.yaml`, `README.md`, and `LICENSE` are required. Everything else is opt-in.

## Manifest (`expansion.yaml`)

```yaml
# expansion.yaml — schema version 1
name: <kebab-case>                  # required; matches folder name
version: 0.y.z                      # required; SemVer per [[GL-004-release-versioning]]
description: <one-line>             # required
author: <name or org>               # required
license: <SPDX identifier>          # required (e.g., MIT, Apache-2.0, CC-BY-SA-4.0)
homepage: <URL>                     # optional
source: <git URL>                   # optional (where it came from)
sha256: <hash>                      # optional but recommended; SCOUT verifies on install

# Declared scope — SENTRY reviews these before install
declares:
  env_vars:                          # env vars the Expansion reads or writes
    - name: TAILSCALE_API_KEY
      purpose: read
      required: true
  mcp_servers:                       # MCP servers the Expansion configures
    - name: tailscale-mcp
      scope: project                 # never global per [[GL-003-doc-authoring]] (MCP scoping)
      transport: stdio
  hooks:                             # hook scripts that run on Claude Code events
    - event: PreToolUse
      command: hooks/tailscale-guard.sh
  network:                           # external endpoints the Expansion contacts
    - api.tailscale.com:443
  filesystem:                        # paths it writes outside its own folder
    - state/inventory/tailscale-*.md
  secrets:                           # references it makes into the 1P vault per GL-002
    - op://harness-team/tailscale-api-key

# Compatibility
requires:
  harness: ">=0.5.0"                  # minimum harness version
  callsigns:                          # callsigns it expects to exist
    - SENTRY
    - FORGE

# What it installs (SCOUT reads this to plan the merge)
provides:
  agents:
    - PATROL - Network Engineer        # new callsign
  sops:
    - SOP-tailscale-acl-rotate
  guidelines:
    - GL-network-acl-discipline       # NNN assigned by LATTICE at install
  templates:
    - tailscale-node.template
```

## Conventions

- **Naming:** the Expansion folder name matches `name:` in the manifest, kebab-case, ASCII only.
- **Versioning:** SemVer 2.0.0 per `[[GL-004-release-versioning]]`. Floor `0.y.z` until the Expansion's public interface is stable.
- **Doc forms:** every Expansion-provided SOP/Guideline/Workstream/Reference declares `form:` per `[[GL-003-doc-authoring]]`.
- **Diagrams:** Mermaid + ASCII (same as core harness).
- **CHANGELOG:** Expansions ship a `CHANGELOG.md` in Keep-a-Changelog 1.1.0 format.
- **License:** **required**. Without a license, SCOUT refuses to install (legal ambiguity = stop).

## Install (high-level flow — full procedure in `[[SOP-install-expansion]]`)

1. SCOUT validates the manifest against this spec.
2. SENTRY reviews the `declares:` block: env vars, MCP servers, hooks, network endpoints, filesystem writes, secret references. Surfaces concerns to the principal.
3. Principal approves (logged in `[[autonomy-contract]]` with `expansion-install:<name>:<version>` as a scoped grant).
4. SCOUT merges:
   - `agents/` → `Team/`
   - `SOPs/` → `Team Knowledge/SOPs/`
   - `Guidelines/` → `Team Knowledge/Guidelines/` (LATTICE assigns NNN)
   - `Templates/` → `Team Knowledge/Templates/`
   - `Workstreams/` → `Team Knowledge/Workstreams/`
5. RELAY wires `adapters/<tool>/` shims for the new callsigns/SOPs.
6. FORGE installs declared hooks under `adapters/claude/hooks/` (if declared).
7. SCOUT runs `tests/` smoke tests.
8. TOWER updates `agent-index.md` + relevant INDEX files.
9. Status added to `Expansions/INDEX.md`.

Uninstall reverses each step in reverse order; one commit per step (per `[[GL-001-commit-autonomy]]`).

## Validation

LATTICE provides a JSON Schema at `ci/schemas/expansion.schema.json` (Phase 2). CI validates each Expansion's `expansion.yaml` against it.

## Out of scope for v1

- Auto-discovery of remote Expansion registries — install is always "you drop the folder in." A future Expansion-Library SOP can automate fetch + verify.
- Sandboxed execution of Expansion code — SENTRY's review is the gate, not a runtime sandbox.
- Multi-machine sync of installed Expansions — harness is single-machine by design; if needed, the install is re-run on each workshop.
