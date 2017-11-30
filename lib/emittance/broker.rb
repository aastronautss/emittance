# @private
class Emittance::Broker
  @registrations = {}
  @enabled = true

  class << self
    attr_reader :enabled

    def process_event(event)
      return unless enabled?

      registrations_for(event).each do |registration|
        registration.call event
      end
    end

    def register(identifier, &callback)
      identifier = normalize_identifier identifier
      @registrations[identifier] ||= []
      registrations_for(identifier) << Emittance::Registration.new(identifier, &callback)
    end

    def register_method_call(identifier, object, method_name)
      register identifier, &lambda_for_method_call(object, method_name)
    end

    def clear_registrations!
      @registrations.keys.each do |identifier|
        self.clear_registrations_for! identifier
      end
    end

    def clear_registrations_for!(identifier)
      identifier = normalize_identifier identifier
      @registrations[identifier].clear
    end

    def registrations_for(identifier)
      identifier = normalize_identifier identifier
      @registrations[identifier] || []
    end

    private

    def normalize_identifier(identifier)
      if is_event_klass?(identifier) || is_event_object?(identifier)
        identifier.identifier
      else
        coerce_identifier_type identifier
      end
    end

    def lambda_for_method_call(object, method_name)
      ->(event) { object.send method_name, event }
    end

    def is_event_klass?(identifier)
      identifier.is_a?(Class) && identifier < Emittance::Event
    end

    def is_event_object?(identifier)
      identifier.is_a? Emittance::Event
    end

    def coerce_identifier_type(identifier)
      identifier.to_sym
    end

    def enabled?
      enabled
    end
  end
end
