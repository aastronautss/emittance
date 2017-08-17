module SystemEvents
  class Broker
    @registrations = {}

    class << self
      def process_event(identifier, timestamp, object = nil, payload = [])
        registrations_for(identifier).each do |registration|
          registration.call identifier, timestamp, object, payload
        end
      end

      def register(identifier, &callback)
        @registrations[identifier.to_sym] ||= []
        registrations_for(identifier) << SystemEvents::Registration.new(identifier, &callback)
      end

      private

      def registrations_for(identifier)
        @registrations[identifier.to_sym] || []
      end
    end
  end
end
