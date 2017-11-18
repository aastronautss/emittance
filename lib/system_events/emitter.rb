module SystemEvents
  module Emitter
    def self.extended(extender)
      SystemEvents::Emitter.emitter_eval(extender) do
        unless singleton_class.method_defined? :emits_on_methods
          def self.emits_on_methods
            @_emits_on_methods ||= []
          end
        end

        include InstanceMethods
      end
    end

    def self.non_emitting_method_for(mth)
      "_non_emitting_#{method_name}".to_sym
    end

    def self.emitter_eval(klass, *args, &blk)
      if klass.respond_to? :class_eval
        klass.class_eval *args, &blk
      else
        klass.singleton_class.class_eval(*args, &blk)
      end
    end

    module InstanceMethods
      def emit(identifier, *payload)
        now = Time.now
        SystemEvents::Broker.process_event identifier, now, self, payload
      end
    end

    EmittingMethod = Struct.new :emitting_method, :arity

    def emits_on(*mths)
      mths.each do |mth|
        non_emitting_mth = non_emitting_method_for mth

        SystemEvents::Emitter.emitter_eval(self) do
          if method_defined?(non_emitting_mth)
            warn "Already emitting on #{mth}"
            return
          end

          alias_method non_emitting_mth, mth

          emitting_mth = EmittingMethod.new mth, instance_method(mth).arity
        end
      end
    end
  end
end
