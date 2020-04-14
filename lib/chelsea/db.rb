require 'pstore'

module Chelsea
  class DB
    def initialize
      @store = PStore.new(_get_db_store_location)
    end

    # This method will take an array of values, and save them to a pstore database
    # and as well set a TTL of Time.now to be checked later
    def save_values_to_db(values)
      values.each do |val|
        next unless _get_cached_value_from_db(val['coordinates']).nil?

        new_val = val.dup
        new_val['ttl'] = Time.now
        @store.transaction do
          @store[new_val['coordinates']] = new_val
        end
      end
    end

    def _get_db_store_location()
      initial_path = File.join(Dir.home.to_s, '.ossindex')
      Dir.mkdir(initial_path) unless File.exist? initial_path
      File.join(initial_path, 'chelsea.pstore')
    end

    # Checks pstore to see if a coordinate exists, and if it does also
    # checks to see if it's ttl has expired. Returns nil unless a record
    # is valid in the cache (ttl has not expired) and found
    def _get_cached_value_from_db(coordinate)
      record = @store.transaction { @store[coordinate] }
      return if record.nil?

      (Time.now - record['ttl']) / 3600 > 12 ? nil : record
    end

    # Goes through the list of @coordinates and checks pstore for them, if it finds a valid coord
    # it will add it to the server response. If it does not, it will append the coord to a new hash
    # and eventually set @coordinates to the new hash, so we query OSS Index on only coords not in cache
    def check_db_for_cached_values(coordinates)
      new_coords = {}
      new_coords['coordinates'] = []
      server_response = []
      coordinates['coordinates'].each do |coord|
        record = _get_cached_value_from_db(coord)
        if !record.nil?
          server_response << record
        else
          new_coords['coordinates'].push(coord)
        end
      end
      [new_coords, server_response]
    end
  end
end
