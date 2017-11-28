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

      def normalize_identifier(identifier)
        if is_event_klass?(identifier)
          identifier.identifier
        else
          identifier.to_sym
        end
      end

      def is_event_klass?(identifier)
        identifier.is_a?(Class) && identifier < SystemEvents::Event
      end
    end
  end
end
