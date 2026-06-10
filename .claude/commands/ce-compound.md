---
description: CE · COMPOUND — distill a reusable rule from a passed review into the shared rules. Run in the review session.
argument-hint: <feature-id (NNN-slug)>
allowed-tools: Read, Edit, Task
---

You are in the **COMPOUND** phase. Run this right after a PASS, ideally in the **same session**
as `/ce-review` (its output is your input). If you are in a fresh session, read
`spec/$ARGUMENTS/review.md` first to reload context.

Feature: **$ARGUMENTS**

Pre-check: only compound when `spec/$ARGUMENTS/status.json` phase is `"passed"`. If it is
`"failed"`, STOP — there is no settled lesson yet (the real fix isn't known).

1. Ask: *"What GENERAL, reusable rule would have prevented the issues found this round, or made
   it go smoother?"* Generalize **beyond** this one feature.
2. Append the lesson(s) to `docs/engineering-rules.md` under `## Rules` — one line each, tagged
   by target role (`[all]`/`[plan]`/`[impl]`/`[review]`), with a trailing
   `<!-- compound: $ARGUMENTS -->` marker. **Skip** anything that merely duplicates an existing rule.
3. If the rules file now looks noisy, or you see duplicates/contradictions, delegate cleanup to
   the **rules-curator** subagent via the Task tool — do NOT prune inline.
4. Print which rule(s) you added, or "no new rule — already covered".
