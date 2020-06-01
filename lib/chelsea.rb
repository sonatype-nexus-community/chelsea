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

# frozen_string_literal: true

# Lazy loading
require_relative 'chelsea/cli'
require_relative 'chelsea/deps'
require_relative 'chelsea/bom'
require_relative 'chelsea/iq_client'
require_relative 'chelsea/oss_index'
require_relative 'chelsea/config'
require_relative 'chelsea/version'
# module Chelsea
#   autoload :CLI,          'chelsea/cli'
#   autoload :Deps,         'chelsea/deps'
#   autoload :Bom,          'chelsea/bom'
#   autoload :IQClient,     'chelsea/iq_client'
#   autoload :OSSIndex,     'chelsea/oss_index'
#   autoload :Config,       'chelsea/config'
#   autoload :Version,      'chelsea/version'
# end
