# ADR 0003 — Superseding a PR Instead of Pushing to Another Session's Branch

Date: 2026-07-22
Status: Accepted

## Context

This repo runs a scheduled, recurring PR-maintenance routine: an agent periodically
re-checks open PRs (CI status, new review comments, whether `main` has moved, whether
the merge-tree is still clean) and acts only if something has actually changed.

PR #6 (`claude/great-faraday-tsu9pl`) was re-verified on 2026-07-22 and found completely
unchanged since the last check on 2026-07-19: CI still green, no new review comments, no
conflicts, `mergeable_state: clean`. The verified content itself was fine — the only
question was *how* to act given that nothing needed fixing.

## The Problem: Whose Branch Is It?

`claude/great-faraday-tsu9pl` was created by a **previous, separate agent session**, not
the one running this maintenance check. Two options existed:

1. Leave PR #6 exactly as-is (do nothing, since nothing changed).
2. Recreate the same verified commits on *this* session's own designated branch, open a
   new PR, and close #6 pointing to it.

The task instructions for this routine specify option 2 when nothing has changed. The
reasoning generalizes beyond this one repo: **do not commit onto a branch you did not
create**, even to fix a trivial thing, unless you have a specific reason to believe that
branch is shared/collaborative. A branch namespaced to a session (`claude/<session-id>`)
is that session's workspace. Pushing new commits onto someone else's — even a previous
run of "the same agent" — risks:

- Racing with that other session if it resumes and pushes too (silently clobbering work,
  or producing a confusing divergent history).
- Attributing changes to a session that had no chance to verify them.
- Making it hard for a human reviewer to tell *which* session is responsible for what,
  when something needs to be debugged later.

Recreating the commits elsewhere and superseding the PR keeps every session's blast
radius limited to its own branch, at the cost of a new PR number. That trade is cheap:
PR numbers are free: authorship and auditability are not.

## The Lesson: Cherry-Pick Only What You Verified, Not Everything Nearby

While recreating #6's commits, the branch `claude/great-faraday-tsu9pl` was found to
contain *six* commits, not three: two dependabot dependency bumps (`rack`, `rack-session`)
and a merge commit, in addition to the three commits that were actually the reviewed
change (`1bec49c`, `5f0f91b`, `3a99a11`). Those three were the only ones described in the
PR's own body and verified in its checklist.

The dependabot bumps were never merged into `main` through any other path — `main` is
still on the older `rack`/`rack-session` versions. Blindly replaying the *whole* source
branch onto a fresh one would have silently reintroduced an unrelated, unreviewed
dependency change riding along with the lint fix, and inflated the new PR's diff beyond
what was actually verified.

**Rule applied:** when asked to "recreate this PR's verified commits," recreate exactly
the commits that constitute *that PR's change* — cross-check the PR's own file list
(`changed_files`) and description against the branch's full commit log before picking
which SHAs to cherry-pick. Do not assume a feature branch's commit history is scoped to
just the feature; branches accumulate incidental history (merges, unrelated bumps) that
should not be smuggled into an unrelated supersession.

## Decision

1. Cherry-pick only `1bec49c`, `5f0f91b`, `3a99a11` onto this session's own branch
   (`claude/great-faraday-zifohv`), leaving out the incidental `rack`/`rack-session`
   Gemfile.lock bumps present in the old branch's history.
2. Re-run `bundle exec rspec` and `standardrb` locally before pushing, rather than
   trusting the prior session's 2026-07-10 verification note.
3. Open a new PR (#7) referencing #6, and close #6 with a comment explaining why,
   rather than force-pushing or amending history on the previous session's branch.
4. Leave the four gemini-code-assist review threads open/unresolved (per repo
   convention) — they carry forward to #7's context via the closing comment, but
   resolving them is a human decision, not this agent's.

## Consequences

- #7 carries a clean, minimal diff scoped exactly to the lint/runtime fix — no
  incidental dependency bumps.
- No commits were pushed to a branch this session did not create.
- A human reviewer can still see the full history and reasoning on #6 (closed, not
  deleted) and pick up review on #7 without re-deriving what changed or why.
- The unrelated `rack`/`rack-session` bump remains unaddressed — it is out of scope
  here and should be picked up as its own dependency-update PR if still needed.
