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
    # A proxy for a hash. Identifies special identifiers.
    #
    class RegistrationMap
      SPECIAL_IDENTIFIER_REGEX = /^\@/

      class << self
        # @param
        def special_identifier?(identifier)
          identifier.to_s =~ SPECIAL_IDENTIFIER_REGEX
        end
      end

      def initialize
        @reg_map = {}
      end

      def [](identifier)
        lookup_term, keys = keys_for(identifier)
        collection_for(lookup_term, keys)
      end

      def each_key(*args, &blk)
        reg_map.each_key(*args, &blk)
      end

      private

      attr_reader :reg_map

      def keys_for(identifier)
        if special_identifier?(identifier)
          keys_for_special_identifier(identifier)
        else
          keys_for_event_identifier(identifier)
        end
      end

      def keys_for_special_identifier(identifier)
        keys = [identifier.to_sym]

        case identifier.to_s
        when '@all'
          keys += reg_map.keys.select { |key| key.is_a?(Class) }
        end
      end

      def keys_for_event_identifier(identifier)
        klass = Emittance::EventLookup.find_event_klass(identifier)
        [klass, [klass]]
      end

      def collection_for(lookup_term, keys)
        mappings = Hash[
          keys.map do |key|
            reg_map[key] ||= empty_registration
            [key, reg_map[key]]
          end
        ]

        RegistrationCollectionProxy.new(lookup_term, mappings)
      end

      def empty_registration
        Set.new
      end

      def special_identifier?(identifier)
        self.class.special_identifier?(identifier)
      end
    end

    ##
    # A collection proxy for registrations. Can include multiple key/value pairs.
    #
    class RegistrationCollectionProxy
      def initialize(lookup_term, mappings)
        @lookup_term = lookup_term
        @mappings = mappings
      end

      def each(*args, &blk)
        arrays = mappings.values.map(&:to_a)
        arrays.flatten.each(*args, &blk)
      end

      def empty?
        mappings.values.all? { |val| val.empty? }
      end

      def <<(item)
        mappings[lookup_term] << item
      end

      def clear
        mappings.values.each(&:clear)
      end

      private

      attr_reader :lookup_term, :mappings
    end
  end
end
