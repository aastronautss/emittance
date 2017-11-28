module SystemEvents
  # @private
  class Broker
    @registrations = {}

    class << self
      def process_event(event)
        registrations_for(event.identifier).each do |registration|
          registration.call event
        end
      end

      def register(identifier, &callback)
        identifier = normalize_identifier identifier
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

      def normalize_identifier(identifier)
        if identifier < SystemEvents::Event
          identifier.identifier
        else
          identifier
        end
      end
    end
  end
end
