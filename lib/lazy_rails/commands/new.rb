require "thor"
require "tty-prompt"

module LazyRails
  module Commands
    class New < Thor
      include NewCommand::Options

      RAILS_NEW_COMMAND = ["rails new"]

      desc "new", "Start new rails project"
      def new
        puts "Welcome to the Rails Project Setup Wizard!"

        app_name = PromptGenerators::AskAppName.new(prompt).call
        _selected_db = PromptGenerators::SelectDb.new(prompt).call
        selected_app_type = PromptGenerators::SelectAppType.new(prompt).call

        if selected_app_type == "web"
          _selected_js = PromptGenerators::SelectJs.new(prompt).call
          _selected_css = PromptGenerators::SelectCss.new(prompt).call
        end

        _selected_tools = PromptGenerators::SelectTools.new(prompt).call

        rails_new_command = RAILS_NEW_COMMAND.compact.join(" ")

        # Display the final command
        puts "\nYour Rails project will be created with the following command:"
        puts rails_new_command

        # Ask for confirmation
        if prompt.yes?("Do you want to run this command now?")
          system(rails_new_command)
          puts "Rails project '#{app_name}' has been created!"
        else
          puts "Command not executed. You can run it manually when you're ready."
        end
      end

      private

      def prompt
        @_prompt ||= TTY::Prompt.new
      end
    end
  end
end
