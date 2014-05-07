module Bnet

  class RequestFailedError < StandardError
    def self.new(msg = nil, error = nil)
      @error = error
      super(msg)
    end
  end

  class BadInputError < StandardError; end

end
