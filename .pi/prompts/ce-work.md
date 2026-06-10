Implement the planned feature **$ARGUMENTS** — the WORK phase of the compound-engineering loop.

You are Pi, the implementation agent. Your standing brief is AGENTS.md (already loaded).

First, read `docs/engineering-rules.md` and obey every rule tagged `[all]` and `[impl]`.
(Pi does not auto-inject files, so read it explicitly before you start.)

1. Read `spec/$ARGUMENTS/tasks.md` and `spec/$ARGUMENTS/design.md`.
2. Implement every task. Check items off in `tasks.md` (`- [ ]` -> `- [x]`) — but only once a
   test or the diff actually proves it; "checked off" must mean "verified".
3. Run the FULL test suite. If red, fix before continuing.
4. Write `spec/$ARGUMENTS/report.md`: **Changes** (files + why), **Tests** (paste output),
   **Risks** (anything skipped / faked / uncertain).
5. Set `spec/$ARGUMENTS/status.json` phase to `"review"`.
6. Do NOT edit `requirements.md` or `design.md`. If they are wrong, note it in `report.md`.

Then stop and tell the user to run `/ce-review $ARGUMENTS` in Claude Code (a fresh session).
