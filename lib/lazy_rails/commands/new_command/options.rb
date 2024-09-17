module NewCommand
  OPTIONS = {
    "api" => "--api",
    "mysql" => "--database=mysql",
    "postgresql" => "--database=postgresql",
    "trilogy" => "--database=trilogy",
    "esbuild" => "--javascript=esbuild",
    "bun" => "--javascript=bun",
    "rollup" => "--javascript=rollup",
    "webpack" => "--javascript=webpack",
    "tailwind" => "--css=tailwind",
    "bootstrap" => "--css=bootstrap",
    "bulma" => "--css=bulma",
    "postcss" => "--css=postcss",
    "sass" => "--css=sass",
    "jbuilder" => "--skip-jbuilder",
    "minitest" => "--skip-test",
    "rubocop" => "--skip-rubocop",
    "brakeman" => "--skip-brakeman"
  }
end
