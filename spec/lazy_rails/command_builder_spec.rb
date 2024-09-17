RSpec.describe LazyRails::CommandBuilder do
  it do
    command = described_class.new("my_app").build do |builder|
      builder.options << "mysql"
      builder.options << "bun"
      builder.options << "tailwind"
      builder.options << "jbuilder"
    end

    expect(command).to eq("rails new my_app --database=mysql --javascript=bun --css=tailwind --skip-jbuilder")
  end
end
