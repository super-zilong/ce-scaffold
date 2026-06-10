# Pi — Compound Engineering agent

This repo uses a **multi-agent compound-engineering** workflow with four phases:
**plan → work → review → compound**. Either agent — Claude Code or Pi — can run **any**
phase; you and Claude Code share the same command names and the same file contract. The
user decides which agent runs which phase.

Your role is **whatever phase command you are invoked with** — not a fixed job. Each command
tells you exactly what to read and write; follow it.

## Read this first — shared rules

Read `docs/engineering-rules.md` and obey every rule that applies to the phase you're running.
(Pi does not auto-inject files, so read it explicitly at the start of each phase.)

## The four phases  (Pi prompt templates live in `.pi/prompts/`)

- `/ce-plan <feature> <request>` — write the spec (`requirements/design/tasks.md`). No code.
- `/ce-work <feature>` — implement from the spec; write `report.md`.
- `/ce-review <feature>` — judge the implementation against the spec; write `review.md`.
- `/ce-compound <feature>` — on PASS, distill a reusable rule into `docs/engineering-rules.md`.

## Handoff contract (the message bus)

```
spec/<NNN-feature>/
  requirements.md  what & why            (plan writes)
  design.md        how + edge cases      (plan writes)
  tasks.md         checklist             (plan writes; work checks off)
  report.md        what work did         (work writes)
  review.md        PASS/FAIL + advisories (review writes)
  decisions.md     contract change log   (plan appends in --revise mode)
  status.json      state machine         (current-phase owner updates)
```

`status.json` phases: `planned -> implementing -> review -> passed | failed`
- **failed** -> back to work (the implementation doesn't satisfy the spec).
- **`/ce-plan --revise`** is user-invokable at **any** time when you decide to change a requirement;
  it amends the contract, resets to `planned`, and supersedes any prior `report.md`/`review.md`.
  Review never changes requirements — it may only *advise*; replan is the user's call.

## Invariants (whatever phase you run, whichever agent you are)

- State passes through **files in `spec/<feature>/`**, never chat memory.
- **Review** must run in a session that did NOT plan or implement the feature — objectivity.
- **Compound** only fires after a PASS, and writes **generalized** rules both agents will read.
- During **work**, do not edit `requirements.md` / `design.md` (the contract); if they're wrong,
  note it in `report.md`. Only `/ce-plan` writes those.
- Review never changes the spec. Its verdict is only PASS/FAIL. If you suspect a requirement is
  wrong, leave an **advisory** note in `review.md`; the **user** decides whether to run
  `/ce-plan --revise`. Replan is always user-initiated.
