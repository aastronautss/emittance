module SystemEvents
  class Registration
    attr_reader :identifier

    def initialize(identifier, &callback)
      @identifier = identifier.to_sym
      @callback = callback
    end

    def call(timestamp, emitter, payload)
      @callback.call @identifier, timestamp, emitter, payload
    end
  end
end
