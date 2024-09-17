require "pry"

RSpec.describe LazyRails::CLI do
  let(:prompt) { TTY::Prompt::Test.new }
  subject(:cli) { described_class.new }

  describe "#version" do
    let(:expected_output) { "LazyRails version #{LazyRails::VERSION}\n" }
    it "outputs the version" do
      expect do
        cli.invoke(:version)
      end.to output(expected_output).to_stdout
    end
  end
end
