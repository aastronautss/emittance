##
# == Emitters
# 
# An emitter is any object that has the power to emit an event. Extend this module in any class whose singleton or 
# instances you would like to have emit events.
# 
# == Usage
# 
# Whenever something warrants the emission of an event, you just need to call +#emit+ on that object. It is generally
# a good practice for an object to emit its own events, but I'm not your mother so you can emit events from wherever
# you want. +#emit+ takes 2 params: the identifier for the event object type (which can also be the
# {SystemEvents::Event} class itself).
#
module SystemEvents::Emitter
  class << self
    # @private
    def extended(extender)
      SystemEvents::Emitter.emitter_eval(extender) do
        include ClassAndInstanceMethods
        extend ClassAndInstanceMethods
      end
    end

    # @private
    def non_emitting_method_for(method_name)
      "_non_emitting_#{method_name}".to_sym 
    end

    # @private
    def emitting_method_event(emitter_klass, method_name)
      SystemEvents::Event.event_klass_for(emitter_klass, method_name)
    end

    # @private
    def emitter_eval(klass, *args, &blk)
      if klass.respond_to? :class_eval
        klass.class_eval *args, &blk
      else
        klass.singleton_class.class_eval *args, &blk
      end
    end
  end

  # Included and extended whenever { SystemEvent::Emitter } is extended.
  module ClassAndInstanceMethods
    # Emits an {SystemEvents::Event event object} to watchers.
    # 
    # @param identifier [Symbol, SystemEvents::Event] either an explicit Event object or the identifier that can be 
    #   parsed into an Event object.
    # @param payload [*] any additional information that might be helpful for an event's handler to have. Can be 
    #   standardized on a per-event basis by pre-defining the class associated with the 
    def emit(identifier, payload)
      now = Time.now
      event_klass = _event_klass_for identifier
      event = event_klass.new(self, now, payload)
      _send_to_broker event
    end

    # If you don't know the specific identifier whose event you want to emit, you can send it a bunch of stuff and 
    # +Emitter+ will automatically generate an +Event+ class for you.
    # 
    # @param identifiers [*] anything that can be used to generate an +Event+ class.
    # @param payload (@see #emit)
    def emit_with_dynamic_identifier(*identifiers, payload:)
      now = Time.now
      event_klass = _event_klass_for *identifiers
      event = event_klass.new(self, now, payload)
      _send_to_broker event
    end

    private

    # @private
    def _event_klass_for(*identifiers)
      SystemEvents::Event.event_klass_for *identifiers
    end

    # @private
    def _send_to_broker(event)
      SystemEvents::Broker.process_event event
    end
  end

  # Tells the class to emit an event when a any of the given set of methods. By default, the event classes are named 
  # accordingly: If a +Foo+ object +emits_on+ +:bar+, then the event's class will be named +FooBarEvent+, and will be
  # a subclass of +SystemEvents::Event+.
  # 
  # The payload for this event will be the value returned from the method call.
  #
  # @param method_names [Symbol, String, Array<Symbol, String>] the methods whose calls emit an event
  def emits_on(*method_names)
    method_names.each do |method_name|
      non_emitting_method = SystemEvents::Emitter.non_emitting_method_for method_name

      SystemEvents::Emitter.emitter_eval(self) do
        if method_defined?(non_emitting_method)
          warn "Already emitting on #{method_name.inspect}"
          return
        end

        alias_method non_emitting_method, method_name

        module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method_name}(*args, &blk)
            return_value = #{non_emitting_method}(*args, &blk)
            emit_with_dynamic_identifier self.class, __method__, payload: return_value
            return_value
          end
        RUBY
      end
    end
  end
end
