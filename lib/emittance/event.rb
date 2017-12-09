# frozen_string_literal: true

module Emittance
  ##
  # Basic usage of Emittance doesn't require that you fiddle with objects of type +Emittance::Event+. However, this
  # class is open for you to inherit from in the cases where you would like to customize some aspects of the event.
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
  #   FooEvent.identifiers # => [:foo]
  #
  # You can set a custom identifier for the event class like so:
  #
  #   FooEvent.add_identifier :bar
  #
  # Now, when emitters emit +:bar+, this will be the event received by watchers.
  #
  class Event
    class << self
      # @return [Array<Symbol>] the identifier that can be used by the {Emittance::Broker broker} to find event handlers
      def identifiers
        EventLookup.identifiers_for_klass(self).to_a
      end

      # Gives the Event object a custom identifier.
      #
      # @param sym [Symbol] the identifier you wish to identify this event by when emitting and watching for it
      def add_identifier(sym)
        raise Emittance::InvalidIdentifierError, 'Identifiers must respond to #to_sym' unless sym.respond_to?(:to_sym)
        EventLookup.register_identifier self, sym.to_sym
      end

      # @param identifiers [*] anything that can be derived into an identifier (or the event class itself) for the
      #   purposes of looking up an event class.
      def event_klass_for(*identifiers)
        EventLookup.find_event_klass(*identifiers)
      end
    end

    attr_reader :emitter, :timestamp, :payload

    # @param emitter the object that emitted the event
    # @param timestamp [Time] the time at which the event occurred
    # @param payload any useful data that might be of use to event watchers
    def initialize(emitter, timestamp, payload)
      @emitter = emitter
      @timestamp = timestamp
      @payload = payload
    end

    # @return [Array<Symbol>] all identifiers that can be used to identify the event
    def identifiers
      self.class.identifiers
    end
  end
end
