#requires -Version 7
<#
  orchestrate.ps1 — drives the compound-engineering loop across two agents:
    PLAN (Claude Code)  ->  IMPLEMENT (Pi)  ->  REVIEW + COMPOUND (Claude Code)

  This is the AUTOMATED path (方式 B). The PRIMARY/simplest path is manual (方式 A):
    1. run  /ce-plan <feature> <request>   in Claude Code
    2. switch to Pi, let it implement from spec/<feature>/   (or /ce-work as fallback)
    3. run  /ce-review <feature>            in Claude Code (chains into /ce-compound on PASS)
  Use this script once the manual flow feels solid.

  Each Claude step is an INDEPENDENT headless session (claude -p) on purpose:
  state is carried by files in spec/<feature>/, NOT by chat memory. Plan and Review
  run in different sessions for objectivity; Compound runs inside the /ce-review session.

  Usage:
    ./orchestrate.ps1 -Request "add a /health endpoint returning build info"
    ./orchestrate.ps1 -Request "..." -Feature 001-health-endpoint   # resume after a FAIL
#>
param(
  [Parameter(Mandatory)][string]$Request,   # the feature request, plain English
  [string]$Feature                          # optional: existing spec id to resume (NNN-slug)
)

$ErrorActionPreference = 'Stop'

function Invoke-Claude([string]$Prompt) {
  # Headless, single-shot session. acceptEdits lets it write spec/ and code files
  # without prompting. Drop to 'plan' or default if you want to approve each edit.
  claude -p $Prompt --permission-mode acceptEdits
}

# 1) PLAN — Claude Code, session #1  (skipped when resuming an existing feature)
if (-not $Feature) {
  Write-Host "`n=== PLAN (Claude Code) ===" -ForegroundColor Cyan
  Invoke-Claude "/ce-plan $Request"
  $Feature = (Get-ChildItem spec -Directory |
              Where-Object Name -ne '_template' |
              Sort-Object Name | Select-Object -Last 1).Name
  if (-not $Feature) { throw "Plan step produced no spec/ folder." }
  Write-Host "Planned feature: $Feature"
}

# 2) IMPLEMENT — Pi, separate process
Write-Host "`n=== IMPLEMENT (Pi) ===" -ForegroundColor Cyan
# NOTE: adjust this invocation to YOUR installed Pi CLI — flags are illustrative.
# Pi must read tasks.md + design.md + docs/engineering-rules.md, implement, write
# report.md, and set status.json -> "review". Point Pi at AGENTS.md for its full brief.
pi -p @"
Read spec/$Feature/tasks.md, spec/$Feature/design.md and docs/engineering-rules.md.
Implement every task and check items off in tasks.md. Run the test suite. Write
spec/$Feature/report.md (changes + test output + risks). Set spec/$Feature/status.json
phase to 'review'. Do not edit requirements.md or design.md.
"@

# 3) REVIEW — Claude Code, session #2 (independent of #1 for objectivity)
Write-Host "`n=== REVIEW (Claude Code) ===" -ForegroundColor Cyan
Invoke-Claude "/ce-review $Feature"

# 4) COMPOUND — only on PASS. It reads review.md from disk, so a separate headless
#    session is fine here (interactive users run it inside the review session instead).
$status = Get-Content "spec/$Feature/status.json" -Raw | ConvertFrom-Json
if ($status.phase -eq 'passed') {
  Write-Host "`n=== COMPOUND (Claude Code) ===" -ForegroundColor Cyan
  Invoke-Claude "/ce-compound $Feature"
}

# 5) Report outcome
Write-Host "`n=== DONE: $Feature -> $($status.phase) ===" -ForegroundColor Green
if ($status.phase -eq 'failed') {
  Write-Host "Review FAILED. Read spec/$Feature/review.md, then re-run:" -ForegroundColor Yellow
  Write-Host "  ./orchestrate.ps1 -Request '$Request' -Feature $Feature"
  # If review's findings include an *advisory* that a requirement itself is wrong, that's a
  # human call — run `/ce-plan $Feature --revise '<change>'` yourself, then re-run this script.
}
