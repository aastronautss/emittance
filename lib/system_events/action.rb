##
# There are certain classes (ergo objects) that represent an action taken by another object. This pattern goes like so:
# 
#   class Foo
#     def assign
#       Assignment.new(self).call
#     end
#   end
# 
#   class Assignment
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
# This pattern is useful for maintaining the single responsibility principle, delegating complex tasks to other objects
# even when (in this particular case), it might be sensible for the +assign+ message to be sent to +Foo+. This has
# numerous benefits, including the ability for actions like +Assignment+ to take a duck type.
# 
# However, this can easily just become a proxy for the same antipattern it was made to solve. We might wind up with a 
# +#call+ method like the following:
# 
#   class Assignment
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
# +Assignment+ is suddenly collaborating with a whole bunch of objects! This isn't bad in itself, but it might cause
# some problems further on down the road as we add more responsibilities to +Assignment+. Do we really want all these
# things to happen every time an +Assignment+ happens? If not, assuming this pattern we'll have to add a bunch of 
# control flow:
# 
#   class Assignment
#     # ...
#   
#     def call
#       do_stuff
#     
#       if some_condition
#         do_stuff_to_another_object
#       
#         if some_other_condition
#           do_stuff_to_something_else
#         else
#           do_stuff_to_yet_another_thing
#         end
#       elsif yet_another_condition
#         do_other_stuff_to_that_other_object
#       else
#         dont_actually_do_anything_but_notify_someone
#       end
#     end
#   
#     # ...
#   end
# 
# This is obviously an extreme example (but not unheard of!), but it gets to the core of what this module tries to 
# solve. +SystemEvents::Action+ helps facilitate the single responsibility principle by emitting an event whenever we
# invoke +#call+ on an object like +Assignment+.
# 
# == Usage
# 
# First, define a class and include this module:
# 
#   class Assignment
#     include SystemEvents::Action
#   
#     attr_reader :assignable
#   
#     def initialize(assignable)
#       @assignable = assignable
#     end
#   end
# 
# Per the pattern explained above, instances of this class are representations of an action being carried out. This 
# class should have a very minimal interface (maybe, at most, some getter methods for its instance variables so the
# handler can make decisions based on its state).
# 
# Next, we'll implement the +#call+ instance method. +SystemEvents::Action+ will take care of the dirty work for us:
# 
#   class Assignment
#     # ...
#   
#     def call
#       do_one_and_i_mean_only_one_thing
#     end
#   
#     # ...
#   end
# 
# Again, this method should do a single thing. From here, your code should be able to run without error! You might 
# notice, though, that a mysterious class will have been defined after loading this file.
# 
#   defined? AssignmentHandler
#   => "constant"
# 
# Next, we can open up this class to implement the event handler. +SystemEvents+ will look for a method called 
# +#handle_call+, and invoke it whenever, in this example, +Assignment#call+ is called.
# 
#   class AssignmentHandler
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
# several advantages. First, we can disable +SystemEvents+ at will, so if we ever want to shut +Assignment+ actions
# off from their listeners, that is always an option to us. Second, to address the concern raised at the beginning of
# this paragraph, this paradigm puts us into the mindset of spreading the flow of our program out across multiple 
# action/handler pairs, allowing us to think more clearly about what our code is doing.
# 
# One possible disadvantage of this pattern is that it suggests a one-to-one pairing between events and handlers.
# 
module SystemEvents::Action
  EMITTING_METHOD = :call
  HANDLER_METHOD_NAME = "handle_#{EMITTING_METHOD}".to_sym

  class NoHandlerMethodError < StandardError; end

  class << self
    # @private
    def included(action_klass)
      handler_klass_name = SystemEvents::Action.handler_klass_name(action_klass)
      handler_klass = SystemEvents::Action.find_or_create_klass(handler_klass_name)

      action_klass.class_eval do
        extend SystemEvents::Emitter

        class << self
          # @private
          def method_added(method_name)
            emitting_method = SystemEvents::Action::EMITTING_METHOD
            emits_on method_name if method_name == emitting_method
            super
          end
        end
      end

      handler_klass.class_eval do
        attr_reader :action

        extend SystemEvents::Watcher

        # @private
        def initialize(action_obj)
          @action = action_obj
        end

        watch SystemEvents::Action.emitting_event_name(action_klass) do |_, _, action_obj|
          handler_obj = new(action_obj)
          handler_method_name = SystemEvents::Action::HANDLER_METHOD_NAME

          if handler_obj.respond_to? handler_method_name
            new(action_obj).send handler_method_name
          else
            raise
          end
        end
      end
    end

    # @private
    def handler_klass_name(action_klass)
      "#{action_klass}Handler"
    end

    # @private
    def emitting_event_name(action_klass)
      SystemEvents::Emitter.emitting_method_event_name(action_klass, SystemEvents::Action::EMITTING_METHOD)
    end

    # @private
    def find_or_create_klass(klass_name)
      unless Object.const_defined? klass_name
        Object.const_set klass_name, Class.new(Object)
      end

      Object.const_get klass_name
    end
  end
end
