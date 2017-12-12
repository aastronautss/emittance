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

      # Look up an {Emittance::Event} class by an identifier. Generates an Event class if no such class exists for
      # that identifier.
      #
      #   EventLookup.find_event_klass :foo
      #   # => FooEvent
      #
      # When passed subclass of {Emittance::Event}, it returns that event class.
      #
      #   class BarEvent < Emittance::Event
      #   end
      #
      #   EventLookup.find_event_klass BarEvent
      #   # => BarEvent
      #
      # Instances of an {Emittance::Event} will fetch the class of that instance.
      #
      #   EventLookup.find_event_klass BarEvent.new(nil, nil, nil)
      #   # => BarEvent
      #
      # Can be passed multiple arguments as a composite identifier. Useful for identifying events by Class#method.
      #
      #   # Not entirely necessary, but for illustrative purposes.
      #   class Baz
      #     def greet
      #     end
      #   end
      #
      #   EventLookup.find_event_klass Baz, :greet
      #   # => BazGreetEvent
      #
      # @param objs [*] anything that can be used to identify an Event class
      # @return [Emittance::Event] the event class identifiable by the params
      def find_event_klass(*objs)
        klass = nil

        klass ||= pass_klass_through(*objs)
        klass ||= klass_of_event(*objs)
        klass ||= find_by_identifier(*objs)

        klass
      end

      # @param klass [Class] a subclass of {Emittance::Event} you wish to find the identifiers for
      # @return [Set<Symbol>] a collection of identifiers that can be used to identify that event class
      def identifiers_for_klass(klass)
        Emittance::EventLookup::Registry.identifiers_for_klass(klass)
      end

      # Registers an identifier for an Event class. After registering, that identifier can be used to identify those
      # events.
      #
      # @param klass [Class] the class you wish to register the identifier for
      # @param identifier [Symbol] identifier you want to identify the class as
      # @return [Class] the class for which you've just registered an identifier
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
        identifier = CompositeIdentifier.new(*objs).generate
        lookup_identifier identifier
      end

      def event_klass?(obj)
        obj.is_a?(Class) && obj < Emittance::Event
      end

      def event_object?(obj)
        obj.is_a? Emittance::Event
      end

      def lookup_identifier(identifier)
        Emittance::EventLookup::Registry.fetch_event_klass(identifier)
      end
    end

    ##
    # Shared behavior for things that want to convert back and forth between event classes and identifiers
    #
    class EventKlassConverter
      include Emittance::Helpers::StringHelpers

      # The thing we want to append to every event class name
      KLASS_NAME_SUFFIX = 'Event'
    end

    ##
    # Converts a collection of objects to a ready-to-go identifier.
    #
    class CompositeIdentifier < EventKlassConverter
      def initialize(*objs)
        @objs = objs
      end

      # Compiles the objects and generates an event class name for them.
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

    ##
    # Derives an event class name from an identifier.
    #
    class EventKlassName < EventKlassConverter
      def initialize(identifier)
        @identifier = identifier
      end

      # Generates an event class name for the given identifier.
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

    ##
    # Derives an identifier from the name of an event class.
    #
    class EventIdentifier < EventKlassConverter
      def initialize(klass)
        @klass = klass
        validate_klass
      end

      # Generates an identifier name for the given event class.
      def generate
        camel_cased_name = undecorate_klass_name(klass.name)
        snake_case(camel_cased_name).to_sym
      end

      private

      attr_reader :klass

      def validate_klass
        subklass_error_msg = "#{klass.name} is not a subclass of Emittance::Event!"
        raise Emittance::IdentifierGenerationError, subklass_error_msg unless klass < Emittance::Event
      end

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
      @identifier_to_klass_mappings = {}
      @klass_to_identifier_mappings = {}

      class << self
        include Emittance::Helpers::ConstantHelpers

        # Finds or generates the event class associated with the identifier.
        #
        # @param identifier [Symbol] the identifier registered to the event class you wish to fetch
        # @return [Class] the event class you wish to fetch
        def fetch_event_klass(identifier)
          klass = nil

          klass ||= identifier_to_klass_mappings[identifier]
          klass ||= derive_event_klass(identifier)

          klass
        end

        # Retrieves all identifiers associated with the event class.
        #
        # @param event_klass [Class] the class you want the identifiers for
        # @return [Set<Symbol>] all identifiers that can be used to identify the given event class
        def identifiers_for_klass(event_klass)
          lookup_klass_to_identifier_mapping(event_klass) ||
            (create_mapping_for_klass(event_klass) && lookup_klass_to_identifier_mapping(event_klass))
        end

        # Registers the given identifier for the given event class.
        #
        # @param klass [Class] the event class you would like to register the identifier for
        # @param identifier [Symbol] the identifier with which you want to identify the event class
        # @return [Class] the event class for which you've registered the identifier
        def register_identifier(klass:, identifier:)
          raise Emittance::InvalidIdentifierError unless valid_identifier? identifier
          raise Emittance::IdentifierCollisionError if identifier_reserved? identifier, klass

          identifier_to_klass_mappings[identifier] = klass

          klass_to_identifier_mappings[klass] ||= empty_collection
          klass_to_identifier_mappings[klass] << identifier

          klass
        end

        # Clears all registrations.
        #
        # @return [Boolean] true
        def clear_registrations!
          identifier_to_klass_mappings.clear
          klass_to_identifier_mappings.clear
        end

        private

        attr_reader :identifier_to_klass_mappings, :klass_to_identifier_mappings

        def identifier_reserved?(identifier, klass)
          klass_already_exists_for_identifier?(identifier, klass) || !!identifier_to_klass_mappings[identifier]
        end

        def klass_already_exists_for_identifier?(identifier, klass)
          derived_klass_name = klass_name_for identifier
          Object.const_defined?(derived_klass_name) && klass.name != derived_klass_name
        end

        def lookup_klass_to_identifier_mapping(event_klass)
          klass_to_identifier_mappings[event_klass]
        end

        def create_mapping_for_klass(event_klass)
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
          set_namespaced_constant_by_name klass_name, new_klass
        end

        def empty_collection
          Set.new
        end
      end
    end
  end
end
