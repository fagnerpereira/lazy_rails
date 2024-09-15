# LazyRails

I love and Im proud of being a Ruby on Rails developer, but there are 2 specific things I hate in Rails:
1. The verbose command I need to memorizer to create new rails apps (I simply ALWAYS FORGET). Example: `rails new my_app --database=sqlite3 --javascript=importmap --css=tailwind`
2. The amount of tools installed by default, even if I don't need them. Example: ActiveStorage, ActiveText, ActionMailer, ActionMailbox

This gem has 2 puroses:
1. To make it easier to get started creating new projects following an interactive guide (like when you create a vite project)
2. To make it easier to add and install new tools on the fly (its just annoying every time I need for example devise, to open their doc and copy and paste install commands)

## Installation
    $ bundle add lazy_rails

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lazy_rails

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO
- [ ] Add support for chosing views templates (erb, haml and slim)
- [ ] Add support for chosing test tool (rspec, minitest, test_unit)
- [ ] Add support for chosing lint tool (rubocop, standard)
- [ ] Add support for chosing css processor (tailwind, bootstrap, bulma, postcss, sass)
- [ ] Add support for chosing js processor (importmap, bun, webpack, esbuild, rollup)
- [ ] Add support for chosing database (sqlite3, mysql, postgresql)
- [ ] Add support for chosing app type (api, web)
- [ ] Add support for chosing basic setup (actioncable, activejob, actionmailer, action mailbox)
- [ ] Add support to install popular gems on the fly (devise, sidekiq, solid_queue)
- [ ] Write good documentation
- [ ] Increase test coverage
- [ ] Improve error handling and user feedback
- [x] ~~Create basic CLI structure~~
- [x] ~~Implement 'new' command for project generation~~

---

If you'd like to contribute to any of these items, please check our [CONTRIBUTING.md](CONTRIBUTING.md) guide and feel free to submit a pull request!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lazy_rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Some notes
This gem is my first gem in my whole career as Ruby/Rails developer, so sorry if I make some mistakes. I hope you like it!

Also I would like to express my thanks to make this gem possible to:
- DHH and whole Rails community WORKERS. (https://github.com/rails/rails)
- Piotr Murach @piotrmurach, who created tty-prompt gem. (https://github.com/piotrmurach/tty-prompt)
- Chris Oliver @excid3, for being a great reference and inspiration as a Professor and Worker. (https://github.com/excid3)
