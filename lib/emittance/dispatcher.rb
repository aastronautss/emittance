# frozen_string_literal: true

require 'set'

require 'emittance/dispatcher/registration_map'

module Emittance
  ##
  # Abstract class for dispatchers. Subclasses must implement the following methods:
  #
  # - +._process_event+
  # - +._register+
  # - +._register_method_call+
  #
  # These methods can be private. These methods will have access to +.registrations_for+, which takes an identifier
  # and returns an enumerable object with each object registered to that identifier. These objects can be anything
  # you want, but typically represent the callback you would like to run whenever an event of a certain type is
  # emitted.
  #
  class Dispatcher
    class << self
      # @private
      def inherited(subklass)
        subklass.instance_variable_set '@registrations', RegistrationMap.new
      end

      # Calls the subclass's +_process_event+ method.
      def process_event(event)
        event = Emittance::Middleware.down(event)
        _process_event(event)
      end

      # Calls the subclass's +_register+ method.
      def register(identifier, params = {}, &callback)
        _register(identifier, params, &callback)
      end

      # Calls the subclass's +_register_method_call+ method.
      def register_method_call(identifier, object, method_name, params = {})
        _register_method_call(identifier, object, method_name, params)
      end

      # @param identifier the identifier the registrations for which you would like to look up
      # @return [RegistrationCollectionProxy] an enumerable containing all registrations for a given identifier
      def registrations_for(identifier)
        registrations[identifier]
      end

      # @return [RegistrationMap] the registrations
      def clear_registrations!
        registrations.each_key { |key| clear_registrations_for! key }
        registrations
      end

      # @param identifier the identifier the registrations for hwich you would like to clear
      # @return [RegistrationCollectionProxy] the cleared registration proxy
      def clear_registrations_for!(identifier)
        registrations_for(identifier).clear
      end

      private

      attr_reader :registrations

      def _process_event(_event)
        raise NotImplementedError
      end

      def _register(_identifier, _params, &_callback)
        raise NotImplementedError
      end

      def _register_method_call(_identifier, _object, _method_name, _params)
        raise NotImplementedError
      end
    end
  end
end
