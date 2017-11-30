class Emittance::Event
  class << self
    # @return [Symbol] the identifier that can be used by the {Emittance::Broker broker} to find event handlers.
    def identifier
      Emittance::Event::EventBuilder.klass_to_identifier self
    end

    # @private
    def event_klass_for(identifier)
      Emittance::Event::EventBuilder.object_to_klass identifier
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
