module SystemEvents
  class Broker
    @registrations = {}

    class << self
      def process_event(identifier, timestamp, emitter = nil, payload = [])
        registrations_for(identifier).each do |registration|
          registration.call timestamp, emitter, payload
        end
      end

      def register(identifier, &callback)
        @registrations[identifier] ||= []
        registrations_for(identifier) << SystemEvents::Registration.new(identifier, &callback)
      end

      def clear_registrations_for!(identifier)
        @registrations[identifier].clear
      end

      def clear_registrations!
        @registrations.keys.each do |identifier|
          self.clear_registrations_for! identifier
        end
      end

      def registrations_for(identifier)
        @registrations[identifier] || []
      end
    end
  end
end
