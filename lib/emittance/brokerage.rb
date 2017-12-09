# frozen_string_literal: true

module Emittance
  ##
  # The clearinghouse for brokers. Registers brokers, and decides which broker to use when sent an event. First point of
  # contact for event propagation.
  #
  class Brokerage
    @enabled = true

    class << self
      # @param event [Emittance::Event] the event object
      # @param broker_id [Symbol] a symbol that can be used to identify a broker by
      def send_event(event, broker_id)
        broker = registry.fetch(broker_id)
        broker.process_event event
      end

      # @param broker [Emittance::Broker] the broker you would like to register
      def register_broker(broker)
        registry.register broker
      end

      def registry
        Emittance::Brokerage::Registry
      end

      def enable!
        @enabled = true
      end

      def disable!
        @enabled = false
      end

      def enabled?
        @enabled
      end

      private

      attr_accessor :enabled
    end

    # @private
    module Registry
      @brokers = {}

      class << self
        include Emittance::Helpers::StringHelpers

        attr_reader :brokers

        def register(broker)
          broker_sym = generate_broker_sym(broker)
          brokers[broker_sym] = broker
        end

        def fetch(broker_id)
          brokers[broker_id.to_sym]
        end

        private

        def generate_broker_sym(broker)
          camel_case = broker.name.split('::').last
          snake_case(camel_case).to_sym
        end
      end
    end
  end
end
