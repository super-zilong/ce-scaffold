# Compound Engineering workspace

This repo uses a **multi-agent compound-engineering** workflow with four phases:
**plan → work → review → compound**. Both agents — Claude Code (you) and Pi — expose all
four as `/ce-*` commands; the user chooses which agent runs which phase. A common split is
Claude plans/reviews/compounds while Pi implements, but that's a default, not a lock.

State is passed between agents through **files**, not chat memory. Each phase runs in
its **own session** on purpose (see "Why separate sessions" below).

## Read this first — shared rules

@docs/engineering-rules.md

## Your role (Claude Code)

Your role is **whatever phase command you are invoked with** — not a fixed job. Either agent
(Claude Code or Pi) can run any of the four phases; the user picks. The same four `ce-` commands
exist on both sides (Claude: `.claude/commands/`, Pi: `.pi/prompts/`):

1. `/ce-plan <feature> <request>` — turn a request into `spec/<feature>/{requirements,design,tasks}.md`
2. `/ce-work <feature>` — implement from the spec; write `report.md`
3. `/ce-review <feature>` — review the implementation against the spec (in a session that did NOT
   plan or implement it — objectivity)
4. `/ce-compound <feature>` — on PASS, distill the lesson into `docs/engineering-rules.md`
   (run in the review session)

A common split is Claude plans/reviews/compounds while Pi implements — but that's a default,
not a rule. Run whichever phase you're asked to.

## Handoff contract (the message bus)

```
spec/<NNN-feature>/
  requirements.md  what & why            (you write in /ce-plan)
  design.md        how + edge cases      (you write in /ce-plan)
  tasks.md         checklist             (you write in /ce-plan; Pi checks off)
  report.md        what Pi did           (Pi writes during /ce-work)
  review.md        PASS/FAIL + advisories (you write in /ce-review)
  decisions.md     contract change log   (you append in /ce-plan --revise)
  status.json      state machine         (current-phase owner updates)
```

`status.json` phases: `planned -> implementing -> review -> passed | failed`
- **failed** -> back to work (the implementation doesn't satisfy the spec).
- **`/ce-plan --revise`** is user-invokable at **any** time when you decide to change a requirement;
  it amends the contract, resets the feature to `planned`, and supersedes any prior
  `report.md`/`review.md`. Review never changes requirements — it may only *advise*; replan is the
  user's call.

## Why separate sessions

- **Plan vs Review run in different sessions** for *objectivity* — a reviewer that didn't
  write the plan won't rubber-stamp its own reasoning, and forces the spec to be complete.
- **Compound runs in the SAME session as Review** for *coupling* — its input is the review
  you just produced; the context is already loaded, so don't open a new session for it.
