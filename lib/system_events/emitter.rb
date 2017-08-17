module SystemEvents
  module Emitter
    def emit(identifier, *payload)
      now = Time.now
      SystemEvents::Broker.process_event identifier, now, self, payload
    end
  end
end
