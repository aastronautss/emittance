class SystemEvents::Event
  class << self
    # @return [Symbol] the identifier that can be used by the {SystemEvents::Broker broker} to find event handlers.
    def identifier
      SystemEvents::Event::EventBuilder.klass_to_identifier self
    end

    # @private
    def event_klass_for(*args)
      SystemEvents::Event::EventBuilder.objects_to_klass *args
    end
  end

  attr_reader :emitter, :timestamp, :payload

  def initialize(emitter, timestamp, payload)
    @emitter = emitter
    @timestamp = timestamp
    @payload = payload
  end

  def identifier
    self.class.identifier
  end
end
