# CRM — People & Organizations

Flat concept folders for people and organizations the principal interacts with. Referenced from Journal entries and Project files via `[[wikilinks]]`.

- **People/** — one file per person; kebab-case filename (`firstname-lastname.md`). Includes role, org links, context, last interaction date.
- **Organizations/** — one file per organization; kebab-case filename. Includes type (employer, vendor, community, …), key contacts (links to `People/`), notes.

## Conventions

- One file per entity. Don't fragment by year or context — append to the same file.
- Cross-link generously: a Journal entry mentioning a person should link `[[firstname-lastname]]`; a person file should link to their `Organizations/` if any.
- Privacy: nothing in CRM should be more sensitive than what would go in a phone contact card. Anything more (e.g., NDAs, salary, credentials) belongs in `PKM/Documents/` or the team vault per `[[GL-002-credential-custody]]`.
- Empty for now — the principal seeds; the team adds stubs when names surface during work.
