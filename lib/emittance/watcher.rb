# frozen_string_literal: true

module Emittance
  ##
  # Can watch for events that propagate through the system.
  #
  module Watcher
    # Watch for an event, identified by its class' identifier. If a callback method is provided, then it will call that
    # method on the caller of +watch+ when the event happens. Otherwise, it will run the callback block.
    #
    # @param identifier [Symbol] the event's identifier
    # @callback_method
    def watch(identifier, callback_method = nil, &callback)
      if callback_method
        Emittance::Dispatcher.register_method_call identifier, self, callback_method
      else
        Emittance::Dispatcher.register identifier, &callback
      end
    end
  end
end
