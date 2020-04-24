class Formatter
  attr_reader :results
  def initialize(quiet: false, server_response:, reverse_dependencies:)
    @quiet = quiet
    @pastel = Pastel.new
    @results = parse_results(server_response, reverse_dependencies)
  end

  def parse_results
    raise 'must implement get_results method in subclass'
  end

  def print
    raise 'must implement do_print method in subclass'
  end
end