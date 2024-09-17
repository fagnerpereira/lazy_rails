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

        app_name = PromptGenerators::AppName.new(prompt).call
        selected_db = PromptGenerators.new(prompt).call
        selected_app_type = PromptGenerators::SelectAppType.new(prompt).call

        if selected_app_type == "web"
          selected_js = PromptGenerators::SelectJs.new(prompt).call
          selected_css = PromptGenerators::SelectCss.new(prompt).call
        end

        selected_tools = PromptGenerators::SelectTools.new(prompt).call

        rails_new_command = RAILS_NEW_COMMAND.compact.join(" ")

        # Display the final command
        puts "\nYour Rails project will be created with the following command:"
        puts rails_new_command

        # Ask for confirmation
        if prompt.yes?("Do you want to run this command now?")
          system(rails_new_command)
          puts "Rails project '#{project_name}' has been created!"
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
