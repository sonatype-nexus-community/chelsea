require 'auditrb/commands/gems'

RSpec.describe Auditrb::Commands::Gems do
  it "executes `gems` command successfully" do
    output = StringIO.new
    file = nil
    options = {}
    command = Auditrb::Commands::Gems.new(file, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
