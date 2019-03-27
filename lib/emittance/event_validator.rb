# frozen_string_literal: true

require 'emittance/event_validator/registration'

module Emittance
  ##
  # An object that validates events against a given set criteria for an event's identifier.
  #
  class EventValidator
    class << self
      def schema_builder
        Registration.schema_builder
      end

      def schema_builder=(new_schema_builder)
        Registration.schema_builder = new_schema_builder
      end
    end

    attr_reader :validation_map

    def initialize(validation_map = Emittance.registration_router_klass.new)
      @validation_map = validation_map
    end

    def register(identifier, schema = nil, &blk)
      registration = new_registration(schema, &blk)

      validation_map.register(identifier, registration)
    end

    def valid_for_event?(event)
      event.identifiers.all? { |identifier| valid_for_identifier?(identifier, event) }
    end

    private

    def valid_for_identifier?(identifier, event)
      registrations_for_identifier(identifier).all? { |registration| registration.valid_for_event?(event) }
    end

    def registrations_for_identifier(identifier)
      validation_map[identifier]
    end

    def new_registration(*args, &blk)
      Registration.new(*args, &blk)
    end
  end
end

# rubocop:disable Style/Documentation
module Emittance
  class << self
    attr_writer :event_validator

    def event_validator
      @event_validator ||= Emittance::EventValidator.new
    end

    def validate_events_for_identifier(identifier, schema = nil, &blk)
      event_validator.register(identifier, schema, &blk)
    end
  end
end
# rubocop:enable Style/Documentation
