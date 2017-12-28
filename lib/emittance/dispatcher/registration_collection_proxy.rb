# frozen_string_literal: true

module Emittance
  class Dispatcher
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

      # @return [Boolean] true if there are no registrations at all, false otherwise
      def empty?
        mappings.values.all?(&:empty?)
      end

      # @return [RegistrationCollectionProxy] self
      def <<(item)
        mappings[lookup_term] << item
        self
      end

      # @return [RegistrationCollectionProxy] self
      def clear
        mappings.values.each(&:clear)
        self
      end

      private

      attr_reader :lookup_term, :mappings
    end
  end
end
