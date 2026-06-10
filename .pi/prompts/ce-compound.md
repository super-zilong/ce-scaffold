Compound the lesson from **$ARGUMENTS** — the COMPOUND phase. Run right after a PASS, ideally
in the same session as `/ce-review` (its output is your input). If you are fresh, read
`spec/$ARGUMENTS/review.md` first.

Pre-check: only compound when `spec/$ARGUMENTS/status.json` phase is `"passed"`. If `"failed"`,
STOP — there is no settled lesson yet.

1. Ask: "What GENERAL, reusable rule would have prevented the issues found this round, or made
   it go smoother?" Generalize beyond this one feature.
2. Append the lesson(s) to `docs/engineering-rules.md` under `## Rules` — one line each, tagged
   `[all]`/`[plan]`/`[impl]`/`[review]`, with a trailing `<!-- compound: $ARGUMENTS -->` marker.
   SKIP anything that merely duplicates an existing rule.
3. If the rules file is now noisy or has duplicates/contradictions, consolidate it
   CONSERVATIVELY yourself: merge/generalize, move obsolete rules to `## Retired rules` (don't
   delete), keep it high-signal. (Claude Code has a dedicated `rules-curator` subagent for this;
   in Pi, just do it carefully inline.)
4. Print which rule(s) you added, or "no new rule — already covered".
