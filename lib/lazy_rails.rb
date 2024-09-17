# frozen_string_literal: true

require_relative "lazy_rails/version"
require_relative "lazy_rails/prompt_generators"
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
      yield self
      build_command
    end

    def build_command
      base_command = ["rails new #{app_name}"]
      options.map do |option|
        base_command << NewCommand::OPTIONS[option]
      end.join(" ")
    end
  end
end
