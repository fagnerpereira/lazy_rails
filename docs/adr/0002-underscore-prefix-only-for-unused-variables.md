# ADR 0002 — The Underscore Prefix Convention: Only for Truly Unused Variables

Date: 2026-06-29
Status: Accepted

## Context

[ADR 0001](0001-lint-hygiene-prefix-unused-variables.md) introduced the Ruby `_` prefix
convention to silence `Lint/UselessAssignment` errors on variables that collect prompt
results but are not yet wired into the `rails_new_command` string.

One of those prefixes was applied incorrectly. The variable `_app_name` was prefixed
with `_` to suppress the linter — but then used two lines later in the success message:

```ruby
_app_name = PromptGenerators::AskAppName.new(prompt).call
# ... several lines ...
puts "Rails project '#{_app_name}' has been created!"
```

This introduced a new linter error:

```
Lint/UnderscorePrefixedVariableName: Do not use prefix '_' for a variable that is used.
```

StandardRB (and RuboCop) enforce two complementary rules that together form a single
contract with the reader:

| Rule | Message | Meaning |
|------|---------|---------|
| `Lint/UselessAssignment` | Useless assignment to variable - `foo` | You assigned `foo` but never read it — delete or prefix `_`. |
| `Lint/UnderscorePrefixedVariableName` | Do not use prefix `_` for a variable that is used. | You read `_foo` — remove the prefix. |

These two rules are intentionally contradictory: they enforce that `_` carries precise
semantic meaning. The prefix is not a silence switch — it is a **signal to every reader**
that the variable will never be read.

## The Lesson: `_` Is a Communication Tool, Not a Linter Bypass

When you write `_app_name`, you are making a promise to the next developer:

> "I know this value is being captured. I am deliberately not using it — perhaps because
> the API requires the argument, or because this code is scaffolding where the binding
> will be removed soon."

If you then _read_ `_app_name`, you have broken that promise. The code now contradicts
itself: the name says "unused" but the body says "used."

Concrete rule: **prefix `_` if and only if the variable is never read after assignment.**

```ruby
# Correct — truly unused, perhaps a required block param
[1, 2, 3].each_with_index { |_item, index| puts index }

# Correct — capturing a gem API result we must assign but won't use
_response = net.get("/ping")   # side-effect matters; return value does not

# Incorrect — prefixed but then read (this PR's bug)
_app_name = ask_for_name
puts "Created #{_app_name}"   # lint error: UnderscorePrefixedVariableName
```

## Why Did This Happen?

The previous PR applied the `_` prefix mechanically to all variables flagged by
`Lint/UselessAssignment`. One of those variables (`app_name`) was used — in the success
message at the bottom of the method. The linter reported it as "useless" only because
the search did not scroll far enough to spot the usage.

This is a common failure mode:

1. Linter flags variable `foo` as unused.
2. Developer adds `_` prefix without reading the full method body.
3. Linter now flags `_foo` as "used but underscore-prefixed."
4. Developer is confused: "I thought I fixed it?"

**Always read the entire method before deciding how to handle a lint warning.**

If you are unsure whether a variable is used downstream:

```bash
grep -n 'app_name' lib/lazy_rails/commands/new.rb
```

Two hits? The variable is used. Remove the prefix, or refactor to make the flow clearer.

## Decision

Remove the `_` prefix from `app_name` in `lib/lazy_rails/commands/new.rb`. The variable
is genuinely used in the success message. No other changes are needed; the other
underscore-prefixed variables (`_selected_db`, `_selected_js`, `_selected_css`,
`_selected_tools`) remain prefixed because they are truly unused — consistent with ADR 0001.

## Consequences

- `Lint/UnderscorePrefixedVariableName` error is resolved.
- `bundle exec rake` (StandardRB + tests) passes CI.
- The code accurately communicates which bindings are placeholders and which are live.
- Future contributors have a clear model: read the full method before applying `_`.
