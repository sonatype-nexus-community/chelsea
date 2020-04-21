require 'tty-spinner'
require 'pastel'

module Chelsea
  class Spinner
    def initialize()
      @pastel = Pastel.new
    end

    def spin_msg(msg)
      format = "[#{@pastel.green(':spinner')}] " + @pastel.white(msg)
      spinner = TTY::Spinner.new(
        format,
        success_mark: @pastel.green('+'),
        hide_cursor: true
      )
      spinner.auto_spin
      spinner
    end
  end
end
