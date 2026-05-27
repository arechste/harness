---
hostname: {{hostname}}
os: {{macos|linux|container}}
role: {{workshop-primary|workshop-alternate|fleet|ephemeral}}
inventory_yaml: ../../repos/mac-organizer/inventory/{{hostname}}.yaml
status: {{active|decommissioned}}
---

# {{hostname}}

## Role in the fleet

One paragraph.

## Pending work on this machine

- (link to `state/machines/{{hostname}}.md` entries, if any)

## Cutover history

- {{YYYY-MM-DD}} — initial cutover to slim regime ([[SOP-cutover-machine]])
