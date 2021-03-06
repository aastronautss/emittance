# frozen_string_literal: true

module Emittance
  # Raised when an identifier (for the purposes of identifying an event class) cannot be parsed, or an event class
  # can otherwise not be found or generated.
  class InvalidIdentifierError < StandardError; end

  # Raised when an identifier couldn't be generated from a class. Typically a validation error.
  class IdentifierGenerationError < StandardError; end

  # Raised when an identifier registration is attempted, but there exists an event registered to the given identifiered.
  class IdentifierCollisionError < StandardError; end

  # Used when a custom event type undergoes payload validation.
  class InvalidPayloadError < StandardError; end
end
