---
id: investigate-terminal-output-drift
status: open
priority: P1
required-expertise: [fleet, devops, adapters]
assignee: unassigned
filed_by: TOWER
filed_at: 2026-05-31T00:00:00Z
blocks: []
links: []
---

# Investigate terminal / Bash-tool output drift (correctness risk)

## Why this is P1

During the 2026-05-31 security-standards session, the Bash tool's **output capture was intermittently unreliable**. This is not cosmetic — it caused a near-miss: TOWER briefly acted on a **false picture of the repo** (a phantom `GL-006..GL-021` guideline skeleton that does not exist, assembled from stale/cached command output) and **two file edits silently shipped incomplete** before careful re-verification caught them. An agent that cannot trust command output cannot safely operate autonomously. Fix or mitigate before the next heavy autonomous session.

## Environment

- Terminal: **Warp.app** (warp.dev), using **panes/splits**.
- Shell: **zsh**; Platform: macOS (darwin 25.5.0).
- Host: the Claude Code CLI Bash tool (captures stdout/stderr of each command).
- Principal is open to **trying a different terminal** (Terminal.app / iTerm2 / Ghostty) to isolate the cause.

## Observed symptoms (evidence)

1. **Empty output** — commands that must print returned `Bash completed with no output` (e.g. `git status --porcelain`, `git log`, `wc -l`), while their side effects clearly succeeded.
2. **Stale / cached output** — a call returned the output of a *previous* command (e.g. an old `git log` HEAD shown after new commits existed).
3. **Spurious / injected content** — temp files read back with lines never written (fabricated "confirmed"-type text), and a `Read` reporting "file has 1 line" for a file just written with many.
4. **Unexpanded shell tokens** — once, `echo "EXIT: $?"` printed the literal `$?` instead of the value, suggesting a shell-mode/quoting anomaly in the captured session.
5. Net effect: the only reliable verification path was `cmd > /tmp/file` followed by the `Read` tool — and even that occasionally glitched.

## Hypotheses to test

- **Warp PTY / block model**: Warp renders command "blocks" and may inject control sequences or use a custom PTY that the harness capture layer mis-parses. Test: run the identical session in a plain terminal (Terminal.app / iTerm2) and see if drift disappears.
- **Warpify / subshell integration**: Warp's shell hooks (subshell detection, "Honor custom prompt", session restoration) may interfere. Test: disable Warpify / custom-prompt honoring for the Claude pane.
- **zsh init noise on non-interactive shells**: `.zshrc`/`.zprofile` printing to stdout, or `precmd`/`preexec` hooks, polluting captured output. Test: inspect dotfiles for output on non-interactive invocation; run `zsh -f` baseline.
- **Output buffering / fd reuse in the capture wrapper**: stale output suggests a buffer or temp/fd not flushed/reset between commands. Test: reproduce with deterministic markers (`echo START-$RANDOM; <cmd>; echo END`).
- **Panes**: whether running Claude Code inside a Warp split vs a full window changes behavior.

## Acceptance criteria

- [ ] Reproduce the drift deterministically (a minimal command sequence that triggers empty/stale output)
- [ ] Identify the layer at fault (Warp vs zsh init vs harness capture)
- [ ] Confirm whether a different terminal (Terminal.app / iTerm2 / Ghostty) eliminates it
- [ ] Recommend a fix or a standing mitigation (terminal/setting change, dotfile fix, or a "verify via temp-file Read" protocol if unavoidable)
- [ ] If unresolved, document the safe-operation workaround in an SOP / guideline so agents always verify mutations

## Notes

- Interim protocol already in use this session: write command output to `/tmp/<name>.txt`, then read it with the `Read` tool; treat any single command's stdout as untrusted until confirmed.
- The prior session log (`2026-05-30-19-00`) also noted "terminal output dropped intermittently twice" — so this is **recurring**, not a one-off.

## Event log

- 2026-05-31 — filed by TOWER after a session where output drift caused a near-miss (phantom skeleton) and two silent edit failures; principal flagged the errors and requested investigation. Tagged P1.
