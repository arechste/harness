# 3. The Inbox

You don't need to know where anything belongs. Drop it in `Team Inbox/` and say "process the inbox" — the team files it.

## How to feed work

Three channels, from "I haven't thought about it" to "I know exactly what I want":

| You have… | Drop it in | What happens |
|---|---|---|
| Something raw and unfiled (screenshot, voice memo, link, brain-dump, business card, half-formed thought) | `Team Inbox/` | TOWER triages → VAULT files into PKM / Team Knowledge / Deliverables / state. Cross-links added. Original removed. See `[[SOP-process-inbox]]`. |
| A *task* you want done | `Team Knowledge/tasks/open/<slug>.md` (or just tell TOWER) | TOWER routes to the right callsign per `[[SOP-route-task]]`. |
| A *deliverable* you've drafted you want the team to react to | `Deliverables/YYYY-MM-DD-<slug>.md` | The team reviews and works against it. |

## What does NOT go in the Inbox

- Anything sensitive (credentials, PII, secrets). The Inbox is committed to git; secrets go through 1Password per `[[GL-002-credential-custody]]`. If you drop something sensitive by mistake, the team will STOP and escalate — they will not commit it.
- Tasks (use `tasks/open/`).
- Things you already know belong in PKM (write directly).

## How filing decides destinations

TOWER + VAULT classify by picking the **narrowest fit**:

- A new topic, habit, goal, project, or key element → `PKM/My Life/<concept>/`
- A new person or organization → `PKM/CRM/People|Organizations/`
- A document reference (passport, contract — stub only) → `PKM/Documents/`
- An image → `PKM/Images/YYYY/MM/`
- A daily reflection → `PKM/Journal/YYYY/MM/YYYY-MM-DD.md` (append)
- An article/link to research → a task for RECON
- An idea for a feature/change → a task with the right expertise tag
- Operational state (machine note, delegation) → `state/`

You can see this in `Team Knowledge/SOPs/SOP-process-inbox.md` if you want the gory detail.
