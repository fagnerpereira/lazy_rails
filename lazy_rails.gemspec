# frozen_string_literal: true

require_relative "lib/lazy_rails/version"

Gem::Specification.new do |spec|
  spec.name = "lazy_rails"
  spec.version = LazyRails::VERSION
  spec.authors = ["Fagner Pereira Rosa"]
  spec.email = ["fagnerfpr@gmail.com"]

  spec.summary = "ToolBox for lazy developers"
  spec.description = "Lazy developers will rule the world."
  spec.homepage = "https://github.com/fagnerpereira/lazy_rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # gemspec = File.basename(__FILE__)
  # spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
  #   ls.readlines("\x0", chomp: true).reject do |f|
  #     (f == gemspec) ||
  #       f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
  #   end
  # end
  # spec.bindir = "exe"

  # spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "tty-prompt"
  spec.add_dependency "rails"
  spec.executables << "lazy_rails"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
