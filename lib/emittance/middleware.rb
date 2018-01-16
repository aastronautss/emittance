# frozen_string_literal: true

module Emittance
  ##
  # Module for managing middlewares.
  #
  class Middleware
    @registered_middlewares = []

    class << self
      attr_reader :registered_middlewares

      # @param middleware [Class] the middleware you wish to register.
      # @return [Array] the updated list of registered middlewares.
      def register(middleware)
        registered_middlewares << middleware
      end

      def clear_registrations!
        registered_middlewares.clear
      end

      def up(input_event)
        registered_middlewares.reduce(input_event) { |event, klass| klass.new(event).up }
      end

      def down(input_event)
        registered_middlewares.reduce(input_event) { |event, klass| klass.new(event).down }
      end
    end

    attr_reader :event

    def initialize(event)
      @event = event
    end

    def up
      event
    end

    def down
      event
    end
  end
end
