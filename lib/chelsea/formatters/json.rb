require 'json'

module Chelsea
  class JsonFormatter
    def initialize(options)
      @options = options
    end

    def print_results(server_response, reverse_deps)
      puts JSON.pretty_generate(server_response)
    end

  end
end
