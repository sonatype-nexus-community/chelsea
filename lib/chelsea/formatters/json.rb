require 'json'
require_relative 'formatter'

module Chelsea
  class JsonFormatter < Formatter
    def initialize(options)
      @options = options
    end

    def get_results(server_response, reverse_deps)
      server_response.to_json
    end

    def do_print(result)
      puts result
    end
  end
end
