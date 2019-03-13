# frozen_string_literal: true

require 'emittance/dispatcher/registration_collection_proxy'

module Emittance
  class Dispatcher
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

      def clear
        @reg_map = {}
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

        [identifier.to_sym, keys]
      end

      def keys_for_event_identifier(identifier)
        klass = Emittance::EventLookup.find_event_klass(identifier)
        keys = [klass] + keys_matching_event_klass(klass)
        [klass, keys]
      end

      def keys_matching_event_klass(_klass)
        [:@all]
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
  end
end
