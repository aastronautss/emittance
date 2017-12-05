# frozen_string_literal: true

module Emittance
  ##
  # Synchronously dispatches the event to watchers.
  #
  class Synchronous < Emittance::Broker
    class << self
      # (@see Emittance::Broker.process_event)
      def process_event(event)
        Emittance::Dispatcher.process_event event
      end
    end
  end
end
