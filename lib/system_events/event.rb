module SystemEvents::Event
  EMITTING_METHOD = :call
  HANDLER_METHOD_NAME = "handle_#{EMITTING_METHOD}".to_sym

  class NoHandlerMethodError < StandardError; end

  class << self
    def included(event_klass)
      handler_klass_name = SystemEvents::Event.handler_klass_name(event_klass)
      handler_klass = SystemEvents::Event.find_or_create_klass(handler_klass_name)

      event_klass.class_eval do
        extend SystemEvents::Emitter

        class << self
          def method_added(method_name)
            emitting_method = SystemEvents::Event::EMITTING_METHOD
            emits_on emitting_method if method_name == emitting_method
          end
        end
      end

      handler_klass.class_eval do
        attr_reader :event

        extend SystemEvents::Watcher

        def initialize(event_obj)
          @event = event_obj
        end

        watch SystemEvents::Event.emitting_event_name(event_klass) do |_, _, event_obj|
          handler_obj = new(event_obj)
          handler_method_name = SystemEvents::Event::HANDLER_METHOD_NAME

          if handler_obj.respond_to? handler_method_name
            new(event_obj).send handler_method_name
          else
            raise
          end
        end
      end
    end

    def handler_klass_name(event_klass)
      "#{event_klass}Handler"
    end

    def emitting_event_name(event_klass)
      SystemEvents::Emitter.emitting_method_event_name(event_klass, SystemEvents::Event::EMITTING_METHOD)
    end

    def find_or_create_klass(klass_name)
      unless Object.const_defined? klass_name
        Object.const_set klass_name, Class.new(Object)
      end

      Object.const_get klass_name
    end
  end
end
