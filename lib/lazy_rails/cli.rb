require "thor"
require "tty-prompt"

# TODO: add a way to select rails version
module LazyRails
  class CLI < Thor
    desc "new", "Start new rails project"
    def new
      prompt = TTY::Prompt.new

      puts "Welcome to the Rails Project Setup Wizard!"

      # Project name
      project_name = prompt.ask("What is the name of your project?") do |q|
        q.required true
        q.validate(/\A[\w-]+\z/)
        q.messages[:valid?] = "Project name can only contain letters, numbers, underscores, and dashes"
      end

      # Database selection
      database = prompt.select("Choose your database:", %w[sqlite3 mysql postgresql])

      # JavaScript approach
      js_approach = prompt.select("Choose your JavaScript approach:", %w[importmap bun webpack esbuild rollup])

      # CSS processor
      css_processor = prompt.select("Choose your CSS processor:", %w[tailwind bootstrap bulma postcss sass])

      # Additional options
      skip_test = prompt.yes?("Skip test files?")
      skip_system_test = prompt.yes?("Skip system test files?")
      api_mode = prompt.yes?("Set up as API-only application?")

      # Build the command
      command = "rails new #{project_name} "
      command += "--database=#{database} "
      command += "--javascript=#{js_approach} "
      command += "--css=#{css_processor} "
      command += "--skip-test " if skip_test
      command += "--skip-system-test " if skip_system_test
      command += "--api " if api_mode
      command += "--minimal"

      # Display the final command
      puts "\nYour Rails project will be created with the following command:"
      puts command

      # Ask for confirmation
      if prompt.yes?("Do you want to run this command now?")
        system(command)
        puts "Rails project '#{project_name}' has been created!"
      else
        puts "Command not executed. You can run it manually when you're ready."
      end
    end

    desc "version", "Display LazyRails version"
    def version
      puts "LazyRails version #{LazyRails::VERSION}"
    end
  end
end
