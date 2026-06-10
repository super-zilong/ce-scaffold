Review the implementation of **$ARGUMENTS** against its spec — the REVIEW phase. Judge ONLY
from the spec files and the actual diff. Run this in a session that did NOT plan or implement
this feature (objectivity holds whichever agent you are).

Read `docs/engineering-rules.md` first. (Pi does not auto-inject files; read it explicitly.)

1. Read `spec/$ARGUMENTS/requirements.md`, `design.md`, `tasks.md`, `report.md`. See the real
   changes with `git diff` (or `git status`; if no git, read the files `report.md` lists).
2. Check objectively:
   - Is EVERY item in `tasks.md` actually done — not just checked off?
   - Does it satisfy every acceptance criterion in `requirements.md`?
   - Does it honor every edge case in `design.md`? Violate any `[all]`/`[impl]`/`[review]` rule?
   - Did the tests run and pass per `report.md`? Re-run them if cheap.
3. Decide the verdict — **PASS** or **FAIL**:
   - **PASS** — the implementation satisfies the spec.
   - **FAIL** — the implementation does not satisfy the spec. Back to the work phase.
   Write the verdict + concrete findings (`file:line`) to `spec/$ARGUMENTS/review.md`. You judge the
   implementation against the spec — never edit `requirements.md`/`design.md`. If you suspect a
   requirement itself is the problem, note it as ADVISORY in your findings and suggest the user
   consider `/ce-plan $ARGUMENTS --revise "<change>"` — but that's the user's call; the verdict stays
   FAIL until the spec or code changes. Do not set any "replan" state.
4. Update `status.json` phase -> `"passed"` or `"failed"`.

Then, by verdict:
- **PASS** -> run `/ce-compound $ARGUMENTS` in THIS session (its input is the review you just wrote).
- **FAIL** -> print the fix list; re-run the work phase, then `/ce-review` again. Do NOT compound a FAIL.
