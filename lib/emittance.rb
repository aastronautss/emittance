# frozen_string_literal: true

require 'emittance/version'
require 'emittance/errors'

require 'emittance/helpers/string_helpers'
require 'emittance/helpers/constant_helpers'
require 'emittance/event_lookup'
require 'emittance/brokerage'
require 'emittance/broker'
require 'emittance/registration'
require 'emittance/event'
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
      Emittance::Brokerage.enable!
    end

    # Disable eventing process-wide.
    def disable!
      Emittance::Brokerage.disable!
    end

    # @return [Boolean] true if eventing is enabled, false otherwise.
    def enabled?
      Emittance::Brokerage.enabled?
    end

    # Not yet implemented!
    # :nocov:
    # @private
    def suppress(&_blk)
      raise NotImplementedError, "This isn't working yet!"
      # Emittance::Dispatcher.suppress(&blk)
    end
    # :nocov:
  end
end
