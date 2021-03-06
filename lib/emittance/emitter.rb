# frozen_string_literal: true

module Emittance
  ##
  # An emitter is any object that has the power to emit an event. Extend this module in any class whose singleton or
  # instances you would like to have emit events.
  #
  # == Usage
  #
  # Whenever something warrants the emission of an event, you just need to call +#emit+ on that object. It is generally
  # a good practice for an object to emit its own events, but I'm not your mother so you can emit events from wherever
  # you want. It's probably not the best idea to do that, though. +#emit+ takes 2 params. First, it takes the identifier
  # for the event object type (which can also be the {Emittance::Event} class itself). See the "identifiers" section
  # of {Emittance::Event} for more info on this. The second argument is the payload. This is basically whatever you
  # want it to be, but you might want to standardize this on a per-event basis. The +Emittance+ will then (at this
  # time, synchronously) trigger each callback registered to listen for events of that identifier.
  #
  # +Emitter+ also provides a vanity class method that allows you to emit an event whenever a given method is called.
  # This event gets triggered whenever an instance of the class finishes executing a method. This event is emitted (and
  # therefore, all listening callbacks are triggered) between the point at which the method finishes executing and the
  # return value is passed to its invoker.
  #
  module Emitter
    # :nocov:
    class << self
      # @private
      def extended(extender)
        Emittance::Emitter.emitter_eval(extender) do
          include ClassAndInstanceMethods
          extend ClassAndInstanceMethods
        end
      end

      # @private
      def non_emitting_method_for(method_name)
        "_non_emitting_#{method_name}".to_sym
      end

      # @private
      def emitter_eval(klass, *args, &blk)
        if klass.respond_to? :class_eval
          klass.class_eval(*args, &blk)
        else
          klass.singleton_class.class_eval(*args, &blk)
        end
      end
    end
    # :nocov:

    ##
    # Included and extended whenever {Emittance::Emitter} is extended.
    #
    module ClassAndInstanceMethods
      # Emits an {Emittance::Event event object} to watchers.
      #
      # @param identifier [Symbol, Emittance::Event] either an explicit Event object or the identifier that can be
      #   parsed into an Event object.
      # @param payload [*] any additional information that might be helpful for an event's handler to have. Can be
      #   standardized on a per-event basis by pre-defining the class associated with the identifier and validating
      #   the payload. See {Emittance::Event} for more details.
      #
      # @return the payload
      def emit(identifier, payload: nil)
        now = Time.now
        event_klass = _event_klass_for identifier
        event = event_klass.new(self, now, payload).tap { |the_event| the_event.topic = identifier }
        _send_to_broker event

        payload
      end

      # If you don't know the specific identifier whose event you want to emit, you can send it a bunch of stuff and
      # +Emitter+ will automatically generate an +Event+ class for you.
      #
      # @param identifiers [*] anything that can be used to generate an +Event+ class.
      # @param payload (@see #emit)
      def emit_with_dynamic_identifier(*identifiers, payload:)
        now = Time.now
        event_klass = _event_klass_for(*identifiers)
        event = event_klass.new(self, now, payload).tap { |the_event| the_event.topic = identifiers.join('.') }
        _send_to_broker event

        payload
      end

      # Tells the object to emit an event when a any of the given set of methods. By default, the event classes are
      # named accordingly: If a +Foo+ object +emits_on+ +:bar+, then the event's class will be named +FooBarEvent+, and
      # will be a subclass of +Emittance::Event+.
      #
      # The payload for this event will be the value returned from the method call.
      #
      # @param method_names [Symbol, String, Array<Symbol, String>] the methods whose calls emit an event
      def emits_on(*method_names, identifier: nil)
        method_names.each do |method_name|
          non_emitting_method = Emittance::Emitter.non_emitting_method_for method_name

          Emittance::Emitter.emitter_eval(self, &_method_patch_block(method_name, non_emitting_method, identifier))
        end
      end

      private

      def _method_patch_block(method_name, non_emitting_method, identifier)
        lambda do |_klass|
          return if method_defined?(non_emitting_method)

          alias_method non_emitting_method, method_name

          module_eval _method_patch_str(method_name, non_emitting_method, identifier), __FILE__, __LINE__ + 1
        end
      end

      def _method_patch_str(method_name, non_emitting_method, identifier)
        <<-RUBY
          def #{method_name}(*args, &blk)
            return_value = #{non_emitting_method}(*args, &blk)
            if #{!identifier.nil? ? true : false}
              emit #{!identifier.nil? ? identifier : false}, payload: return_value
            else
              emit_with_dynamic_identifier self.class, __method__, payload: return_value
            end
            return_value
          end
        RUBY
      end

      def _event_klass_for(*identifiers)
        Emittance::Event.event_klass_for(*identifiers)
      end

      def _send_to_broker(event)
        Emittance::Brokerage.send_event event
      end
    end
  end
end
