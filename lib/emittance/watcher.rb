##
# Mix in this module to wire up the ability to watch for events. For more information, see {#watch}.
#
module Emittance::Watcher
  # Register a callback for an event, identified by its identifier symbol. If a callback method is passed in, that
  # method will be called on the object that called +#watch+. Otherwise, the callback can take the form of a block,
  # which is passed the event object as a parameter when the event occurs. If both are provided, only the
  # +callback_method+ will be registered.
  #
  # @param identifier [Symbol] the event's identifier
  # @param callback_method [Symbol] the name of the method you wish to call whenever the event is captured
  # @param callback [Block] the block you wish to have run whenever the event is captured
  def watch(identifier, callback_method = nil, &callback)
    if callback_method
      Emittance::Broker.register_method_call identifier, self, callback_method
    else
      Emittance::Broker.register identifier, &callback
    end
  end
end
