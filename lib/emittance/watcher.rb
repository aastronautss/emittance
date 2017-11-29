module Emittance::Watcher
  def watch(identifier, &callback)
    Emittance::Broker.register identifier, &callback
  end
end
