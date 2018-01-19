# frozen_string_literal: true

module Emittance
  class Dispatcher
    ##
    # A collection proxy for registrations. Can include multiple key/value pairs.
    #
    class RegistrationCollectionProxy
      include Enumerable

      # @param lookup_term the term initially used to lookup the registrations
      # @param mappings [Hash] the mappings of identifiers to their respective registrations
      def initialize(lookup_term, mappings)
        @lookup_term = lookup_term
        @mappings = mappings
      end

      # @return [RegistrationCollectionProxy] self
      def each
        return enum_for(:each) unless block_given?

        arrays.flatten.each do |registration|
          yield registration
        end
      end

      # @return [Boolean] true if there are no registrations at all, false otherwise
      def empty?
        mappings.values.all?(&:empty?)
      end

      # @return [Integer] the number of registrations that exist in the collection
      def length
        arrays.flatten.length
      end

      alias size length
      alias count length

      # @param idx [Integer] the index you wish to find
      # @return the registration indexed at the specified index
      def [](idx)
        arrays.flatten[idx]
      end

      # @return the registration at the first index
      def first
        self[0]
      end

      # @return the registration at the last index
      def last
        self[-1]
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

      def arrays
        mappings.values.map(&:to_a)
      end
    end
  end
end
