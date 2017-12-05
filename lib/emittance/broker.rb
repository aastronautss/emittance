# frozen_string_literal: true

module Emittance
  ##
  # Base class for event brokers.
  #
  class Broker
    class << self
      # @param _event [Emittance::Event] the event to be passed off to watchers
      def process_event(_event)
        raise NotImplementedError
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
