# frozen_string_literal: true

require 'set'

module Emittance
  ##
  # For looking up event classes by their identifiers. Can perform a reverse lookup of identifiers by their associated
  # event class.
  #
  module EventLookup
    class << self
      include Emittance::Helpers::StringHelpers

      def find_event_klass(*objs)
        klass = nil

        klass ||= pass_klass_through(*objs)
        klass ||= klass_of_event(*objs)
        klass ||= find_by_identifier(*objs)

        klass
      end

      def identifiers_for_klass(klass)
        Emittance::EventLookup::Registry.identifiers_for_klass(klass)
      end

      def register_identifier(klass, identifier)
        Emittance::EventLookup::Registry.register_identifier klass: klass, identifier: identifier
      end

      private

      def pass_klass_through(*objs)
        objs.length == 1 && event_klass?(objs[0]) ? objs[0] : nil
      end

      def klass_of_event(*objs)
        objs.length == 1 && event_object?(objs[0]) ? objs[0].class : nil
      end

      def find_by_identifier(*objs)
        objs.length == 1 && identifier?(objs[0]) ? lookup_identifier(objs[0]) : nil
      end

      def find_by_identifier(*objs)
        identifier = CompositeIdentifier.new(*objs).generate
        lookup_identifier identifier
      end

      def event_klass?(obj)
        obj.is_a?(Class) && obj < Emittance::Event
      end

      def event_object?(obj)
        obj.is_a? Emittance::Event
      end

      def identifier?(obj)
        obj.is_a? Symbol
      end

      def lookup_identifier(identifier)
        Emittance::EventLookup::Registry.fetch_event_klass(identifier)
      end
    end

    private

    class EventKlassConverter
      include Emittance::Helpers::StringHelpers

      KLASS_NAME_SUFFIX = 'Event'
    end

    class CompositeIdentifier < EventKlassConverter
      def initialize(*objs)
        @objs = objs
      end

      def generate
        parts = objs.map { |obj| identifier_name_for obj }
        compose_identifier_parts parts
      end

      private

      attr_reader :objs

      def identifier_name_for(obj)
        name_str = obj.to_s
        name_str = clean_up_punctuation name_str
        name_str = snake_case name_str

        name_str
      end

      def compose_identifier_parts(parts)
        parts.join('_').to_sym
      end
    end

    class EventKlassName < EventKlassConverter
      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        base_name = camel_case identifier.to_s
        decorate_klass_name base_name
      end

      private

      attr_reader :identifier

      def decorate_klass_name(klass_name_str)
        "#{klass_name_str}#{KLASS_NAME_SUFFIX}"
      end
    end

    class EventIdentifier < EventKlassConverter
      def initialize(klass)
        @klass = klass
      end

      def generate
        camel_cased_name = undecorate_klass_name(klass.name)
        snake_case(camel_cased_name).to_sym
      end

      private

      attr_reader :klass

      def undecorate_klass_name(klass_name)
        klass_name.gsub(/#{KLASS_NAME_SUFFIX}$/, '')
      end
    end

    ##
    # Caches event-to-identifier and identifier-to-event mappings. The strategy here is to lazily store/load those
    # mappings. They are created on lookup. The other option would be to add a +.inherited+ method to
    # {Emittance::Event} that would make subclasses register themselves, but would cause some unwanted entanglement.
    #
    module Registry
      KLASS_NAME_SUFFIX = 'Event'

      @identifier_to_klass_mappings = {}
      @klass_to_identifier_mappings = {}

      class << self
        include Emittance::Helpers::StringHelpers

        def fetch_event_klass(identifier)
          klass = nil

          klass ||= identifier_to_klass_mappings[identifier]
          klass ||= derive_event_klass(identifier)

          klass
        end

        def identifiers_for_klass(event_klass)
          lookup_klass_to_identifier_mapping(event_klass) ||
            create_klass_to_identifier_mapping(event_klass)
        end

        def register_identifier(identifier:, klass:)
          raise Emittance::InvalidIdentifierError unless valid_identifier? identifier
          raise Emittance::IdentifierCollisionError if identifier_to_klass_mapping_exists? identifier

          identifier_to_klass_mappings[identifier] = klass

          klass_to_identifier_mappings[klass] ||= empty_collection
          klass_to_identifier_mappings[klass] << identifier
        end

        def clear_registrations!
          identifier_to_klass_mappings.clear
          klass_to_identifier_mappings.clear
        end

        private

        attr_reader :identifier_to_klass_mappings, :klass_to_identifier_mappings

        def identifier_to_klass_mapping_exists?(identifier)
          !!identifier_to_klass_mappings[identifier]
        end

        def lookup_klass_to_identifier_mapping(event_klass)
          klass_to_identifier_mappings[event_klass]
        end

        def create_klass_to_identifier_mapping(event_klass)
          new_identifier = derive_identifier_from_klass(event_klass)
          register_identifier(identifier: new_identifier, klass: event_klass)

          new_identifier
        end

        def valid_identifier?(identifier)
          identifier.is_a? Symbol
        end

        def derive_event_klass(identifier)
          klass_name = klass_name_for identifier
          event_klass = find_or_create_event_klass klass_name
          register_identifier(identifier: identifier, klass: event_klass)

          event_klass
        end

        def derive_identifier_from_klass(event_klass)
          EventIdentifier.new(event_klass).generate
        end

        def klass_name_for(identifier)
          EventKlassName.new(identifier).generate
        end

        def find_or_create_event_klass(klass_name)
          lookup_event_klass(klass_name) || create_event_klass(klass_name)
        end

        def lookup_event_klass(klass_name)
          Object.const_defined?(klass_name) ? Object.const_get(klass_name) : nil
        end

        def create_event_klass(klass_name)
          new_klass = Class.new(Emittance::Event)
          Object.const_set klass_name, new_klass
        end

        def empty_collection
          Set.new
        end
      end
    end
  end
end
