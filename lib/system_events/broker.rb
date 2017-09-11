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
        @registrations[identifier.to_sym] ||= []
        registrations_for(identifier) << SystemEvents::Registration.new(identifier, &callback)
      end

      def clear_registrations_for!(identifier)
        @registrations[identifier.to_sym].clear
      end

      def clear_registrations!
        @registrations.keys.each do |identifier|
          self.clear_registrations_for! identifier
        end
      end

      def registrations_for(identifier)
        @registrations[identifier.to_sym] || []
      end
    end
  end
end
