# frozen_string_literal: true

module Emittance
  module SpecFixtures
    class Foo; end
    class Bar; end
    class FooBar; end

    class FooEmitter
      extend Emittance::Emitter

      def emit_foo
        emit :foo

        'return value'
      end

      def do_something
        'return value'
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

# Top-level namespace classes

class Foo; end
class Bar; end
class FooBar; end
class Foo::Baz; end

class FooEvent < Emittance::Event; end
class BarEvent < Emittance::Event; end
class FooBarEvent < Emittance::Event; end
class FooBarFooEvent < Emittance::Event; end
class Foo::BazEvent < Emittance::Event; end
