module SystemEvents
  class Broker
    class << self
      @registrations = {}

      def process_event(identifier, timestamp, object, payload)
        registrations_for(identifier).each do |registration|
          registration.call identifier, timestamp, object, payload
        end
      end

      def register(identifier, callback)
        @registrations[identifier.to_sym] ||= []
        registrations_for(identifier) << Registration.new(identifier, callback)
      end

      private

      def registrations_for(identifier)
        @registrations[identifier.to_sym] || []
      end
    end
  end
end
