module Emittance::Watcher
  def watch(identifier, callback_method = nil, &callback)
    if callback_method
      Emittance::Dispatcher.register_method_call identifier, self, callback_method
    else
      Emittance::Dispatcher.register identifier, &callback
    end
  end
end
