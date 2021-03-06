# frozen_string_literal: true

module Emittance
  ##
  # Consider the usual "Service Object" pattern:
  #
  #   class Foo
  #     def assign
  #       FooAssignment.new(self).call
  #     end
  #   end
  #
  #   class FooAssignment
  #     attr_reader :assignable
  #
  #     def initialize(assignable)
  #       @assignable = assignable
  #     end
  #
  #     def call
  #       do_stuff
  #     end
  #
  #     # ...
  #   end
  #
  # There are variations on this pattern, the idea is that the service object represents something that your application
  # is doing. However, this can easily just become a proxy for the same antipattern it was made to solve. We might wind
  # up with a +#call+ method like the following:
  #
  #   class FooAssignment
  #     # ...
  #
  #     def call
  #       do_stuff
  #       do_stuff_to_another_object
  #       do_stuff_to_something_else
  #       do_stuff_to_yet_another_thing
  #     end
  #
  #     # ...
  #   end
  #
  # We can use the +Emittance+ core features to prune those method calls:
  #
  #   class FooAssignment
  #     extend Emittance::Emitter
  #
  #     # ...
  #
  #     def call
  #       do_stuff
  #       emit :foo_assignment
  #     end
  #
  #     # ...
  #   end
  #
  # +Emittance::Action+ provides a shortcut for this. Just mix it in and implement +#call+! This allows us to keep the
  # expressitivity that a Service Object is made to provide, while preventing us from having to give such an object too
  # many responsibilities.
  #
  # == Usage
  #
  # First, define a class and include this module:
  #
  #   class FooAssignment
  #     include Emittance::Action
  #
  #     attr_reader :assignable
  #
  #     def initialize(assignable)
  #       @assignable = assignable
  #     end
  #   end
  #
  # Next, we'll implement the +#call+ instance method. +Emittance::Action+ will take care of the dirty work for us:
  #
  #   class FooAssignment
  #     # ...
  #
  #     def call
  #       do_one_and_i_mean_only_one_thing
  #     end
  #
  #     # ...
  #   end
  #
  # From here, your code should be able to run without error! You might notice, though, that a mysterious class will
  # have been defined after loading this file.
  #
  #   defined? FooAssignmentHandler
  #   => "constant"
  #
  # Next, we can open up this class to implement the event handler. +Emittance+ will look for a method called
  # +#handle_call+, and invoke it whenever, in this example, +FooAssignment#call+ is called.
  #
  #   class FooAssignmentHandler
  #     def handle_call
  #       notify_someone(action)
  #     end
  #
  #     # ...
  #   end
  #
  # The "Action" object is stored as the instance variable +@action+, made available with a getter class +#action+. This
  # will allow us to access its data and make decisions based on it.
  #
  # Now, this seems like we're passing the buck of all that control flow to yet another object, but this pattern has
  # several advantages. First, we can disable +Emittance+ at will, so if we ever want to shut +FooAssignment+ actions
  # off from their listeners, that is always an option to us. Second, to address the concern raised at the beginning of
  # this paragraph, this paradigm puts us into the mindset of spreading the flow of our program out across multiple
  # action/handler pairs, allowing us to think more clearly about what our code is doing.
  #
  # One possible disadvantage of this pattern is that it suggests a one-to-one pairing between events and handlers.
  #
  module Action
    # Name of the method that will emit an event when invoked.
    EMITTING_METHOD = :call
    # Name of the method that will be invoked when the handler class captures an event.
    HANDLER_METHOD_NAME = "handle_#{EMITTING_METHOD}".to_sym

    # @private
    class << self
      include Emittance::Helpers::ConstantHelpers

      def included(action_klass)
        handler_klass_name = Emittance::Action.handler_klass_name(action_klass)
        handler_klass = Emittance::Action.find_or_create_klass(handler_klass_name)

        setup_action_klass action_klass
        setup_handler_klass handler_klass, action_klass
      end

      # @private
      def handler_klass_name(action_klass)
        "#{action_klass}Handler"
      end

      # @private
      def emitting_event_identifier(action_klass)
        Emittance::Event.event_klass_for action_klass
      end

      # @private
      def find_or_create_klass(klass_name)
        set_namespaced_constant_by_name(klass_name, Class.new) unless Object.const_defined?(klass_name)

        Object.const_get klass_name
      end

      private

      # Class setups

      def setup_action_klass(action_klass)
        action_klass.class_eval(&action_klass_blk)
      end

      def setup_handler_klass(handler_klass, action_klass)
        handler_klass.class_eval(&handler_klass_blk(action_klass))
      end

      # Blocks

      # rubocop:disable Metrics/MethodLength
      def action_klass_blk
        lambda do |_klass|
          extend Emittance::Emitter

          class << self
            define_method :method_added do |method_name|
              emitting_method = Emittance::Action::EMITTING_METHOD
              identifier = Emittance::Action.emitting_event_identifier(self)
              emits_on(method_name, identifier: identifier) if method_name == emitting_method
              super method_name
            end
          end
        end
      end

      def handler_klass_blk(action_klass)
        lambda do |_klass|
          attr_reader :action

          extend Emittance::Watcher

          define_method :initialize do |action_obj|
            @action = action_obj
          end

          watch Emittance::Action.emitting_event_identifier(action_klass) do |event|
            handler_obj = new(event.emitter)
            handler_method_name = Emittance::Action::HANDLER_METHOD_NAME

            handler_obj.send(handler_method_name) if handler_obj.respond_to?(handler_method_name)
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
