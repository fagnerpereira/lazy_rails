require "thor"
require "tty-prompt"

# TODO: add a way to select rails version
module LazyRails
  class CLI < Thor
    RAILS_NEW_COMMAND = ["rails new"]
    APP_TYPES = {
      "api" => "--api"
    }
    DB_OPTIONS = {
      "mysql" => "--database=mysql",
      "postgresql" => "--database=postgresql",
      "trilogy" => "--database=trilogy"
    }
    JS_OPTIONS = {
      "esbuild" => "--javascript=esbuild",
      "bun" => "--javascript=bun",
      "rollup" => "--javascript=rollup",
      "webpack" => "--javascript=webpack"
    }
    CSS_OPTIONS = {
      "tailwind" => "--css=tailwind",
      "bootstrap" => "--css=bootstrap",
      "bulma" => "--css=bulma",
      "postcss" => "--css=postcss",
      "sass" => "--css=sass"
    }
    SKIP_OPTIONS = {
      "jbuilder" => "--skip-jbuilder",
      "minitest" => "--skip-test",
      "rubocop" => "--skip-rubocop",
      "brakeman" => "--skip-brakeman"
    }

    desc "new", "Start new rails project"
    def new
      prompt = TTY::Prompt.new

      puts "Welcome to the Rails Project Setup Wizard!"

      # Project name
      project_name = prompt.ask("What is the name of your project?") do |q|
        q.default "rails-app-#{Time.now.strftime("%Y%m%d%H%M%S")}"
        q.required true
        q.validate(/\A[\w-]+\z/)
        q.messages[:valid?] = "Project name can only contain letters, numbers, underscores, and dashes"
      end

      # Database selection
      db_option = prompt.select("Choose your database:", show_help: :always) do |menu|
        menu.choice "SQLite(default)", "sqlite3"
        menu.choice "MySQL", "mysql"
        menu.choice "Trilogy", "trilogy"
        menu.choice "PostgreSQL", "postgresql"
      end

      # Project type
      project_type = prompt.select("Choose your project type:", %w[web api], show_help: :always)

      unless project_type == "api"
        # JavaScript approach
        js_option = prompt.select("Choose your JavaScript approach:", %w[importmap esbuild bun rollup webpack], show_help: :always)

        # CSS processor
        css_option = prompt.select("Choose your CSS processor:", %w[none tailwind bootstrap bulma postcss sass], show_help: :always)
      end

      # Skip rails setup defaults
      rails_setup_defaults = prompt.multi_select("SKIP RAILS DEFAULTS:", show_help: :always) do |menu|
        menu.choice "jbuilder"
        menu.choice "minitest"
        menu.choice "rubocop"
        menu.choice "brakeman"
      end

      RAILS_NEW_COMMAND << project_name
      RAILS_NEW_COMMAND << DB_OPTIONS[db_option] if db_option
      RAILS_NEW_COMMAND << APP_TYPES[project_type] if project_type
      RAILS_NEW_COMMAND << JS_OPTIONS[js_option] if js_option
      RAILS_NEW_COMMAND << CSS_OPTIONS[css_option] if css_option

      rails_setup_defaults.each do |tool|
        RAILS_NEW_COMMAND << SKIP_OPTIONS[tool]
      end

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

    desc "version", "Display LazyRails version"
    def version
      puts "LazyRails version #{LazyRails::VERSION}"
    end
  end
end
