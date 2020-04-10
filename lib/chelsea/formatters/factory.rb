require_relative 'json'
require_relative 'xml'
require_relative 'text'

class FormatterFactory
    def get_formatter(format: 'text')
        case format
        when 'text'
          Chelsea::TextFormatter.new()
        when 'json'
          Chelsea::JsonFormatter.new()
        when 'xml'
          Chelsea::XMLFormatter.new()
        end
  end
end