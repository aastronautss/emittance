# frozen_string_literal: true

module Emittance
  module Watcher
    def watch(identifier, callback_method = nil, &callback)
      if callback_method
        Emittance::Dispatcher.register_method_call identifier, self, callback_method
      else
        Emittance::Dispatcher.register identifier, &callback
      end
    end
  end
end
