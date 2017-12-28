# frozen_string_literal: true

require 'set'

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
      def inherited(subklass)
        subklass.instance_variable_set '@registrations', RegistrationMap.new
      end

      def process_event(event)
        _process_event(event)
      end

      def register(identifier, &callback)
        _register(identifier, &callback)
      end

      def register_method_call(identifier, object, method_name)
        _register_method_call(identifier, object, method_name)
      end

      def registrations_for(identifier)
        registrations[identifier]
      end

      def clear_registrations!
        registrations.each_key { |key| clear_registrations_for! key }
      end

      def clear_registrations_for!(identifier)
        registrations_for(identifier).clear
      end

      private

      attr_reader :registrations

      def _process_event(_event)
        raise NotImplementedError
      end

      def _register(_identifier, &_callback)
        raise NotImplementedError
      end

      def _register_method_call(_identifier, _object, _method_name)
        raise NotImplementedError
      end
    end

    ##
    # A proxy for a hash. Identifies special identifiers
    #
    class RegistrationMap
      class << self
        def special_identifier?(identifier)
          identifier.to_s =~ /^\@/
        end
      end

      def initialize
        @reg_map = {}
      end

      def [](identifier)
        keys = keys_for(identifier)
        reg_map[keys] ||= empty_registration
        reg_map[keys]
      end

      def each_key(*args, &blk)
        reg_map.each_key(*args, &blk)
      end

      private

      attr_reader :reg_map

      def keys_for(identifier)
        Emittance::EventLookup.find_event_klass(identifier)
      end

      def empty_registration
        Set.new
      end

      def special_identifier?(identifier)
        self.class.special_identifier?(identifier)
      end
    end

    class RegistrationCollection
    end
  end
end
