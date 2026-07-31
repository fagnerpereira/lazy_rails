# ADR 0004 — Coupled Transitive Dependency Bumps: loofah and rails-html-sanitizer

Date: 2026-07-24
Status: Accepted

## Context

This repo runs the same scheduled PR-maintenance routine described in ADR 0003. This
pass found three open PRs against `main` (`96e2af9`, unchanged since #7 was opened):

- **#7** — `fix: resolve StandardRB lint violations and correct class references in
  Commands::New`. Open, not draft, CI green (Ruby 3.3.4 + GitGuardian both passing).
- **#8** — Dependabot: bump `loofah` 2.22.0 → 2.25.2.
- **#9** — Dependabot: bump `rails-html-sanitizer` 1.6.0 → 1.7.1.

Both #8 and #9 had **failing CI** — not because of anything wrong with the dependency
bump itself, but because their branches were cut from `main` *before* #7's lint fix
existed, so they inherited the same five `Lint/UselessAssignment` violations in
`lib/lazy_rails/commands/new.rb` that #7 fixes. `bundle install` succeeded on both; only
the `standardrb` step failed. This is worth internalizing as a general pattern: a
dependency-bump PR's CI failure is not always about the dependency. Check *what* failed
before assuming the bump itself is broken.

## Why One Gem's Security Patch Bumped Another Gem's Minimum Version

`rails-html-sanitizer` does not implement HTML sanitization itself — it wraps `loofah`,
which wraps `nokogiri`. When `rails-html-sanitizer` 1.7.1 patches an XSS hole
(`GHSA-cj75-f6xr-r4g7`, SVG `href`/`xlink:href` restricted to local references), the fix
actually lives in `loofah`'s scrubbing logic, so the gemspec's dependency floor moves
with it:

```text
rails-html-sanitizer (1.6.0)  loofah (~> 2.21)
rails-html-sanitizer (1.7.1)  loofah (~> 2.25, >= 2.25.2)
```

This is normal for wrapper/adapter gems: a security fix "in" the wrapper is frequently
really a security fix in the thing it wraps, exposed through a version floor rather than
new wrapper code. The teaching point for whoever reads this later: **when a gem's
changelog says "patched X" but the diff is nearly empty, check whether it just bumped a
dependency's minimum version.** That's still a real, necessary fix — it just lives one
layer down.

## Why This Produced Two Separate Dependabot PRs Instead of One

Dependabot opens one PR per direct advisory, not per resolved dependency tree. It saw
two independent GHSA advisories — one against `loofah` directly (`GHSA-5qhf-9phg-95m2`
et al., fixed in 2.25.2) and one against `rails-html-sanitizer` (`GHSA-cj75-f6xr-r4g7`,
fixed in 1.7.1) — and filed #8 and #9 as if they were unrelated. They are not: fixing
either one, done correctly, ends up requiring loofah `>= 2.25.2` in the lockfile. The gem
constraint operator explains why the two PRs *looked* different in scope even though they
converge on the same lockfile state:

- Ruby's pessimistic operator `~> 2.21` (two components) means `>= 2.21, < 3.0` — it only
  pins the **major** version. So loofah could jump all the way to 2.25.2 while
  `rails-html-sanitizer` stayed on 1.6.0 (`loofah ~> 2.21` is still satisfied). That is
  exactly what #8's diff shows: `loofah` bumped, `rails-html-sanitizer` untouched.
- `rails-html-sanitizer` 1.7.1's *own* gemspec tightens the loofah constraint to
  `~> 2.25, >= 2.25.2`. Resolving #9 alone therefore drags `loofah` up to 2.25.2 as a
  side effect — which is why #9's Gemfile.lock diff already contained every line #8's
  diff contained, plus the `rails-html-sanitizer` bump itself. **#9 was a strict superset
  of #8.**

Applying only #8 would have left the actual CVE (`GHSA-cj75-f6xr-r4g7`, in
`rails-html-sanitizer`) unpatched. Applying only #9 would have fully resolved both.
Dependabot doesn't know this — it evaluates each advisory in isolation and lets Bundler's
resolver work out the fallout independently in each PR branch. A human (or an agent
doing this maintenance pass) has to notice the overlap and merge them as one change.

## Decision

1. Cherry-picked #7's fix commits onto this session's designated branch
   (`claude/great-faraday-pec4g1`), verified against `main`'s current SHA (`96e2af9`,
   unmoved since #7 opened). **Note:** #7's own PR description cited commit SHAs
   `1bec49c`/`5f0f91b`/`3a99a11` — none of those exist on the live branch. The actual
   commits on `claude/great-faraday-zifohv` are `c9c1fa5`, `60b0304`, `32f2d91`, and
   `1998cf5` (four commits, the last of which added ADR 0003 — also undocumented in the
   PR body's own summary of "what changed"). This is the same lesson as ADR 0003 in
   reverse: don't trust a PR body's claimed SHA list without diffing it against the live
   branch. Cherry-picked the real, live commits; the result is identical in content to
   what #7 already had reviewed and CI-passed.
2. Resolved #8 and #9 together in a single `bundle lock --update loofah
   rails-html-sanitizer`, rather than as two separate changes, since #9 already subsumes
   #8 as shown above. This produced `loofah 2.25.2` and `rails-html-sanitizer 1.7.1`,
   matching both dependabot PRs' target versions.
3. Bundler's resolver additionally picked `nokogiri 1.19.4` (newer than the `1.17.2` both
   dependabot PRs had computed at filing time) because `rails-html-sanitizer 1.7.1`
   excludes several `1.16.x` nokogiri releases and the rubygems index has moved on since
   #8/#9 were opened. This is expected — a fresh `bundle lock` always resolves against
   the current index, not the index as it existed when a stale PR was filed. `crass` and
   `mini_portile2` moved for the same transitive reason.
4. Left `BUNDLED WITH` at `2.5.17` (reverted an incidental change from running `bundle
   lock` under a newer locally-installed Bundler). CI's `ruby/setup-ruby` step installs
   whatever Bundler version the lockfile pins, and #7/#8/#9 all already passed dependency
   installation under `2.5.17` — only `standardrb` was failing them. Changing this line
   would have been unrelated scope creep.
5. Re-ran the CI-equivalent command (`bundle exec rake`, exactly what `.github/workflows/main.yml`
   runs) locally: **13 examples, 0 failures**; **0 `standardrb` offenses** (exit 0,
   matching #7's claimed baseline exactly).
6. Opened one new PR from this combined branch, closing #7, #8, and #9 with comments
   pointing at it, rather than merging three separate diffs that would each individually
   still fail CI on their own.

## Consequences

- One PR now carries the lint/runtime fix and the full, correctly-coupled security bump,
  and it is green end-to-end — none of #7, #8, #9 individually were.
- Future Dependabot PRs that land on gems in a wrapper relationship (e.g. `nokogiri` →
  `loofah` → `rails-html-sanitizer`, or similar adapter chains) should be diffed against
  each other before merging separately — check whether one's Gemfile.lock diff is a
  superset of another's before assuming they're independent.
- `nokogiri` is now noticeably ahead of what either dependabot PR proposed. If that turns
  out to be undesirable (e.g. a regression surfaces), the fix is to re-run `bundle lock
  --update nokogiri` with an explicit upper bound, not to hand-edit the lockfile.
- PR body SHA lists and "supersedes" claims should be treated as a hypothesis to verify
  against `pull_request_read(method: get_commits)`, not as ground truth — this is the
  second maintenance pass in a row (see ADR 0003) where the PR's own narrative diverged
  from its live commit history.
