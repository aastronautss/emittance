##
# Base class for event brokers.
#
class Emittance::Broker
  class << self
    # @param event [Emittance::Event] the event to be passed off to watchers
    def process_event(event)
      raise NotImplementedError
    end

    def inherited(subklass)
      register_broker subklass
      super
    end

    private

    def register_broker(broker)
      Emittance::Brokerage.register_broker broker
    end
  end
end

require 'emittance/brokers/synchronous'
