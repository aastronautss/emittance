# frozen_string_literal: true

require 'emittance/event_validator'

module Emittance
  class Middleware
    ##
    # Enables event payload validation for a given event, based on the parameters set by an {Emittance::EventValidator}.
    # Event payloads are often passed in the form of a hash (or JSON object). This middleware ensures that these
    # payloads contain the correct structure for a given schema.
    #
    class EventValidation < Emittance::Middleware
      class << self
        attr_accessor :invalidation_strategy
      end

      def up
        invalid! unless Emittance.event_validator.valid_for_event?(event)

        event
      end

      private

      def invalid!
        message = "Invalid paylod for event emitted by #{event.emitter} " \
          "(identifiers: #{event.identifiers.split(', ')})"

        raise InvalidPayloadError, message unless invalidation_strategy == :warn

        warn "[ Emittance ] #{message}"
      end

      def invalidation_strategy
        self.class.invalidation_strategy
      end
    end
  end
end
