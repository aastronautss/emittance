# frozen_string_literal: true

##
# The clearinghouse for brokers. Registers brokers, and decides which broker to use when sent an event. First point of
# contact for event propagation.
#
module Emittance
  class Brokerage
    class << self
      def send_event(event, broker_id)
        broker = registry.fetch(broker_id)
        broker.process_event event
      end

      def register_broker(broker)
        registry.register broker
      end

      def registry
        Emittance::Brokerage::Registry
      end
    end

    # @private
    module Registry
      @brokers = {}

      class << self
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

        def snake_case(str)
          str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
        end
      end
    end
  end
end
