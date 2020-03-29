require 'json'
require 'rest-client'
require 'pstore'
require_relative 'version'
require_relative 'oss_index_exception'

module Chelsea
  class OssIndex
    def initialize(options)
      @db_file_name = options[:db_file_name] == nil ? 'chelsea.pstore' : options[:db_file_name]
      @store = PStore.new(get_db_store_location())
    end

    # Goes through the keys in the db cache, and truncates them.
    def clear_db_cache()
      @store.transaction do
        @store.roots.each do |root|
          @store.delete(root)
        end
      end
    end

    # Responsible for communicating with OSS Index, as well as retrieving values from the database cache.
    # Accepts a hash of coordinates, with key "coordinates", and returns a server_response of all responses 
    # from OSS Index
    def query_ossindex_for_vulns(coordinates)
      server_response = Array.new()

      server_response = get_cached_server_response(coordinates["coordinates"])

      coordinates = get_new_coordinate_list_after_checking_cache(coordinates)

      if coordinates["coordinates"].count() > 0
        chunked = Hash.new()
        coordinates["coordinates"].each_slice(128).to_a.each do |coords|
          chunked["coordinates"] = coords
          r = RestClient.post "https://ossindex.sonatype.org/api/v3/component-report", chunked.to_json, 
          {content_type: :json, accept: :json, 'User-Agent': get_user_agent()}
        
          if r.code == 200
            server_response = server_response.concat(JSON.parse(r.body))
            save_values_to_db(JSON.parse(r.body))
            return server_response
          else
            raise Chelsea::OssIndexException.new "Error getting data from OSS Index server. Server returned non-success code #{r.code}.", "ErrorCommunicating"
          end
        end
      else
        return server_response
      end

      rescue SocketError => e
        raise Chelsea::OssIndexException.new "Socket error getting data from OSS Index server.", "SocketError" 
      rescue RestClient::RequestFailed => e
        raise Chelsea::OssIndexException.new "Error getting data from OSS Index server:#{e.response}.", "RequestFailed"
      rescue RestClient::ResourceNotFound => e
        raise Chelsea::OssIndexException.new "Error getting data from OSS Index server. Resource not found.", "ResourceNotfound"
      rescue Errno::ECONNREFUSED => e
        raise Chelsea::OssIndexException.new "Error getting data from OSS Index server. Connection refused.", "ECONNREFUSED"
      rescue StandardError => e
        raise Chelsea::OssIndexException.new "UNKNOWN Error getting data from OSS Index server.", "StandardError"
    end

    private

    # Goes through the list of @coordinates and checks pstore for them, if it finds a valid coord
    # it will add it to the server response. If it does not, it will append the coord to a new hash
    # and eventually set coordinates to the new hash, so we query OSS Index on only coords not in cache
    def get_new_coordinate_list_after_checking_cache(coordinates)
      new_coords = Hash.new
      new_coords["coordinates"] = Array.new
      coordinates["coordinates"].each do |coord|
        record = get_cached_value_from_db(coord)
        if record.nil?
          new_coords["coordinates"].push(coord)
        end
      end

      return new_coords
    end

    # This method will take an array of values, and save them to a pstore database
    # and as well set a TTL of Time.now to be checked later
    def save_values_to_db(values)
      values.each do |val|
        if get_cached_value_from_db(val["coordinates"]).nil?
          new_val = val.dup
          new_val["ttl"] = Time.now
          @store.transaction do 
            @store[new_val["coordinates"]] = new_val
          end 
        end
      end
    end

    # Goes through an Array of coordinates, checks to see if value is in cache, and starts populating
    # a server response for coordinates we already know about
    def get_cached_server_response(coordinates)
      response = Array.new
      coordinates.each do |coord|
        record = get_cached_value_from_db(coord)
        if !record.nil?
          response << record
        end
      end

      return response
    end

    # Checks pstore to see if a coordinate exists, and if it does also
    # checks to see if it's ttl has expired. Returns nil unless a record
    # is valid in the cache (ttl has not expired) and found
    def get_cached_value_from_db(coordinate)
      record = @store.transaction { @store[coordinate] }
      if !record.nil?
        diff = (Time.now - record['ttl']) / 3600
        if diff > 12
          return nil
        else
          return record
        end
      else
        return nil
      end
    end

    def get_db_store_location()
      initial_path = File.join("#{Dir.home}", ".ossindex")
      Dir.mkdir(initial_path) unless File.exists? initial_path
      return File.join(initial_path, @db_file_name)
    end

    def get_user_agent()
      return "chelsea/#{Chelsea::VERSION}"
    end
  end
end
