---
description: CE · REVIEW an implementation against its spec. Claude Code, own/fresh session.
argument-hint: <feature-id (NNN-slug)>
allowed-tools: Read, Write, Edit, Bash
---

You are in the **REVIEW** phase. You did NOT plan or implement this feature in the current
session — judge **only** from the spec files and the actual diff. Be the objective reviewer
who didn't write the code.

Feature: **$ARGUMENTS**

1. Read the contract and the work:
   - @docs/engineering-rules.md
   - `spec/$ARGUMENTS/requirements.md`, `design.md`, `tasks.md`, `report.md`
   - The actual changes: run `!git diff` — if this repo isn't a git repo or nothing is
     committed, run `!git status` and otherwise read each file that `report.md` lists.
2. Check, objectively:
   - Is **every** item in `tasks.md` actually done — not just checked off (a `[review]` rule)?
   - Does it satisfy every acceptance criterion in `requirements.md`?
   - Does it honor every edge case in `design.md`? Violate any `[all]`/`[impl]`/`[review]` rule?
   - Did the tests run and pass per `report.md`? Re-run them if cheap.
3. Decide the verdict — **PASS** or **FAIL**:
   - **PASS** — the implementation satisfies the spec.
   - **FAIL** — the implementation does not satisfy the spec. Back to the work phase.
   Write the verdict + concrete findings (`file:line`) to `spec/$ARGUMENTS/review.md`. You judge the
   **implementation against the spec** — you do NOT judge whether the spec is right, and you never
   edit `requirements.md` / `design.md`. If you *suspect* a requirement itself is the real problem
   (contradictory, infeasible, wrong), add an **advisory** note to your findings suggesting the user
   consider `/ce-plan $ARGUMENTS --revise "<change>"` — but that is the user's call, not yours, and
   the verdict stays FAIL until the spec or the code changes. Do not set any "replan" state.
4. Update `status.json` phase -> `"passed"` or `"failed"`, refresh `updated`.

Then, by verdict:
- **PASS** -> immediately run `/ce-compound $ARGUMENTS` in **this same session** (its input is the
  review you just produced).
- **FAIL** -> print the fix list; re-run the work phase on the same feature, then `/ce-review` again.
  Do NOT compound from a failing round.
