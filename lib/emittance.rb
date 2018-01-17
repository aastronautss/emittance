# frozen_string_literal: true

require 'emittance/version'
require 'emittance/errors'

require 'emittance/helpers/string_helpers'
require 'emittance/helpers/constant_helpers'
require 'emittance/event_lookup'
require 'emittance/dispatcher'
require 'emittance/brokerage'
require 'emittance/broker'
require 'emittance/event'
require 'emittance/emitter'
require 'emittance/watcher'
require 'emittance/notifier'
require 'emittance/action'

##
# The base namespace for this library. You can do some basic configuration stuff by calling methods on its singleton.
#
module Emittance
  class << self
    # Enable eventing process-wide
    def enable!
      Emittance::Brokerage.enable!
    end

    # Disable eventing process-wide
    def disable!
      Emittance::Brokerage.disable!
    end

    # @return [Boolean] true if eventing is enabled, false otherwise
    def enabled?
      Emittance::Brokerage.enabled?
    end

    # @return [Class] the currently enabled broker class
    def broker
      Emittance::Brokerage.broker
    end

    # @return [Class] the dispatcher attached to the currently enabled broker
    def dispatcher
      broker.dispatcher
    end

    # @param [identifier] the identifier that can be used to identify the broker you wish to use
    def use_broker(identifier)
      Emittance::Brokerage.use_broker identifier
    end

    # Not yet implemented! Remove nocov and private flags when finished.
    # :nocov:
    # @private
    def suppress(&_blk)
      raise NotImplementedError, "This isn't working yet!"
      # Emittance::Dispatcher.suppress(&blk)
    end
    # :nocov:
  end
end

Emittance.use_broker :synchronous
