require_relative 'json'
require_relative 'xml'
require_relative 'text'

# Factory for formatting dependencies
class FormatterFactory
  def get_formatter(format: 'text')
    case format
    when 'text'
      Chelsea::TextFormatter.new
    when 'json'
      Chelsea::JsonFormatter.new
    when 'xml'
      Chelsea::XMLFormatter.new
    else
      Chelsea::TextFormatter.new
    end
  end
end
