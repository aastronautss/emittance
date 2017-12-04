require 'emittance/version'
require 'emittance/errors'

require 'emittance/registration'
require 'emittance/event'
require 'emittance/event/event_builder'
require 'emittance/emitter'
require 'emittance/watcher'
require 'emittance/action'
require 'emittance/broker'

module Emittance
  class << self
    def enable!
      Emittance::Broker.enable!
    end

    def disable!
      Emittance::Broker.disable!
    end

    def enabled?
      Emittance::Broker.enabled?
    end

    def suppress(&blk)
      Emittance::Broker.suppress &blk
    end
  end
end
