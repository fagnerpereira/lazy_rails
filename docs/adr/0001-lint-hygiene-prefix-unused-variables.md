# ADR 0001 — Lint Hygiene: Intentional Variables and WIP Scaffolding

Date: 2026-06-28  
Status: Accepted

## Context

`lib/lazy_rails/commands/new.rb` collects user input through several prompt generators but does not yet wire that input into the final `rails new` command string. As a result, StandardRB flagged five variables as `Lint/UselessAssignment`:

```ruby
app_name = PromptGenerators::AppName.new(prompt).call      # assigned, never read
selected_db = PromptGenerators.new(prompt).call            # assigned, never read
selected_js = PromptGenerators::SelectJs.new(prompt).call  # assigned, never read
selected_css = PromptGenerators::SelectCss.new(prompt).call # assigned, never read
selected_tools = PromptGenerators::SelectTools.new(prompt).call # assigned, never read
```

The same method also contained two runtime bugs masked because no test exercises this code path:
1. `PromptGenerators.new(prompt)` — modules cannot be instantiated; this raises `NoMethodError: undefined method 'new' for module PromptGenerators` at runtime.
2. `PromptGenerators::AppName` — the class is defined as `AskAppName`, not `AppName`.
3. `project_name` was used in a `puts` but was never defined in scope.

## The Lesson: What a Linter Is Really Telling You

A linter catching `Lint/UselessAssignment` is telling you one of three things:

1. **You forgot to use the value** — a genuine bug. You computed a result and discarded it instead of returning it or storing it where it belongs.
2. **The assignment is a side effect you care about** — the right-hand-side has an observable effect (network call, database write, user prompt) and you intentionally discard the return value.
3. **The code is intentionally incomplete** — WIP scaffolding that will be wired up once the feature is built out.

Cases 2 and 3 are both valid, but the linter cannot distinguish them from a mistake. Ruby and StandardRB give you a precise signal for this: **prefix the variable name with `_`**.

```ruby
# Before — linter error, ambiguous intent
selected_db = PromptGenerators::SelectDb.new(prompt).call

# After — intentional, documented
_selected_db = PromptGenerators::SelectDb.new(prompt).call
```

The `_` prefix is a convention understood by every Ruby programmer, the interpreter itself (block parameter warnings), pattern matching, and all major linters. It reads as: "I know I am not using this return value yet. I am not ignoring the linter by accident."

## The Lesson: WIP Code and the Boy Scout Rule

WIP scaffolding is normal and healthy. What is not healthy is WIP code that silently misbehaves.

`PromptGenerators.new(prompt)` will raise `NoMethodError` the first time a real user runs `lazy_rails new`. The tests do not catch it today because they stub the prompt generators, but a real user will hit it immediately. Leaving a known-broken call path in place is a debt that someone will pay — usually by surprise, usually at the worst time.

The **Boy Scout Rule** says: leave the code a little cleaner than you found it. Fixing `PromptGenerators.new` → `PromptGenerators::SelectDb.new` and `AppName` → `AskAppName` costs two minutes now and prevents a `NoMethodError` surprise in the future.

## The Lesson: Module vs. Class in Ruby

In Ruby, `module` and `class` are different things with different capabilities:

- A `class` has `.new` — you can create instances of it.
- A `module` does **not** have `.new` — it is a namespace and/or a mixin, not an object factory.

```ruby
module PromptGenerators; end
PromptGenerators.new  # => NoMethodError: undefined method 'new'

class PromptGenerators::SelectDb; end
PromptGenerators::SelectDb.new  # => #<PromptGenerators::SelectDb:0x...>
```

Always check whether the constant you are calling `.new` on is a `class` or a `module`. The error only surfaces at runtime.

## Decision

1. Prefix all currently-unused prompt variables with `_`.
2. Fix `PromptGenerators::AppName` → `PromptGenerators::AskAppName`.
3. Fix `PromptGenerators.new(prompt)` → `PromptGenerators::SelectDb.new(prompt)`.
4. Fix the undefined `project_name` reference to use the captured `app_name`.

## Consequences

- `bundle exec rake` (StandardRB + tests) passes in CI.
- The module instantiation bug is eliminated before it causes a runtime surprise for users.
- The WIP nature of the feature is preserved — the command still builds as `"rails new"` until the remaining integration work is done.
- Future contributors can read the `_` prefix and know exactly which variables are awaiting wiring.
