module SystemEvents::Watcher
  def watch(identifier, &callback)
    SystemEvents::Broker.register identifier, &callback
  end
end
