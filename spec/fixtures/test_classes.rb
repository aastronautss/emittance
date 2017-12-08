module Emittance
  module SpecFixtures
    class FooEmitter
      extend Emittance::Emitter

      def emit_foo
        emit :foo
      end

      def do_something

      end
      emits_on :do_something
    end

    class FooInstanceEmitter
    end

    class FooWatcher
      extend Emittance::Watcher
    end

    class FooInstanceWatcher
      include Emittance::Watcher
    end

    class FooAction
      include Emittance::Action

      def call
        'bar'
      end

      def foo_action_handled!
        'handled!'
      end
    end

    class FooActionHandler
      def handle_call
        action.foo_action_handled!
      end
    end
  end
end
