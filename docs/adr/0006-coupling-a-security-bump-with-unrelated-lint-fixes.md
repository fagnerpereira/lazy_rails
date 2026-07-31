# ADR 0006 — Should a Security Dependency Bump Ship in the Same PR as Unrelated Lint Fixes?

Date: 2026-07-30
Status: Accepted

## Context

This is another run of the scheduled PR-maintenance routine described in ADR 0003, 0004,
and 0005. This pass found exactly one open PR:

- **#11** — `fix: StandardRB lint fixes + coupled loofah/rails-html-sanitizer security
  bump (Supersedes #10, #7, #8, #9)`. Draft, head `claude/great-faraday-1c8jj7`, base
  `main` at `96e2af9` (unmoved).

Checked before touching anything: `main` hadn't moved, both CI checks (`Ruby 3.3.4`,
`GitGuardian Security Checks`) were green, there was one non-actionable comment (this
session's own prior re-verification note), and zero open review threads. Same situation
ADR 0005 describes for #10 — recreate the verified content on this session's own branch
and supersede, rather than amend someone else's branch or leave a stale draft in place.
Cherry-picked the same six commits cleanly onto `claude/great-faraday-d8jwer`, confirmed
`git diff origin/claude/great-faraday-1c8jj7 HEAD` was empty, and re-ran `bundle exec
rspec` (13 examples, 0 failures) and `bundle exec standardrb` (0 offenses) locally.

That reverification is routine at this point (ADR 0005 already covers why it's worth
doing even when GitHub's checks are green). What hadn't been examined yet, across five
generations of this PR, is a question this pass was explicitly asked to look at: **should
the security bump and the lint fixes really be in the same PR at all?**

## The Tradeoff: One PR vs. Two

**What coupling buys you:**

- One CI run, one review pass, one merge — less process overhead for a two-file change.
- The two changes don't conflict (`Gemfile.lock` vs. `lib/lazy_rails/commands/new.rb`),
  so combining them costs nothing in merge risk.
- A reviewer only has to context-switch once instead of twice.

**What coupling costs you:**

- **Bisectability.** If something regresses after merge, `git bisect` (or just reading
  the log) lands on a commit that changed two unrelated things. This repo's commits are
  already split per-concern internally (the lint fix and the dependency bump are separate
  commits, not squashed), which mitigates this — but the PR-level CI signal is still one
  green/red checkmark covering both, so a reviewer skimming PR status can't tell which
  half passed just from the PR list.
- **Review latency asymmetry.** Lint fixes invite bikeshedding (naming conventions,
  whether `_app_name` vs `app_name` is right — see ADR 0001/0002, which took two rounds
  to settle). A security fix riding along with a slower-to-review style change inherits
  that latency. The reverse is also true: if the security bump needed urgent scrutiny
  (e.g. "does this break anything at runtime"), it shouldn't be gated on unrelated lint
  debate.
- **Independent revert.** If the lint fix turned out to be wrong post-merge, reverting it
  cleanly (without also reverting the security bump) requires a partial revert instead of
  `git revert <merge-sha>`.

Neither side of this tradeoff is free, and no general rule ("always split," "always
combine") survives contact with every repo. It depends on deployment cadence and blast
radius.

## The Judgment Call for *This* Repo

`lazy_rails` is a Rails **application generator CLI gem** — it runs once, locally, when a
developer scaffolds a new app; it is not a long-running service parsing untrusted HTML at
request time. The `loofah`/`rails-html-sanitizer` chain sits in `Gemfile.lock` as a
transitive dependency of the gem's own dev/test toolchain, not as production
sanitization logic this CLI executes against attacker-supplied input in a deployed,
internet-facing process. That matters for how urgently the fix needs to land:

- In a **live web app**, every day a sanitizer CVE fix sits unmerged in review is a day a
  running, internet-facing process stays exploitable. There, coupling it to a slower
  style-fix review is a real cost, and the right call is almost always to ship the
  security bump alone, on the fastest possible path, and let lint fixes trail behind on
  their own PR.
- Here, there's no live exposure window ticking — merging the bump next week doesn't
  leave any running instance more exploitable than merging it today. Given that, and
  given the two files don't conflict, keeping this pass's convention of one small,
  fully-green PR is the pragmatic choice: it's what generations #7 through #11 already
  did, splitting now would be pure process churn with no corresponding safety benefit,
  and every regeneration so far has re-verified both halves pass independently anyway
  (separate commits, both tested).

**Decision for this pass: keep them coupled**, but this ADR exists so the *next* session
re-evaluating this PR doesn't have to re-derive the reasoning — and so a junior reading
this repo's history understands this was a deliberate call for a CLI-generator repo, not
a default to copy uncritically into a production web service.

## The CVE Class, for a Junior Reading This Later

ADR 0004 already covers *why* `rails-html-sanitizer` and `loofah` version bumps travel
together (a dependency-floor relationship, not two independent changes). What it doesn't
spell out is *what kind of vulnerability class this is* — worth knowing before you decide
how urgently a fix like this deserves to ship.

`rails-html-sanitizer` is the gem Rails uses under the hood for `sanitize`,
`strip_tags`, and `strip_links` — any time application code takes a string that might
contain HTML (a comment, a bio field, a rich-text body) and either allows a safe subset
of markup through or strips it down to plain text before rendering it back into a page.
`loofah` is the layer underneath that actually walks the parsed HTML/XML tree and decides
what to keep, rewrite, or drop.

**The bug class:** a sanitization bypass. The sanitizer's job is to take attacker-
controlled markup and guarantee that whatever comes out the other side can't execute
script when the browser renders it. A bypass means some crafted input exists that slips
an executable payload past the scrubber — most often by hiding it somewhere the parser's
allow-list logic doesn't check as carefully as it checks plain `<script>` tags: an
`href`/`xlink:href` attribute on an `<svg>` or similar element that the browser will still
treat as executable context (`javascript:` URIs, external references) even though it
looks like an inert attribute value to a naive scrubber. GHSA-cj75-f6xr-r4g7, the specific
advisory behind this bump, is exactly that shape: SVG `href`/`xlink:href` values weren't
being restricted to local (same-document) references, so a crafted value could point at
something a browser would execute.

**Why that's XSS, concretely:** if any part of your app renders user-supplied content
through `sanitize` and trusts the result to be safe, and an attacker's input survives
sanitization with a live script vector intact, that script now runs in the browser of
*whoever views that content* — with that victim's cookies, session, and DOM access. If
the sanitized string gets saved to the database first (a comment, a profile field) and
rendered for other users later, it's **stored XSS** — every future viewer is a victim,
not just the attacker's own session. If it's sanitized and echoed back in the same
request/response cycle (e.g. a search query rendered on a results page), it's **reflected
XSS** — the attacker needs to get a victim to click a crafted link, but the payload never
touches storage.

**The one-sentence version for a junior:** "sanitizer bypass" doesn't mean the sanitizer
crashed or errored — it means it ran successfully, said the output was safe, and was
wrong. That's why these bumps matter even when nothing in your own application code
changed: the safety guarantee your app was relying on moved, silently, until you update
the gem.

## Decision

1. Cherry-picked #11's six commits onto this session's own branch
   (`claude/great-faraday-d8jwer`), verified content-identical via empty `git diff`
   against `claude/great-faraday-1c8jj7`.
2. Re-ran `bundle exec rspec` (13 examples, 0 failures), `bundle exec standardrb`
   (0 offenses), and `bundle exec rake` (the exact CI command) locally before pushing.
3. Kept the security bump and lint fixes coupled in one PR, per the reasoning above —
   this repo's low deployment-cadence risk profile (a CLI generator, not a live service)
   makes the coupling cost negligible, and it matches the convention every prior
   generation of this PR already used.
4. Added this ADR so the tradeoff and the CVE-class explanation are documented once,
   for whoever (human or agent) next has to decide whether to keep coupling them.
5. Opened a new PR from this branch, superseding #11, and closed #11 with a comment
   pointing to the new PR.

## Consequences

- The verified fix (lint/runtime corrections + coupled `loofah`/`rails-html-sanitizer`
  security bump) continues to move forward as one PR, under a fresh session's own
  branch, per the ADR 0003 convention.
- If this repo ever becomes (or gains) a long-running, internet-facing component that
  processes untrusted HTML at request time, this decision should be revisited: the
  "no live exposure window" reasoning above is specific to a CLI generator and stops
  applying the moment that's no longer true.
- A future maintenance pass that finds a *slow-moving* lint PR blocking a *time-sensitive*
  security PR should split them, even in this repo — the default here is "couple when
  cheap," not "always couple."
