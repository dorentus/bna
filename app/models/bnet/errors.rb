module Bnet

  class RequestFailedError < StandardError
    attr_reader :error

    def self.new(msg = nil, error = nil)
      @error = error
      super(msg)
    end
  end

  class BadInputError < StandardError; end

end
