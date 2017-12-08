# frozen_string_literal: true

require 'set'

module Emittance
  # @private
  class Dispatcher
    @registrations = {}
    @enabled = true

    class << self
      include Emittance::IdentifierSerializer

      def process_event(event)
        new.process_event event
      end

      def register(identifier, &callback)
        identifier = normalize_identifier identifier
        registrations[identifier] ||= empty_registration
        registrations_for(identifier) << Emittance::Registration.new(identifier, &callback)
      end

      def register_method_call(identifier, object, method_name)
        register identifier, &lambda_for_method_call(object, method_name)
      end

      def clear_registrations!
        registrations.each_key do |identifier|
          clear_registrations_for! identifier
        end
      end

      def clear_registrations_for!(identifier)
        identifier = normalize_identifier identifier
        registrations[identifier].clear
      end

      def registrations_for(identifier)
        identifier = normalize_identifier identifier
        registrations[identifier] || empty_registration
      end

      def enable!
        @enabled = true
      end

      def disable!
        @enabled = false
      end

      def enabled?
        @enabled
      end

      private

      attr_accessor :enabled, :registrations

      def empty_registration
        Set.new
      end

      def lambda_for_method_call(object, method_name)
        ->(event) { object.send method_name, event }
      end
    end

    def initialize(suppressed = false)
      @suppressed = suppressed
    end

    def process_event(event)
      return unless enabled?

      registrations_for(event).each do |registration|
        registration.call event
      end
    end

    private

    attr_reader :suppressed

    def registrations_for(event)
      self.class.registrations_for event
    end

    def enabled?
      self.class.enabled? && !suppressed?
    end

    def suppressed?
      suppressed
    end
  end
end
