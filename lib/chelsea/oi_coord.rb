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
