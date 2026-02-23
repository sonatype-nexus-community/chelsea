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

require 'json'
require 'fileutils'

module Chelsea
  # OSS Index data cache
  # SECURITY: Uses JSON file cache instead of PStore/Marshal to prevent
  # deserialization attacks (CVE pending - CWE-502)
  class DB
    CACHE_TTL_HOURS = 12

    def initialize
      @cache_file = _get_db_store_location
      _ensure_cache_directory_exists
    end

    # This method will take an array of values, and save them to the cache
    # and as well set a TTL of Time.now to be checked later
    def save_values_to_db(values)
      cache = _load_cache
      values.each do |val|
        next unless get_cached_value_from_db(val['coordinates']).nil?

        new_val = val.dup
        new_val['ttl'] = Time.now.to_i
        cache[new_val['coordinates']] = new_val
      end
      _save_cache(cache)
    end

    # This method will delete all values in the cache
    def clear_cache
      File.delete(@cache_file) if File.exist?(@cache_file)
    end

    def _get_db_store_location
      initial_path = File.join(Dir.home.to_s, '.ossindex')
      File.join(initial_path, 'chelsea-cache.json')
    end

    # Checks cache to see if a coordinate exists, and if it does also
    # checks to see if its ttl has expired. Returns nil unless a record
    # is valid in the cache (ttl has not expired) and found
    def get_cached_value_from_db(val)
      cache = _load_cache
      record = cache[val]
      return if record.nil?

      ttl = record['ttl']
      return if ttl.nil?

      # Check if TTL has expired (12 hours)
      (Time.now.to_i - ttl) / 3600 > CACHE_TTL_HOURS ? nil : record
    end

    private

    def _ensure_cache_directory_exists
      cache_dir = File.dirname(@cache_file)
      unless File.exist?(cache_dir)
        FileUtils.mkdir_p(cache_dir)
        # Set restrictive permissions on directory (owner only)
        File.chmod(0o700, cache_dir)
      end
    end

    def _load_cache
      return {} unless File.exist?(@cache_file)

      begin
        JSON.parse(File.read(@cache_file))
      rescue JSON::ParserError
        # If cache is corrupted, start fresh
        {}
      end
    end

    def _save_cache(cache)
      # Write with restrictive permissions (owner read/write only)
      File.open(@cache_file, 'w', 0o600) do |f|
        f.write(JSON.pretty_generate(cache))
      end
      # Ensure permissions are set even if file existed
      File.chmod(0o600, @cache_file)
    end
  end
end
