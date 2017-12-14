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
    # @param callback_method [Symbol] one option for adding a callback--the method on the object to call when the
    #   event fires
    # @param callback [Block] the other option for adding a callback--the block you wish to be executed when the event
    #   fires
    # @return [Proc] the block that will run when the event fires
    def watch(identifier, callback_method = nil, &callback)
      if callback_method
        _dispatcher.register_method_call identifier, self, callback_method
      else
        _dispatcher.register identifier, &callback
      end
    end

    private

    def _dispatcher
      Emittance.dispatcher
    end
  end
end
