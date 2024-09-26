# frozen_string_literal: true

require_relative "lazy_rails/version"
require_relative "lazy_rails/prompt_generators"
require_relative "lazy_rails/cli"
# require_relative "lazy_rails/commands/new"
# require_relative "lazy_rails/commands/new_command/generator"

module LazyRails
  module NewCommand
    OPTIONS = {
      "api" => "--api",
      "mysql" => "--database=mysql",
      "postgresql" => "--database=postgresql",
      "trilogy" => "--database=trilogy",
      "esbuild" => "--javascript=esbuild",
      "bun" => "--javascript=bun",
      "rollup" => "--javascript=rollup",
      "webpack" => "--javascript=webpack",
      "tailwind" => "--css=tailwind",
      "bootstrap" => "--css=bootstrap",
      "bulma" => "--css=bulma",
      "postcss" => "--css=postcss",
      "sass" => "--css=sass",
      "jbuilder" => "--skip-jbuilder",
      "minitest" => "--skip-test",
      "rubocop" => "--skip-rubocop",
      "brakeman" => "--skip-brakeman"
    }
  end

  class Error < StandardError; end

  class CommandBuilder
    attr_accessor :app_name, :options

    def initialize(app_name)
      @app_name = app_name
      @options = []
    end

    def build
      if block_given?
        yield self
      end
      command = base_command + build_options
      command.compact.join(" ").strip
    end

    def build_options
      options.flatten.map do |option|
        NewCommand::OPTIONS[option]
      end
    end

    def base_command
      ["rails new #{app_name}"]
    end
  end
end
