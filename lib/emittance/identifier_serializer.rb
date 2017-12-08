# frozen_string_literal: true

module Emittance
  ##
  # Helper methods for identifiers.
  #
  module IdentifierSerializer
    private

    def normalize_identifier(identifier)
      if event_klass?(identifier) || event_object?(identifier)
        identifier.identifier
      else
        coerce_identifier_type identifier
      end
    end

    def event_klass?(identifier)
      identifier.is_a?(Class) && identifier < Emittance::Event
    end

    def event_object?(identifier)
      identifier.is_a? Emittance::Event
    end

    def coerce_identifier_type(identifier)
      identifier.to_sym
    end
  end
end
