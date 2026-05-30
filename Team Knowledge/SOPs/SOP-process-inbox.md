# SOP-process-inbox — File raw principal intake from `Team Inbox/`

**Owner:** TOWER (triage + librarian-pass capture & filing — VAULT folded in 2026-05-30). **Triggers:** principal says "process the inbox" or files appear in `Team Inbox/`.

## Purpose

Sweep `Team Inbox/`, route each item to its right home (PKM / Team Knowledge / Deliverables / state / a new task), add cross-links, and remove the original. The principal should never need to file their own inputs.

## When to call

- Principal explicitly asks ("process the inbox", "TOWER, here's something new")
- Session boot finds files in `Team Inbox/` other than `README.md`
- After a working block — a quick sweep to clear scratch

## Inputs

- The dropped file(s) (any extension: `.md`, `.png`, `.pdf`, `.txt`, `.eml`, voice memo, …)
- The principal's most recent message context (often clarifies intent)
- `[[agent-index]]` (for routing) and `PKM/INDEX.md`, `Team Knowledge/INDEX.md` (for destinations)

## Steps

1. **Sweep.** TOWER lists `Team Inbox/` (excluding `README.md`). For each file, read it (or read its filename + extension if binary).
2. **Classify.** For each item, decide destination — pick the *narrowest* fit:
   - Life concept (Topic / Habit / Goal / Project / Key Element) → `PKM/My Life/<concept>/<slug>.md`
   - Person or org → `PKM/CRM/People|Organizations/<slug>.md`
   - Document reference (passport, contract) → `PKM/Documents/<slug>.md` (stub only — never the doc itself)
   - Image → `PKM/Images/YYYY/MM/<descriptive-name>.<ext>`
   - Daily reflection / brain-dump → `PKM/Journal/YYYY/MM/YYYY-MM-DD.md` (append, don't replace)
   - Article / link the team should research → file a task: `Team Knowledge/tasks/open/<slug>.md` with `required-expertise: research`
   - Idea for a feature / change to harness or a repo → file a task with the right expertise tag
   - Operational state (machine note, delegation update) → `state/<area>/...`
   - Sensitive (credential, PII) → STOP, escalate via `[[SOP-escalate-blocked]]` — never paste into the repo
3. **Route.** If the item needs work (research, hire, audit), TOWER calls `[[SOP-route-task]]` to set `assignee:` on the new task.
4. **Capture.** TOWER (librarian-mode) — or the routed callsign — writes the destination file and adds `[[wikilinks]]` to related concepts already in PKM.
5. **Cross-link.** Add a back-reference from any concept file that now mentions a new entity (a Person mentioned in a Journal entry gets a stub in `CRM/People/`).
6. **Remove the original.** Once filed, `git rm` the original from `Team Inbox/` (the destination is now the SSOT — the inbox is transient).
7. **Report.** TOWER returns a short summary: items in, destinations out, tasks filed, any items escalated.

## Worked example

```
Inbox: brain-dump-end-of-day.md (markdown), screenshot-tailscale-error.png, link-anthropic-folder-trust.md (single URL)

Classify:
- brain-dump-end-of-day.md → splits into:
    - daily Journal entry → PKM/Journal/2026/05/2026-05-30.md (append)
    - one new Topic (Tailscale ACLs) → PKM/My Life/Topics/tailscale-acls.md (stub)
    - one new Person mentioned → PKM/CRM/People/<name>.md (stub)
- screenshot-tailscale-error.png → PKM/Images/2026/05/tailscale-acl-error.png + embedded in Journal entry
- link-anthropic-folder-trust.md → task for RECON: tasks/open/research-folder-trust.md (required-expertise: research)

git rm Team Inbox/{brain-dump-end-of-day.md, screenshot-tailscale-error.png, link-anthropic-folder-trust.md}

Report: 3 items in → 1 journal entry + 2 stubs + 1 image + 1 task; no escalations.
```

## Common mistakes

- **Pasting sensitive content** (a screenshot of a 1P unlock, an email with a token). STOP, do not commit; escalate.
- **Filing without cross-linking.** A new Person stub without back-references defeats the wiki — TOWER's librarian-pass adds the links.
- **Routing the *original* file instead of filing it.** Inbox items are *inputs*; they get filed to their destination and removed. They are not tasks themselves.
- **Skipping the daily Journal append.** End-of-day brain-dumps belong in the Journal; spinning up a Project/Topic for every sentence is over-filing.

## Related

- `[[Team Inbox/README]]` — the principal-facing description of the inbox
- `[[SOP-route-task]]` — for items that become work
- `[[SOP-escalate-blocked]]` — for sensitive items or unclear intent
- `[[GL-002-credential-custody]]` — what to do when credentials show up by mistake
