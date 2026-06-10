Plan the feature **$ARGUMENTS** into a spec — the PLAN phase of the compound-engineering loop.
Do NOT write implementation code; your output is a spec a fresh reviewer can judge against.

Read `docs/engineering-rules.md` first and obey every `[all]` and `[plan]` rule.
(Pi does not auto-inject files; read it explicitly.)

> **Two modes.** Fresh request -> create a new spec (steps below). If `$ARGUMENTS` names an
> existing feature id plus `--revise "<change>"`, jump to **Revision mode** at the bottom. Revision
> is always **user-initiated** — you decide to change a requirement (a review may suggest one looks
> wrong, but it never triggers replan; the user does).

1. Pick the next spec id: highest `NNN` under `spec/` (ignore `_template`) + 1, else `001`.
   Slugify the feature name.
2. Create `spec/NNN-<slug>/` from the shape in `spec/_template/`:
   - `requirements.md` — problem/why + TESTABLE acceptance criteria + out-of-scope.
   - `design.md` — approach + changed files + a REQUIRED "Error & edge-case paths" section
     (omitting it makes review FAIL).
   - `tasks.md` — ordered checklist of small, independently verifiable `- [ ]` tasks; break every
     edge case out as its own task that demands a test.
3. Write `status.json`: `{"feature":"NNN-...","phase":"planned","updated":"<UTC ISO now>","notes":""}`.
4. Print the created path + a one-paragraph summary, then STOP.

Hand-off: the work phase reads `tasks.md` + `design.md`. Keep the spec tight and unambiguous.

## Revision mode  (`/ce-plan <feature-id> --revise "<change>"`)

Amend an existing contract in place — do NOT create a new feature folder. Revision is always
**user-initiated**: the user decided to change a requirement. May be invoked from ANY phase (incl.
`passed`). A review may *advise* that a requirement looks wrong, but it never triggers replan — the user does.

1. Take the change + motivation from the `--revise` argument / the user. Read the current
   requirements/design/tasks (and any `review.md` advisory the user is acting on).
2. Amend `requirements.md` and/or `design.md`; keep it minimal and targeted.
3. Update `tasks.md` if work changed (un-check tasks that must be redone). Any existing
   `report.md`/`review.md` is now STALE — leave it for history; the feature re-runs work + review.
4. APPEND an entry to `spec/<feature-id>/decisions.md` (create from `spec/_template/decisions.md` if
   missing): date, what changed, reason (cite a review advisory if that prompted it). Never overwrite past entries.
5. Bump `spec_version` in `status.json` (start at 1 if absent); set phase back to `"planned"`.
6. Print a one-paragraph diff summary, then STOP. The loop resumes at the work phase.
