module SystemEvents::Emitter
  class << self
    def extended(extender)
      SystemEvents::Emitter.emitter_eval(extender) do
        include ClassAndInstanceMethods
        extend ClassAndInstanceMethods
      end
    end

    def non_emitting_method_for(method_name)
      "_non_emitting_#{method_name}".to_sym 
    end

    def emitting_method_event_name(emitter_klass, method_name)
      "#{emitter_klass}##{method_name}"
    end

    def emitter_eval(klass, *args, &blk)
      if klass.respond_to? :class_eval
        klass.class_eval *args, &blk
      else
        klass.singleton_class.class_eval *args, &blk
      end
    end
  end

  module ClassAndInstanceMethods
    def emit(identifier, *payload)
      now = Time.now
      SystemEvents::Broker.process_event identifier, now, self, payload
    end
  end

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
            event_name = SystemEvents::Emitter.emitting_method_event_name(self.class, __method__)
            return_value = #{non_emitting_method}(*args, &blk)
            emit event_name, return_value
            return_value
          end
        RUBY
      end
    end
  end
end
