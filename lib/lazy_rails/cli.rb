require "thor"
require "tty-prompt"

module CommandGenerators
  autoload :Options, "lazy_rails/command_generators/options"
end

module LazyRails
  class CLI < Thor
    RAILS_NEW_COMMAND = ["rails new"]

    desc "new", "Start new rails project"
    def new
      puts "Welcome to the Rails Project Setup Wizard!"

      RAILS_NEW_COMMAND << PromptGenerators::AppName.new(prompt).call
      RAILS_NEW_COMMAND << DB_OPTIONS[PromptGenerators::DbName.new(prompt).call]

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

    private

    def prompt
      @_prompt ||= TTY::Prompt.new
    end
  end
end
