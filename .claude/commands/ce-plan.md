---
description: CE · PLAN a feature into a spec (requirements/design/tasks). Claude Code, own session.
argument-hint: <feature-name> [short description of the request]
allowed-tools: Read, Write, Edit, Bash
---

You are in the **PLAN** phase of the compound-engineering loop. Do **NOT** write
implementation code — that is the work phase (`/ce-work`, in either agent). Your output is a
spec that a reviewer with no memory of this session can judge against.

Request: **$ARGUMENTS**

> **Two modes.** If `$ARGUMENTS` is a fresh request, create a new spec (steps below). If it names
> an **existing feature id** plus `--revise "<change>"`, jump to **Revision mode** at the bottom
> instead of creating a new folder. Revision is always **user-initiated** — you decide to change a
> requirement (possibly prompted by a review's advisory note, but the call is yours).

Steps (new feature):

1. Read the shared rules: @docs/engineering-rules.md . Obey every `[all]` and `[plan]` rule.
2. Choose the next spec id: look at existing folders under `spec/` (ignore `_template`),
   take the highest `NNN` and increment; start at `001` if none. Slugify the feature name.
3. Create `spec/NNN-<feature-slug>/` and write three files (use `spec/_template/` as the shape):
   - `requirements.md` — problem/why + **testable** acceptance criteria + out-of-scope.
   - `design.md` — the approach + changed files + a **required** "Error & edge-case paths"
     section (a `[plan]` rule; omitting it makes review FAIL).
   - `tasks.md` — an ordered checklist of small, independently verifiable `- [ ]` tasks.
4. Write `status.json`: `{"feature":"NNN-...","phase":"planned","updated":"<UTC ISO now>","notes":""}`.
5. Print the created path and a one-paragraph summary, then STOP.

Hand-off: the work phase reads `tasks.md` + `design.md` and implements. Make the spec tight
and unambiguous — ambiguity here becomes wasted implementation rounds later.

## Revision mode  (`/ce-plan <feature-id> --revise "<change>"`)

Amend an existing contract in place — you do NOT create a new feature folder. Revision is always
**user-initiated**: the user decided to change a requirement. May be invoked from **any** phase,
including `passed`. (A review can only *advise* that a requirement looks wrong; it never triggers
this — the user does, possibly after reading that advisory.)

1. Take the change and its motivation from the `--revise` argument / the user. Read the current
   `requirements.md` / `design.md` / `tasks.md` (and any `review.md` advisory the user is acting on).
2. Amend `requirements.md` and/or `design.md` to make the change. Keep it minimal and targeted;
   don't silently rewrite unrelated parts.
3. Update `tasks.md` if the change adds, removes, or invalidates work (un-check tasks that must be
   redone). Any existing `report.md` / `review.md` is now **stale** — leave it for history, but the
   feature must go back through work + review.
4. **APPEND** an entry to `spec/<feature-id>/decisions.md` (create from `spec/_template/decisions.md`
   if missing): the date, what changed, and the reason (cite a review advisory if that prompted it).
   Never overwrite past entries.
5. Bump `spec_version` in `status.json` (start at 1 if absent) and set phase back to `"planned"`.
6. Print a one-paragraph diff summary of what changed and why, then STOP. The loop resumes at the
   work phase against the revised spec.
