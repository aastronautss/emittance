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
    @enabled = true

    def enabled?
      !!@enabled
    end

    def enable
      @enabled = true
    end

    def disable
      @enabled = false
    end
  end
end
