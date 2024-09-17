module LazyRails
  module PromptGenerators
    class Base
      attr_reader :prompt

      def initialize(prompt)
        @prompt = prompt
      end
    end

    class SelectAppType < Base
      def call
        prompt.select(
          "Choose your project type:",
          %w[web api],
          show_help: :always
        )
      end
    end

    class SelectDb < Base
      def call
        prompt.select("Choose your database:", show_help: :always) do |menu|
          menu.choice "SQLite(default)", "sqlite3"
          menu.choice "MySQL", "mysql"
          menu.choice "Trilogy", "trilogy"
          menu.choice "PostgreSQL", "postgresql"
        end
      end
    end

    class SelectJs < Base
      def call
        prompt.select(
          "Choose your JavaScript approach:",
          %w[importmap esbuild bun rollup webpack],
          show_help: :always
        )
      end
    end

    class SelectCss < Base
      def call
        prompt.select(
          "Choose your CSS processor:",
          %w[none tailwind bootstrap bulma postcss sass],
          show_help: :always
        )
      end
    end

    class AskAppName < Base
      def call
        prompt.ask("What is the name of your project?") do |q|
          q.default "rails-app-#{Time.now.to_i}"
          q.required true
          q.validate(/\A[\w-]+\z/)
          q.messages[:valid?] = "Project name can only contain letters, numbers, underscores, and dashes"
        end
      end
    end

    class SelectTools < Base
      def call
        prompt.multi_select("SKIP RAILS DEFAULTS:", show_help: :always) do |menu|
          menu.choice "jbuilder"
          menu.choice "minitest"
          menu.choice "rubocop"
          menu.choice "brakeman"
        end
      end
    end
  end
end
