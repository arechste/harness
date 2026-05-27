# SOP-close-session — Wrap a session and write a durable log

**Owner:** TOWER (the session's main identity). **Triggers:** principal says "wrap," "close session," "end session," "log this," "we're done," "stop here," or any clear intent to end. Also: TOWER's own judgment when natural stopping points arrive and the principal has stepped away.

## Purpose

Don't let session context evaporate. Convert it into:

- A written log under `Team Knowledge/session-logs/YYYY/MM/YYYY-MM-DD-HH-MM_<topic-slug>.md`
- Updated task states (anything `in-progress/` that isn't actually in progress anymore)
- Surfaced graduation candidates — insights that are now durable enough to become Guidelines or SOPs
- A clean handoff: the next session boots and the picture is coherent

## When to call

- Explicit principal trigger (any of the phrases above; pattern-match intent, not literal strings)
- TOWER detects a natural stop (long pause, principal signals end of working block, before a context-window compaction)
- Before any planned long-running background job that will outlast the current session

## Inputs

- The session itself (conversation context + on-disk state changes)
- `Team Knowledge/tasks/in-progress/` — what's currently owned by callsigns this session has worn
- `Team Knowledge/session-logs/YYYY/MM/` — recent prior logs (for `[[wikilink]]` cross-reference)
- `Principal/Journal/` — for graduation candidates (durable insights move here)

## Steps

1. **Sweep `tasks/in-progress/`.** For each task this session worked on:
   - Truly complete → `[[SOP-close-task]]` (move to `done/<YYYY>/<MM>/`, write outcome)
   - Made progress but not done → append a `session-progress:` event line; leave in `in-progress/`
   - Started but blocked → call `[[SOP-escalate-blocked]]`
   - Not started, not yours anymore → call `[[SOP-handoff-task]]` to TOWER for re-routing

2. **Write the session log.** Create `Team Knowledge/session-logs/$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d-%H-%M)_<topic-slug>.md` (mkdir -p the YYYY/MM if needed). Topic-slug is 2-4 words about the session's main thread. Body:
   - **Worked on:** 1-3 bullets, what changed
   - **Decisions:** bullets, with one-line rationale each
   - **Realignments:** anything where the principal said "actually no, do X instead" — capture original direction + correction + why
   - **Insights:** non-obvious things learned (a quirk, a constraint, a fact worth keeping)
   - **Open threads:** what's still in flight, with task IDs / PR links
   - **Next likely move:** one sentence on where you'd start next session
   - **Wikilinks:** to prior session logs on the same thread, relevant SOPs, the principal's journal entries you created

3. **Librarian pass (VAULT hat).** Quick scan:
   - Any `[[wikilink]]` you used that doesn't resolve to a real file? Note it in `notes` or open a small `Team Knowledge/tasks/open/` task tagged `required-expertise: vault`.
   - Any new file you created without an INDEX entry? Add the entry.
   - Any SSOT drift (same fact written in two places)? Flag for cleanup or fix in place if trivial.

4. **Propose graduations.** Review the "Insights" section against your recent (last ~5) session logs. If something has now appeared 3+ times, or is clearly a permanent rule, propose graduating it:
   - Operational rule → new `GL-NNN-<topic>.md`
   - Repeatable procedure → new `SOP-<verb>-<noun>.md`
   - Principal-facing fact → new `Principal/Reference/<topic>.md` or `Principal/Journal/` entry

   Don't *do* the graduation yet — propose it by filing a task in `tasks/open/` tagged `required-expertise: writer` (QUILL) or `librarian` (VAULT) with `links: [<session-log-path>]`.

5. **Commit and push the session log.** Per `[[GL-001-commit-autonomy]]`, harness permits direct-to-`main` push for session-log commits (the log IS the qualifying meta-change). Stage *only* the artifacts close-session itself produced — the new log file, any `INDEX.md` updates from the librarian pass, any new graduation-task files in `tasks/open/`. Do NOT bundle in unrelated uncommitted state from the session; substantive work belongs in its own commit by the agent that did it.

   ```bash
   HARNESS=~/airepos/common/harness
   LOG="Team Knowledge/session-logs/$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d-%H-%M)_<topic-slug>.md"

   git -C "$HARNESS" add "$LOG"
   # If steps 3-4 updated other files (INDEX, new graduation task), stage them too:
   # git -C "$HARNESS" add "Team Knowledge/INDEX.md" "Team Knowledge/tasks/open/<new-graduation>.md"

   git -C "$HARNESS" commit -F- <<EOF
   chore(session-log): $(date +%Y-%m-%d\ %H:%M) — <topic-slug>

   <optional one-line summary>

   Co-Authored-By: Claude/Opus/harness@$(hostname -s) <noreply@anthropic.com>
   EOF

   git -C "$HARNESS" push
   ```

   Signing is off inside harness (per `harness/.gitconfig`) so this is friction-free. If `git push` fails (network, conflict, branch protection), surface to the principal — do not retry blindly. The log is durable on disk locally; the principal can push later.

6. **Sign off.** End with a one-line acknowledgement to the principal: log path, commit hash, push outcome. Example: *"Session logged at `Team Knowledge/session-logs/2026/05/2026-05-27-09-55_close-session-smoketest.md`, committed as `a1b2c3d`, pushed to main. 0 graduations proposed. Closing."*

## Worked example

TBD — fill in after first real close-session run on fragtnix.

## Common mistakes

- **Writing the log before the sweep.** The sweep often surfaces an item that belongs in the log's "Open threads" — log first, sweep later means you miss it.
- **Auto-graduating mid-session.** Steps 4 *proposes*; the actual graduation is a separate task another agent will pick up. Resist the urge to write the Guideline now.
- **Cross-linking from the log to itself.** Wikilink to *other* logs, SOPs, and journal entries — not to the file you're writing.
- **Skipping when the session was short.** Even a 5-minute session that produced a commit deserves a log entry. Future-you will thank present-you.
- **Bundling unrelated uncommitted changes into the session-log commit.** Step 5 stages only close-session's own artifacts. If `git status` shows other modifications, those belong in a separate commit by whichever agent made them — never silently swept into the session-log commit.
- **Retrying a failed push silently.** If `git push` fails, the principal must know. The log on disk is the durable record; the push is reconcilable later. Don't loop or fall back to `--force`.
