module Chelsea
  class DependencyException < StandardError
    def initialize(msg="This is a custom exception", exception_type="custom")
      @exception_type = exception_type
      super(msg)
    end
  end
end
