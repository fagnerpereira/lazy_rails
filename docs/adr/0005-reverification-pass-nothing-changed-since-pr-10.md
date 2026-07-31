# ADR 0005 — Reverification Pass: PR #10 Unchanged, Recreated on a New Branch

Date: 2026-07-25
Status: Accepted

## Context

This is another run of the scheduled PR-maintenance routine described in ADR 0003 and
ADR 0004. This pass found exactly one open PR:

- **#10** — `fix: StandardRB lint fixes + coupled loofah/rails-html-sanitizer security
  bump (Supersedes #7, #8, #9)`. Draft, head `claude/great-faraday-pec4g1`, base `main`
  at `96e2af9`.

Checked before touching anything:

- `main` had **not moved** — still at `96e2af9`, the same SHA #10 was opened against.
- CI on #10's head commit was green: both check runs (`Ruby 3.3.4`, `GitGuardian
  Security Checks`) completed with `conclusion: success`.
- Comments: one, from `gemini-code-assist[bot]`, stating that bot's consumer review
  service has been sunset — not actionable, not a review request.
- Review threads: zero open.
- No other open PRs existed to fold in.

In short: nothing changed since #10 was last verified. This is the same situation ADR
0003 describes for PR #6 — the correct action is not "do nothing" (leaving a stale draft
around forever isn't maintenance) and not "amend #10's branch" (that branch belongs to a
previous session, per ADR 0003's reasoning), but to **recreate the same verified content
on this session's own branch and supersede the PR**, even though the diff is identical.

## The Lesson: A Green, Unchanged PR Still Needs a Fresh Session to Re-Confirm It

It would be tempting to treat "CI already passed, nothing changed" as a reason to skip
local verification entirely and just cherry-pick blind. Resist that. Two things are worth
re-checking locally even when GitHub's own checks are green:

1. **CI green is necessary, not sufficient, for *this* session's confidence.** A previous
   session's CI run proves the code worked against the CI image at that time. Re-running
   `bundle exec rspec` and `bundle exec standardrb` locally, on the exact commits about to
   be pushed, confirms this session isn't relying on someone else's word for it — the same
   principle ADR 0004 applied when it re-ran the suite instead of trusting a stale note.
2. **A clean cherry-pick is a real check, not a formality.** If `main` had moved even
   slightly, the same commits might no longer apply cleanly, or might apply cleanly but
   produce a different merged result than what CI actually tested. Diffing the result
   against the source branch (`git diff origin/<old-branch> HEAD`) after cherry-picking
   confirms the recreated branch is byte-for-byte the same tree that was reviewed — not
   just "close enough."

This pass did both: cherry-picked #10's five commits (`60a0a38`, `27f6a69`, `ae9776e`,
`2d660ed`, `0565e4b`) cleanly with no conflicts, confirmed `git diff
origin/claude/great-faraday-pec4g1 HEAD` was empty (content-identical), and re-ran the
CI-equivalent commands locally.

## Why No New "Coupled Dependency" Lesson Here

ADR 0004 already documents, in depth and at a level appropriate for a junior engineer,
why a security fix in one gem (`rails-html-sanitizer`) can require bumping a
dependency-of-a-dependency (`loofah`), and how to recognize that two Dependabot PRs
filed against the same wrapper chain are really one change in disguise (check whether one
PR's `Gemfile.lock` diff is a strict superset of the other's). Nothing in this pass adds
a new instance of that pattern or a new wrinkle to it, so this ADR doesn't repeat it —
readers should go to ADR 0004 for that lesson. Re-explaining an already-well-covered
lesson in a new ADR just to have "something new" would dilute the one clear write-up
that exists.

## Decision

1. Cherry-picked #10's five commits onto this session's own branch
   (`claude/great-faraday-1c8jj7`), verified clean (no conflicts) against `main` at the
   unchanged `96e2af9`.
2. Confirmed the recreated branch is content-identical to `claude/great-faraday-pec4g1`
   via `git diff` (empty output).
3. Re-ran `bundle exec rspec` (13 examples, 0 failures) and `bundle exec standardrb`
   (0 offenses, exit 0) locally rather than relying solely on GitHub's cached check
   results.
4. Opened one new draft PR from this branch, superseding #10, and closed #10 with a
   comment pointing to the new PR and a best-effort delete of `claude/great-faraday-pec4g1`.
5. Did not add a new "coupled dependency" writeup, since ADR 0004 already covers it.

## Consequences

- The verified fix (lint/runtime corrections + coupled `loofah`/`rails-html-sanitizer`
  security bump) continues to move forward under a fresh session's own branch, per the
  ADR 0003 convention, without ever amending a previous session's branch.
- A human reviewer opening the new PR can trust that this session independently
  re-confirmed both the merge-cleanliness and the test/lint results, not just copied
  GitHub's green checkmark.
- The next maintenance pass should keep checking whether `main` has moved before
  assuming a straight cherry-pick will still apply — this pass got lucky that it hadn't.
