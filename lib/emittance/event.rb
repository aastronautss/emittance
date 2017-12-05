# froze_string_literal: true

##
# Basic usage of Emittance doesn't require that you fiddle with objects of type +Emittance::Event+. However, this class
# is open for you to inherit from in the cases where you would like to customize some aspects of the event.
#
# To define a custom event, just inherit from +Emittance::Event+:
#
#   class FooEvent < Emittance::Event
#   end
#
# One common use case for this is to make sure all payloads share the same format. You can do this however you'd like.
# We've provided an +InvalidPayloadError+ class for that purpose. Here's one example of how that might happen:
#
#   class FooEvent < Emittance::Event
#     def initialize(emitter, timestamp, payload)
#       super
#       validate_payload
#     end
#
#     private
#
#     def validate_payload
#       raise Emittance::InvalidPayloadError unless payload.is_a?(String)
#     end
#   end
#
# == Custom Identifiers
#
# By default, the identifier for this event will be the snake_case form of the class name with +Event+ chopped off:
#
#   FooEvent.identifier # => :foo
#
# You can set a custom identifier for the event class like so:
#
#   FooEvent.add_identifier :bar
#
# Now, when emitters emit +:bar+, this will be the event received by watchers.
#
class Emittance::Event
  class << self
    # @return [Symbol] the identifier that can be used by the {Emittance::Broker broker} to find event handlers
    def identifier
      EventBuilder.klass_to_identifier self
    end

    # Gives the Event object a custom identifier.
    #
    # @param [Symbol] the identifier you wish to identify this event by when emitting and watching for it
    def add_identifier(sym)
      EventBuilder.register_custom_identifier self, sym
    end

    # @private
    def event_klass_for(*identifiers)
      EventBuilder.objects_to_klass *identifiers
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
