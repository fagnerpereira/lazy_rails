RSpec.describe LazyRails::CommandBuilder do
  context "with no options" do
    it "returns the base command" do
      command = described_class.new("my_app").build

      expect(command).to eq("rails new my_app")
    end
  end

  context "with postgresql database" do
    it "returns the base command with the database option" do
      command = described_class.new("my_app").build do |builder|
        builder.options << "postgresql"
      end

      expect(command).to eq("rails new my_app --database=postgresql")
    end
  end

  context "with bulma css" do
    it "returns the base command with the css option" do
      command = described_class.new("my_app").build do |builder|
        builder.options << "bulma"
      end

      expect(command).to eq("rails new my_app --css=bulma")
    end
  end

  context "with multiple options" do
    it "returns the base command with all the options" do
      command = described_class.new("my_app").build do |builder|
        builder.options << "mysql"
        builder.options << "bun"
        builder.options << "tailwind"
        builder.options << "jbuilder"
      end

      expect(command).to eq("rails new my_app --database=mysql --javascript=bun --css=tailwind --skip-jbuilder")
    end
  end

  context "with options without block" do
    it "returns the base command with all the options" do
      command = described_class.new("my_app")
      command.options << "mysql"
      command.options << "bun"
      command.options << "tailwind"
      command.options << "jbuilder"

      expect(command.build).to eq("rails new my_app --database=mysql --javascript=bun --css=tailwind --skip-jbuilder")
    end
  end
end
