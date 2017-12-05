# froze_string_literal: true

# @private
module Emittance
  class Registration
    attr_reader :identifier

    def initialize(identifier, &callback)
      @identifier = identifier
      @callback = callback
    end

    def call(event)
      @callback.call event
    end
  end
end
