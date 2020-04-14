require_relative 'json'
require_relative 'xml'
require_relative 'text'

# Factory for formatting dependencies
class FormatterFactory
  def get_formatter(format: 'text', quiet: false)
    case format
    when 'text'
      Chelsea::TextFormatter.new quiet: quiet
    when 'json'
      Chelsea::JsonFormatter.new quiet: quiet
    when 'xml'
      Chelsea::XMLFormatter.new quiet: quiet
    else
      Chelsea::TextFormatter.new quiet: quiet
    end
  end
end
