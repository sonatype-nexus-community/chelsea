require 'json'
require_relative 'formatter'

module Chelsea
  class JsonFormatter < Formatter
    def parse_results(server_response, reverse_deps: [])
      server_response.to_json
    end

    def print
      puts @results
    end
  end
end
