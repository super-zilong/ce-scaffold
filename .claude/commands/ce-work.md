---
description: CE · WORK — implement a planned feature from its spec. Runs in either agent (Claude or Pi).
argument-hint: <feature-id (NNN-slug)>
allowed-tools: Read, Write, Edit, Bash
---

You are in the **WORK** (implementation) phase.

> Either agent can run the work phase — the user picks. Running it here keeps everything in
> Claude Code; running `/ce-work` in Pi (from `.pi/prompts/`) offloads implementation. Both
> write the identical files, so the rest of the loop doesn't care which one ran.

Feature: **$ARGUMENTS**

1. Read `spec/$ARGUMENTS/tasks.md`, `spec/$ARGUMENTS/design.md`, and @docs/engineering-rules.md .
   Obey every `[all]` and `[impl]` rule.
2. Implement every task. Check items off in `tasks.md` (`- [ ]` -> `- [x]`) — but only once a
   test or the diff actually proves it (a `[review]` rule); "checked off" must mean "verified".
3. Run the full test suite. If red, fix before continuing.
4. Write `spec/$ARGUMENTS/report.md`: **Changes** (files + why), **Tests** (paste output),
   **Risks** (anything skipped / faked / uncertain).
5. Set `spec/$ARGUMENTS/status.json` phase -> `"review"`.
6. Do NOT edit `requirements.md` or `design.md`. If they are wrong, note it in `report.md`.

Then STOP and tell the user to run `/ce-review $ARGUMENTS` in a **fresh** session (objectivity).
