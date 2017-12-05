require 'emittance/version'
require 'emittance/errors'

require 'emittance/brokerage'
require 'emittance/broker'
require 'emittance/registration'
require 'emittance/event'
require 'emittance/event/event_builder'
require 'emittance/emitter'
require 'emittance/watcher'
require 'emittance/action'
require 'emittance/dispatcher'

module Emittance
  class << self
    def enable!
      Emittance::Dispatcher.enable!
    end

    def disable!
      Emittance::Dispatcher.disable!
    end

    def enabled?
      Emittance::Dispatcher.enabled?
    end

    def suppress(&blk)
      Emittance::Dispatcher.suppress(&blk)
    end
  end
end
