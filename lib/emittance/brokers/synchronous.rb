# frozen_string_literal: true

module Emittance
  ##
  # Synchronously dispatches the event to watchers.
  #
  class Synchronous < Emittance::Broker
    class << self
      # (@see Emittance::Broker.process_event)
      def process_event(event)
        dispatcher.process_event event
      end
    end
  end
end

require 'emittance/dispatchers/synchronous'

Emittance::Brokerage.register_broker Emittance::Synchronous, :synchronous
