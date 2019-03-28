# frozen_string_literal: true

require 'emittance/version'
require 'emittance/errors'

require 'emittance/helpers/string_helpers'
require 'emittance/helpers/constant_helpers'
require 'emittance/event_lookup'
require 'emittance/topic_lookup'
require 'emittance/event'
require 'emittance/dispatcher'
require 'emittance/brokerage'
require 'emittance/broker'
require 'emittance/emitter'
require 'emittance/watcher'
require 'emittance/middleware'
require 'emittance/notifier'
require 'emittance/action'

##
# The base namespace for this library. You can do some basic configuration stuff by calling methods on its singleton.
#
module Emittance
  class << self
    attr_reader :event_routing_strategy

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
    def default_broker
      Emittance::Brokerage.default_broker
    end

    alias broker default_broker

    def dispatcher_for(*args)
      Emittance::Brokerage.dispatcher_for(*args)
    end

    alias dispatcher dispatcher_for

    # @return [Class] the dispatcher attached to the currently enabled broker
    def default_dispatcher
      default_broker.dispatcher
    end

    # @param identifier [#to_sym] the identifier that can be used to identify the broker you wish to use
    def use_broker(identifier)
      Emittance::Brokerage.use_broker identifier
    end

    def default_broker=(identifier)
      Emittance::Brokerage.default_broker = identifier
    end

    #   Emittance.use_middleware MyMiddleware
    #   Emittance.use_middleware MyOtherMiddleware, MyCoolMiddleware
    #
    # @param middlewares [Array<Class>] each middleware you wish to run.
    def use_middleware(*middlewares)
      Emittance::Middleware.register middlewares
    end

    # Removes all middlewares from the app.
    def clear_middleware!
      Emittance::Middleware.clear_registrations!
    end

    # @return [Class] the registration router currently enabled by the dispatcher
    def registration_router_klass
      Emittance::Dispatcher.registration_router_klass
    end

    # Not yet implemented! Remove nocov and private flags when finished.
    # :nocov:
    # @private
    def suppress(&_blk)
      raise NotImplementedError, "This isn't working yet!"
      # Emittance::Dispatcher.suppress(&blk)
    end
    # :nocov:

    def event_routing_strategy=(new_strategy)
      @event_routing_strategy = new_strategy
      Emittance::Event.lookup_strategy = new_strategy
      Emittance::Dispatcher.routing_strategy = new_strategy
    end
  end
end

Emittance.use_broker :synchronous
