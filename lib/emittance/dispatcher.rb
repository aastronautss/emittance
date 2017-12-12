# frozen_string_literal: true

require 'set'

module Emittance
  # @private
  class Dispatcher
    @registrations = {}
    @enabled = true

    class << self
      def process_event(event)
        registrations_for(event).each do |registration|
          registration.call event
        end
      end

      def registrations_for(identifier)
        event_klass = find_event_klass identifier
        registrations[event_klass] ||= empty_registration
        registrations[event_klass]
      end

      def register(identifier, &callback)
        event_klass = find_event_klass identifier
        registrations[event_klass] ||= empty_registration
        registrations_for(event_klass) << Emittance::Registration.new(event_klass, &callback)

        callback
      end

      def register_method_call(identifier, object, method_name)
        register identifier, &lambda_for_method_call(object, method_name)
      end

      def clear_registrations!
        registrations.each_key do |event_klass|
          clear_registrations_for! event_klass
        end
      end

      def clear_registrations_for!(identifier)
        event_klass = find_event_klass identifier
        registrations[event_klass].clear
      end

      private

      attr_accessor :registrations

      def empty_registration
        Set.new
      end

      def find_event_klass(event)
        Emittance::EventLookup.find_event_klass(event)
      end

      def lambda_for_method_call(object, method_name)
        ->(event) { object.send method_name, event }
      end
    end
  end
end
