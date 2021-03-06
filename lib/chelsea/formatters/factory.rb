# frozen_string_literal: true

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

require_relative 'json'
require_relative 'xml'
require_relative 'text'

# Factory for formatting dependencies
class FormatterFactory
  def get_formatter(verbose:, format: 'text')
    case format
    when 'text'
      Chelsea::TextFormatter.new verbose: verbose
    when 'json'
      Chelsea::JsonFormatter.new verbose: verbose
    when 'xml'
      Chelsea::XMLFormatter.new verbose: verbose
    else # rubocop:disable Lint/DuplicateBranch
      Chelsea::TextFormatter.new verbose: verbose
    end
  end
end
