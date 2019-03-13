# frozen_string_literal: true

module Emittance
  ##
  # = Topical Event Lookup
  #
  # This section describes the new ('topical') style of event lookup. This will be maintained in the future in favor
  # of the old ('classical') style. However, it is not enabled by default. To enable this strategy, you must configure
  # Emittance to use it:
  #
  #   Emittance.event_routing_strategy = :topical
  #
  # This strategy mimicks the topic name format used by RabbitMQ.
  #
  # = Classical Event Lookup (Legacy)
  #
  # This section describes the old ('classical') style of event lookup. While it's unlikely to be removed, it will
  # remain unsupported in favor of the new ('topical') style of event lookup, described above.
  #
  # Basic usage of Emittance doesn't require that you fiddle with objects of type +Emittance::Event+. However, this
  # class is open for you to inherit from in the cases where you would like to customize some aspects of the event.
  #
  # To define a custom event, just inherit from +Emittance::Event+:
  #
  #   class FooEvent < Emittance::Event
  #   end
  #
  # One common use case for this is to make sure all payloads share the same format. You can do this however you'd like.
  # We've provided an +InvalidPayloadError+ class for that purpose. Here's one example of how that might happen:
  #
  #   class FooEvent < Emittance::Event
  #     def initialize(emitter, timestamp, payload)
  #       super
  #       validate_payload
  #     end
  #
  #     private
  #
  #     def validate_payload
  #       raise Emittance::InvalidPayloadError unless payload.is_a?(String)
  #     end
  #   end
  #
  # == Identifiers
  #
  # Events are identified by what we call "Identifiers." These come in the form of symbols, and can be used to identify
  # specific event types.
  #
  # === Identifier Naming
  #
  # The naming convention for events and their identifiers goes like this: the name of an event class will be the
  # CamelCase form of its identifier, plus the word +Event+. For example, +FooEvent+ can be identified with +:foo+.
  # Thus, the events received by watchers of +:foo+ will be instances of `FooEvent`. Conversely, if you make an event
  # class +BarEvent+ that inherits from +Emittance::Event+, its built-in identifier will be +:bar+. You can see what
  # a +Emittance::Event+ subclass's identifier is by calling +.identifiers+ on it.
  #
  #   class SomethingHappenedEvent < Emittance::Event
  #   end
  #
  #   MyEvent.identifiers
  #   # => [:something_happened]
  #
  #   MyEvent.new.identifiers
  #   # => [:something_happened]
  #
  # The namespace resultion operator (+::+) in an event's class name will translate to a +/+ in the identifier name:
  #
  #   class Foo::BarEvent < Emittance::Event
  #   end
  #
  #   Foo::BarEvent.identifiers
  #   #=> [:'foo/bar']
  #
  # === Custom Identifiers
  #
  # By default, the identifier for this event will be the snake_case form of the class name with +Event+ chopped off:
  #
  #   FooEvent.identifiers
  #   # => [:foo]
  #
  # You can set a custom identifier for the event class like so:
  #
  #   FooEvent.add_identifier :bar
  #   FooEvent.identifiers
  #   # => [:foo, :bar]
  #
  # Now, when emitters emit +:bar+, this will be the event received by watchers. +#add_identifier+ will raise an
  # {Emittance::IdentifierCollisionError} if you attempt to add an identifier that has already been claimed. This
  # error will also be raised if you try to add an identifier that already has an associated class. For example:
  #
  #   class FooEvent < Emittance::Event
  #   end
  #
  #   class BarEvent < Emittance::Event
  #   end
  #
  #   BarEvent.add_identifier :foo
  #   # => Emittance::IdentifierCollisionError
  #
  # This error is raised because, even though we haven't explicitly add the identifier +:foo+ for +FooEvent+, Emittance
  # is smart enough to know that there exists a class whose name resolves to +:foo+.
  #
  # It's best to use custom identifiers very sparingly. One reason for this can be illustrated like so:
  #
  #   class FooEvent < Emittance::Event
  #   end
  #
  #   FooEvent.add_identifier :bar
  #   FooEvent.identifiers
  #   # => [:foo, :bar]
  #
  #   class BarEvent < Emittance::Event
  #   end
  #
  #   BarEvent.identifiers
  #   # => []
  #
  # Since +BarEvent+'s default identifier was already reserved when it was created, it could not claim that identifier.
  # We can manually add an identifier post-hoc, but this would nevertheless become confusing.
  #
  class Event
    LOOKUP_STRATEGIES = {
      classical: EventLookup,
      topical: TopicLookup
    }.freeze

    @lookup_strategy = EventLookup

    class << self
      attr_reader :lookup_strategy

      # @param new_strategy_name [#to_sym] the name of the new lookup strategy
      def lookup_strategy=(new_strategy_name)
        new_strategy =
          if new_strategy_name.is_a?(Module)
            new_strategy_name
          else
            LOOKUP_STRATEGIES[new_strategy_name.to_sym]
          end

        raise ArgumentError, 'Could not find a lookup strategy with that name' unless new_strategy

        @lookup_strategy = new_strategy
      end

      def inherited(subklass)
        subklass.instance_variable_set('@lookup_strategy', lookup_strategy)
      end

      # @return [Array<Symbol>] the identifier that can be used by the {Emittance::Broker broker} to find event handlers
      def identifiers(event = nil)
        lookup_strategy.identifiers_for_klass(self, event).to_a
      end

      # Gives the Event object a custom identifier.
      #
      # @param sym [Symbol] the identifier you wish to identify this event by when emitting and watching for it
      def add_identifier(sym)
        raise Emittance::InvalidIdentifierError, 'Identifiers must respond to #to_sym' unless sym.respond_to?(:to_sym)
        lookup_strategy.register_identifier self, sym.to_sym
      end

      # @param identifiers [*] anything that can be derived into an identifier (or the event class itself) for the
      #   purposes of looking up an event class.
      def event_klass_for(*identifiers)
        lookup_strategy.find_event_klass(*identifiers)
      end
    end

    attr_reader :emitter, :timestamp, :payload
    attr_accessor :topic

    # @param emitter the object that emitted the event
    # @param timestamp [Time] the time at which the event occurred
    # @param payload any useful data that might be of use to event watchers
    def initialize(emitter, timestamp, payload)
      @emitter = emitter
      @timestamp = timestamp
      @payload = payload
    end

    # @return [Array<Symbol>] all identifiers that can be used to identify the event
    def identifiers
      self.class.identifiers(self)
    end
  end
end
