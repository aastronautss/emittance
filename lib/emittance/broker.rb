# frozen_string_literal: true

module Emittance
  ##
  # Base class for event brokers.
  #
  class Broker
    DISPATCHER_KLASS_NAME = 'Dispatcher'

    class << self
      # @param _event [Emittance::Event] the event to be passed off to watchers
      def process_event(_event)
        raise NotImplementedError
      end

      def dispatcher
        self.const_get DISPATCHER_KLASS_NAME
      end

      def inherited(subklass)
        register_broker subklass
        super
      end

      def register_broker(broker)
        Emittance::Brokerage.register_broker broker
      end
    end
  end
end

require 'emittance/brokers/synchronous'
