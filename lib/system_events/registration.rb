module SystemEvents
  class Registration
    attr_reader :identifier

    def initialize(identifier, &callback)
      @identifier = identifier.to_sym
      @callback = callback
    end

    def call(timestamp, payload)
      @callback.call @identifier, timestamp, payload
    end
  end
end
