require_relative 'json'
require_relative 'xml'
require_relative 'text'

# Factory for formatting dependencies
class FormatterFactory
  def get_formatter(format: 'text', **opts)
    case format
    when 'text'
      Chelsea::TextFormatter.new opts
    when 'json'
      Chelsea::JsonFormatter.new opts
    when 'xml'
      Chelsea::XMLFormatter.new opts
    else
      Chelsea::TextFormatter.new opts
    end
  end
end
