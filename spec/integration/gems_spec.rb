RSpec.describe "`auditrb gems` command", type: :cli do
  it "executes `auditrb help gems` command successfully" do
    output = `auditrb help gems`
    expected_output = <<-OUT
Usage:
  auditrb gems FILE

Options:
  -h, [--help], [--no-help]  # Display usage information

Audit dependencies specified in a .gemspec file.
    OUT

    expect(output).to eq(expected_output)
  end
end
