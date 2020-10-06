# frozen_string_literal: true

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
module Chelsea
  # Class to colect Coordinate data
  class OICoord
    attr_reader :vulnerable

    def initialize(opts)
      @name, @version = opts['coordinates'].sub('pkg:gem/', '').split('@')
      @vulnerable = opts['vulnerabilities'].length.positive?
      @coordinates = opts['coordinates']
      @description = opts['description']
      @reference = opts['reference']
      @vulnerabilities = opts['vulnerabilities']
    end

    def to_h
      {
        name: @name, version: @version,
        vulnerable: @vulnerable, coordinates: @coordinates,
        description: @description, reference: @reference,
        vulnerabilities: @vulnerabilities
      }
    end
  end
end
