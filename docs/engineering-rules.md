# Engineering Rules (shared)

> Single source of truth for **how we build here**. BOTH agents read this file:
> - **Claude Code** via `CLAUDE.md`
> - **Pi** via `AGENTS.md`
>
> The `compound` step appends a generalized lesson here after every PASS, so each
> round makes the next one easier. Keep every rule **one line, generalized, actionable**,
> and tagged by the role it targets: `[all]` `[plan]` `[impl]` `[review]`.

## Conventions

- State is passed between agents through **files in `spec/<feature>/`**, never chat memory.
- A reviewer with **no memory** of the planning session must be able to judge the work from the spec + diff alone. If they can't, the spec was too thin.

## Rules

<!-- compound appends below. One line each. Generalized. Role-tagged. -->

- [all] Prefer the simplest design that satisfies the spec; do not add unrequested abstraction.
- [plan] Every `design.md` MUST enumerate error / edge-case paths, or review will FAIL.
- [plan] Acceptance criteria in `requirements.md` must be observable and testable, not vague.
- [plan] Record every post-plan change to the contract in `spec/<feature>/decisions.md` with its reason; contract changes are user-initiated (self-authorized), never made by review or the work phase.
- [impl] Run the full test suite before marking a task complete; paste the result into `report.md`.
- [impl] Validate all external / user inputs before use.
- [impl] In `report.md`, list every file changed and call out anything skipped or uncertain.
- [impl] For every edge case listed in `design.md`, add a test that exercises it before checking the task off — green happy-path tests do not prove spec compliance.
- [impl] A tool/shell error is not proof a step is impossible — try a platform-native invocation (e.g. `python -m unittest` directly) before recording a task as blocked or unverifiable.
- [review] A change PASSES only if every item in `tasks.md` is done and no existing test breaks.
- [review] Treat a checked-off task as unverified until the diff or a test proves it; "checked off" is a claim, not evidence.
- [review] Review judges the implementation against the spec (PASS/FAIL) and never edits `requirements.md`/`design.md`. If you suspect the spec itself is wrong, note it as an *advisory* in `review.md`; replan is user-initiated via `/ce-plan --revise`, never a review verdict.


## Retired rules

<!-- The rules-curator subagent moves obsolete/duplicate/superseded rules here
     instead of deleting them, so we keep an audit trail. -->
