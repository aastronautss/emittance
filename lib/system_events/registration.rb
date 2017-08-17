module SystemEvents
  class Registration
    attr_reader :identifier

    def initialize(identifier, &callback)
      @identifier = identifier
      @callback = callback
    end

    def call(timestamp, object, payload)
      @callback.call @identifier, timestamp, object, payload
    end
  end
end
