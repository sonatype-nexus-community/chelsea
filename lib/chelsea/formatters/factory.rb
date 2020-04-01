require_relative 'json'
require_relative 'xml'
require_relative 'text'

class FormatterFactory
    def get_formatter(format: 'text', options: {})
        case format
        when 'text'
          Chelsea::TextFormatter.new(options)
        when 'json'
          Chelsea::JsonFormatter.new(options)
        when 'xml'
          Chelsea::XMLFormatter.new(options)
        end
  end
end