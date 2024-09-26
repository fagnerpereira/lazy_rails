require "pry"
require "thor"
require "tty-prompt"

module CommandGenerators
  autoload :Options, "lazy_rails/command_generators/options"
end

module LazyRails
  class CLI < Thor
    desc "new", "Start new rails project"
    def new
      puts "Welcome to the Rails Project Setup Wizard!"

      command = CommandBuilder.new(
        PromptGenerators::AskAppName.new(prompt).call
      )
      command.options << PromptGenerators::SelectDb.new(prompt).call
      command.options << app_type = PromptGenerators::SelectAppType.new(prompt).call

      if app_type == "web"
        command.options << PromptGenerators::SelectJs.new(prompt).call
        command.options << PromptGenerators::SelectCss.new(prompt).call
      end

      command.options << PromptGenerators::SelectTools.new(prompt).call
      puts "\nYour Rails project will be created with the following command:"
      puts command.build

      if prompt.yes?("Do you want to run this command now?")
        system(command.build)
        puts "Rails project '#{command.app_name}' has been created!"
      else
        puts "Command not executed. You can run it manually when you're ready."
      end
    end

    desc "version", "Display LazyRails version"
    def version
      puts "LazyRails version #{LazyRails::VERSION}"
    end

    private

    def prompt
      @_prompt ||= TTY::Prompt.new
    end
  end
end
