module LazyRails
  module PromptGenerators
    describe AskAppName do
      let(:prompt) { FakePrompt.new }

      describe "#call" do
        it do
          described_class.new(prompt).call
          expect(prompt.question).to eq("What is the name of your project?")
        end
      end
    end

    describe SelectAppType do
      let(:prompt) { FakePrompt.new }

      describe "#call" do
        it do
          described_class.new(prompt).call

          expect(prompt.question).to eq("Choose your project type:")
          expect(prompt.options).to match(show_help: :always)
          expect(prompt.choices).to eq(%w[web api])
        end
      end
    end
    describe SelectCss do
      let(:prompt) { FakePrompt.new }

      describe "#call" do
        it do
          described_class.new(prompt).call

          expect(prompt.question).to eq("Choose your CSS processor:")
          expect(prompt.options).to match(show_help: :always)
          expect(prompt.choices).to eq(%w[none tailwind bootstrap bulma postcss sass])
        end
      end
    end
    describe SelectDb do
      let(:prompt) { FakePrompt.new }

      describe "#call" do
        it do
          described_class.new(prompt).call

          expect(prompt.question).to eq("Choose your database:")
          expect(prompt.options).to match(show_help: :always)
          expect(prompt.choices).to include("sqlite3", "mysql", "trilogy", "postgresql")
        end
      end
    end
    describe SelectJs do
      let(:prompt) { FakePrompt.new }

      describe "#call" do
        it do
          described_class.new(prompt).call

          expect(prompt.question).to eq("Choose your JavaScript approach:")
          expect(prompt.options).to match(show_help: :always)
          expect(prompt.choices).to eq(%w[importmap esbuild bun rollup webpack])
        end
      end
    end
    describe SelectTools do
      let(:prompt) { FakePrompt.new }

      describe "#call" do
        it do
          described_class.new(prompt).call

          expect(prompt.question).to eq("SKIP RAILS DEFAULTS:")
          expect(prompt.options).to match(show_help: :always)
          expect(prompt.choices).to eq(%w[jbuilder minitest rubocop brakeman])
        end
      end
    end
  end
end
