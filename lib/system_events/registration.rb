module SystemEvents
  class Registration
    attr_reader :identifier

    def initialize(identifier, &block)
      @identifier = identifier
      @callback = block
    end

    def call(timestamp, object, payload)
      @callback.call @identifier, timestamp, object, payload
    end
  end
end
