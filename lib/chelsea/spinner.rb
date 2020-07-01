#
# Copyright 2019-Present Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'tty-spinner'
require 'pastel'

module Chelsea
  # Class to manage paste spinner
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
