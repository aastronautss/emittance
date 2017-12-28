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
      # @param subklass [Class] the new subclass
      def inherited(subklass)
        subklass.instance_variable_set '@registrations', RegistrationMap.new
      end

      # Calls the subclass's +_process_event+ method.
      def process_event(event)
        _process_event(event)
      end

      # Calls the subclass's +_register+ method.
      def register(identifier, &callback)
        _register(identifier, &callback)
      end

      # Calls the subclass's +_register_method_call+ method.
      def register_method_call(identifier, object, method_name)
        _register_method_call(identifier, object, method_name)
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
        # @param identifier the identifier we want to know information about
        # @return [Boolean] true if the identifier is a special one, false otherwise
        def special_identifier?(identifier)
          identifier.to_s =~ SPECIAL_IDENTIFIER_REGEX
        end
      end

      # Build a registration map.
      def initialize
        @reg_map = {}
      end

      # @param identifier the identifier you wish to lookup registrations for
      # @return [RegistrationCollectionProxy] a collection of registrations for that identifier
      def [](identifier)
        lookup_term, keys = keys_for(identifier)
        collection_for(lookup_term, keys)
      end

      # @param args args passed to +Hash#each_key+
      # @param blk block passed to +Hash#each_key+
      # @return [RegistrationMap] self
      def each_key(*args, &blk)
        reg_map.each_key(*args, &blk)
        self
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
      # @param lookup_term the term initially used to lookup the registrations
      # @param mappings [Hash] the mappings of identifiers to their respective registrations
      def initialize(lookup_term, mappings)
        @lookup_term = lookup_term
        @mappings = mappings
      end

      # @param args args passed to +Array#each+
      # @param blk block passed to +Array#each+
      # @return [RegistrationCollectionProxy] self
      def each(*args, &blk)
        arrays = mappings.values.map(&:to_a)
        arrays.flatten.each(*args, &blk)
        self
      end

      def empty?
        mappings.values.all? { |val| val.empty? }
      end

      def <<(item)
        mappings[lookup_term] << item
        self
      end

      def clear
        mappings.values.each(&:clear)
        self
      end

      private

      attr_reader :lookup_term, :mappings
    end
  end
end
