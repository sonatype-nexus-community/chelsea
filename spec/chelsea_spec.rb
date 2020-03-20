require "bundler/setup"
require "chelsea"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.describe Chelsea do
  it "has a version number" do
    expect(Chelsea::CLI.new.version).not_to be nil
  end
end
