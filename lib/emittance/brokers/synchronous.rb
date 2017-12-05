# frozen_string_literal: true

##
# Synchronously dispatches the event to watchers.
#
module Emittance
  class Synchronous < Emittance::Broker
    class << self
      # (@see Emittance::Broker.process_event)
      def process_event(event)
        Emittance::Dispatcher.process_event event
      end
    end
  end
end
