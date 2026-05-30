# Documents

Markdown stubs that **point at where the real document lives** — never the document itself. Passports, contracts, identity files, certificates, licenses, signed agreements.

A stub records: what the document is, where the original lives (1Password vault item, encrypted backup path, paper safe, …), key dates (issued, expires), and any references that need cross-linking (the org, the project).

## Why stubs not files

- Documents are often sensitive — never paste them into the repo (text or binary).
- 1Password / a real document vault is the source of truth; the stub is the *index entry* the team can find when you say "where's my passport?"
- This keeps `git log` and any future searches free of personally-identifying content.

## Stub shape

```markdown
# <document name>

- **Type:** <passport | contract | certificate | ...>
- **Issued:** YYYY-MM-DD
- **Expires:** YYYY-MM-DD (or "—")
- **Where:** <1Password vault item ref, or "safe — top drawer", or sops path>
- **Related:** [[firstname-lastname]] · [[org-slug]]

Notes (non-sensitive only).
```

Empty for now.
