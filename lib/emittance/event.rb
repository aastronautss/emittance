class Emittance::Event
  class << self
    # @return [Symbol] the identifier that can be used by the {Emittance::Broker broker} to find event handlers.
    def identifier
      Emittance::Event::EventBuilder.klass_to_identifier self
    end

    # @private
    def event_klass_for(*args)
      Emittance::Event::EventBuilder.objects_to_klass *args
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
