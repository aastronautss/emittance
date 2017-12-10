# frozen_string_literal: true

module Emittance
  # @private
  class Registration
    attr_reader :event_klass

    def initialize(event_klass, &callback)
      @event_klass = event_klass
      @callback = callback
    end

    def call(event)
      @callback.call event
    end
  end
end
