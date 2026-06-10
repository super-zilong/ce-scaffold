# Compound Engineering — minimal multi-agent scaffold

A zero-dependency scaffold for **compound engineering** across two coding agents,
**Claude Code** and **Pi**. All four phases — **plan → work → review → compound** — exist as
commands on **both** agents; the user chooses which agent runs which phase. A common split is
Claude plans/reviews/compounds while Pi implements, but nothing is locked to one agent.

No plugins, no Python, no CLI to install. Just markdown commands + a shared rules file +
a thin orchestrator. The whole thing is built on one principle:

> **The filesystem is the message bus.** Agents are separate processes with no shared
> memory; they hand off through files in `spec/<feature>/`. Lessons accumulate in
> `docs/engineering-rules.md`, which **both** agents read — so each round makes the next
> one easier (the "compound" in compound engineering).

## Layout

```
CLAUDE.md                     Claude Code entry — phase-neutral brief + includes shared rules
AGENTS.md                     Pi entry — phase-neutral brief + points at shared rules
docs/engineering-rules.md     SHARED rule library (both agents read; compound appends here)
.claude/
  commands/                   Claude Code's four phase commands (/ce-plan|work|review|compound)
    ce-plan.md  ce-work.md  ce-review.md  ce-compound.md
  agents/
    rules-curator.md          subagent that de-dups/prunes the rules file when it bloats
.pi/
  prompts/                    Pi's four phase templates — same names, Pi-native format
    ce-plan.md  ce-work.md  ce-review.md  ce-compound.md
spec/
  _template/                  shape for requirements/design/tasks/status
  <NNN-feature>/              one folder per feature (the handoff contract)
orchestrate.ps1               optional: chains the phases headlessly (方式 B)
```

Both command sets are identical in intent and drive the same `spec/` files — only the file
format differs (Claude `.claude/commands/*.md` with frontmatter; Pi `.pi/prompts/*.md` with
`$ARGUMENTS` substitution). Pick any agent for any phase.

## The loop (maps to compound engineering's plan → work → review → compound)

| Phase     | Default agent | Session            | Reads                       | Writes                         |
|-----------|---------------|--------------------|-----------------------------|--------------------------------|
| Plan      | either        | #1 (own)           | request + rules             | `requirements/design/tasks.md` |
| Work      | either (often Pi) | separate       | `tasks.md` + rules          | code + `report.md`             |
| Review    | either        | #2 (NOT the planner/implementer) | spec + diff   | `review.md` (PASS/FAIL)        |
| Compound  | either        | inside the review session | `review.md`         | new rule -> `engineering-rules.md` |

The "default agent" column is just a suggestion — **any phase runs in either agent**. What
matters is the *session* discipline, which is agent-neutral:

**Why the session split:** Plan and Review run in *different* sessions so the reviewer
isn't anchored to its own plan (objectivity, and it forces the spec to be complete).
Compound runs *inside* the Review session because its input is the review you just
produced — opening a fresh session there would only re-load the same context.

`status.json` phases: `planned -> implementing -> review -> passed | failed`.
On FAIL, fix in the work phase and re-`/ce-review`. Compound only fires on PASS (so the rule
reflects the real fix, not a mid-loop guess).

## Changing a requirement

Requirements are changed by **you**, never by an agent — via
`/ce-plan <feature> --revise "<change>"`. The invariant: **review never rewrites the contract; only
`/ce-plan` does.** `--revise` amends `requirements.md`/`design.md` in place, bumps `spec_version`,
resets the feature to `planned`, and **appends to `spec/<feature>/decisions.md`** (append-only audit
trail of *why* intent changed). Any prior `report.md`/`review.md` becomes stale; the feature re-runs
work → review.

Run it anytime — even after a feature has PASSed:

```
/ce-plan 002-fastapi-health-api --revise "add a 'service' name field to the /health JSON"
```

**Where review fits.** Review's verdict is only **PASS** or **FAIL** — it judges the implementation
against the spec, not whether the spec is right. If the reviewer suspects a requirement itself is the
problem (contradictory, infeasible, wrong), it can leave an **advisory** note in `review.md` pointing
you at `/ce-plan --revise`. But that's only advice — *you* decide whether to replan. Review never
sets a "replan" state and never edits the contract.

Why this matters for compounding: the *reasons* requirements change (in `decisions.md`) are
first-class lessons. On the eventual PASS, `/ce-compound` can distill a `[plan]` rule so the same
bad-requirement class gets caught at plan time next round — the system learns to plan better, not
just to code better.

## How to use

### Path A — manual (recommended to start)

Run each phase in whichever agent you like — same command names on both. A typical mix:

1. **Plan** (Claude Code):  `/ce-plan health-endpoint add a /health route returning build info`
2. **Work** (Pi, or Claude Code):  `/ce-work 001-health-endpoint`
   - in Pi, pointed at `AGENTS.md`, implementing from `spec/001-health-endpoint/`.
3. **Review** (a fresh session — either agent, just not the one that planned/implemented):
   `/ce-review 001-health-endpoint`
   - writes `review.md`; on **PASS** it chains into `/ce-compound 001-health-endpoint`,
     which appends a rule to `docs/engineering-rules.md`.

You could equally plan in Pi and review in Claude, or run all four in one agent — the `spec/`
files are the only thing that carries state between phases.

### Path B — scripted

```powershell
./orchestrate.ps1 -Request "add a /health endpoint returning build info"
# resume after a FAIL:
./orchestrate.ps1 -Request "..." -Feature 001-health-endpoint
```

## Wiring notes

- **Pi entry point:** Pi auto-loads `AGENTS.md` and discovers `/ce-*` templates from
  `.pi/prompts/`. Both are phase-neutral now — Pi can run plan/work/review/compound. If your
  Pi reads a different config file, mirror `AGENTS.md` into it.
- **Pi prompt templates** live in `.pi/prompts/` and are invoked as `/ce-plan`, `/ce-work`,
  `/ce-review`, `/ce-compound` (same as Claude). They use `$ARGUMENTS` substitution.
- **Pi CLI flags** in `orchestrate.ps1` are illustrative — adjust to your installed `pi`.
- **git:** `/ce-review` prefers `git diff` to see changes. If you `git init` this repo, review
  gets sharper; without git it falls back to reading the files `report.md` lists.
- **Rule bloat:** once `engineering-rules.md` gets long or contradictory, the compound step
  hands off to the `rules-curator` subagent to merge/generalize/retire — keeping it tight.

## Extending

- Add a `[role]` tag scheme to target rules at a specific agent (`[impl/Pi]`, `[plan/Claude]`).
- Swap Pi for any other implementation agent — the contract is just the `spec/` files.
- Add more phases (e.g. a `/release` command) by following the same file-handoff pattern.
