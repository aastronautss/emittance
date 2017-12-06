# frozen_string_literal: true

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

##
# The base namespace for this library. You can do some basic configuration stuff by calling methods on its singleton.
#
module Emittance
  class << self
    # Enable eventing process-wide.
    def enable!
      Emittance::Dispatcher.enable!
    end

    # Disable eventing process-wide.
    def disable!
      Emittance::Dispatcher.disable!
    end

    # @return [Boolean] true if eventing is enabled, false otherwise.
    def enabled?
      Emittance::Dispatcher.enabled?
    end

    # :nocov:
    # @private
    def suppress(&blk)
      Emittance::Dispatcher.suppress(&blk)
    end
    # :nocov:
  end
end
