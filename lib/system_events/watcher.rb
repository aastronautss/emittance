module SystemEvents
  module Watcher
    def watch(identifier, &block)
      SystemEvents::Broker.register identifier, block
    end
  end
end
