# frozen_string_literal: true

module Emittance
  ##
  # The clearinghouse for brokers. Registers brokers, and decides which broker to use when sent an event. First point of
  # contact for event propagation.
  #
  class Brokerage
    @enabled = true
    @current_broker = nil

    class << self
      # @param event [Emittance::Event] the event object
      # @param broker_id [Symbol] a symbol that can be used to identify a broker by
      def send_event(event)
        broker.process_event event
      end

      # @return [Class] the currently selected broker
      def broker
        @current_broker
      end

      # @param identifier [Symbol] the symbol you have registered the broker to
      def use_broker(identifier)
        @current_broker = registry.fetch identifier
      end

      # @param broker [Emittance::Broker] the broker you would like to register
      def register_broker(broker, symbol)
        registry.register broker, symbol
      end

      # @return [Module] the registry containing all broker registrations
      def registry
        Emittance::Brokerage::Registry
      end

      # Enables event propagation.
      def enable!
        self.enabled = true
      end

      # Disables event propagation.
      def disable!
        self.enabled = false
      end

      # @return [Boolean] true if event propagation is enabled, false otherwise
      def enabled?
        enabled
      end

      private

      attr_accessor :enabled
    end

    # @private
    module Registry
      @brokers = {}

      class << self
        attr_reader :brokers

        def register(broker, symbol)
          brokers[symbol.to_sym] = broker
        end

        def fetch(broker_id)
          brokers[broker_id.to_sym]
        end
      end
    end
  end
end
