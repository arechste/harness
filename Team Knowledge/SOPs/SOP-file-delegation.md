# SOP-file-delegation — Create a delegated work item (GH issue + local mirror)

**Owner:** typically CASCADE. **Triggers:** the harness needs work done in one of the 5 product repos, or in a repo it doesn't own directly.

## Purpose

File a GitHub issue in the target repo AND mirror it under `state/delegations/open/<repo>-<N>.md`. The local mirror is the SSOT; the GH issue is the human/external surface.

## When to call

- An SOP produces a change spec for a product repo (dotfiles, dotclaude, …)
- A bug needs fixing in a downstream repo
- An audit finding needs assigning to a repo owner

## Inputs

- Target repo (one of: aitools-common, dotclaude, dotfiles, git-organizer, mac-organizer/fleet-organizer)
- Title, body, labels, milestone
- Acceptance criteria
- `[[Templates/delegation.template.md]]`

## Steps

1. Copy the delegation template to `state/delegations/open/<repo>-pending.md` (`<N>` not known until GH issue is filed).
2. Fill in: title, body (acceptance criteria, links, context), labels, expected assignee.
3. File the GH issue: `gh -R <owner>/<repo> issue create --title ... --body-file <mirror>`. Capture the returned issue number `<N>`.
4. Rename the mirror: `git mv state/delegations/open/<repo>-pending.md state/delegations/open/<repo>-<N>.md`.
5. Set frontmatter `gh_issue: https://github.com/<owner>/<repo>/issues/<N>`, `status: open`, `filed_at: <ISO ts>`.
6. Commit: `chore(delegation): file <repo>#<N> — <short title>`.

## Worked example

TBD (Phase 2).

## Common mistakes

- Filing the GH issue first and forgetting the mirror — breaks SSOT (R0-Q10 forge-as-mirror).
- Using `gh issue create` with inline `--body "$(cat ...)"` — use `--body-file <path>` per cross-repo conventions.
