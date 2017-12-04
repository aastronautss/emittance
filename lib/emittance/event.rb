##
# Basic usage of Emittance doesn't require that you fiddle with objects of type +Emittance::Event+
#
class Emittance::Event
  class << self
    # @return [Symbol] the identifier that can be used by the {Emittance::Broker broker} to find event handlers.
    def identifier
      EventBuilder.klass_to_identifier self
    end

    # Gives the Event object a custom identifier.
    # 
    # @param [Symbol] 
    def identifier=(sym)
      EventBuilder.register_custom_identifier self, sym
    end

    # @private
    def event_klass_for(*identifier)
      EventBuilder.objects_to_klass *identifier
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
