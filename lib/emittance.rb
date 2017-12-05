# froze_string_literal: true

require 'emittance/version'
require 'emittance/errors'

require 'emittance/registration'
require 'emittance/event'
require 'emittance/event/event_builder'
require 'emittance/emitter'
require 'emittance/watcher'
require 'emittance/action'
require 'emittance/broker'

##
# The base namespace for this library. You can do some basic configuration stuff by calling methods on its singleton.
#
module Emittance
  class << self
    # Enable eventing process-wide.
    def enable!
      Emittance::Broker.enable!
    end

    # Disable eventing process-wide.
    def disable!
      Emittance::Broker.disable!
    end

    # @return [Boolean] true if eventing is enabled, false otherwise.
    def enabled?
      Emittance::Broker.enabled?
    end

    # @private
    def suppress(&blk)
      Emittance::Broker.suppress(&blk)
    end
  end
end
