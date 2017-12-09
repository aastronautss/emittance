# frozen_string_literal: true

module Emittance
  module Helpers
    ##
    # Some helpers for fetching, setting, and manipulating constants.
    #
    module ConstantHelpers
      # Since +Object.const_set+ does not support namespaced constant names, use this to set the constant to the
      # correct namespace.
      #
      # Example:
      #
      #   my_const_name = 'String::Foo'
      #   Object.const_set my_const_name, 'bar'
      #   # => NameError: wrong constant name String::Foo
      #
      #   set_namespaced_constant_by_name my_const_name, 'bar'
      #   String::Foo
      #   # => 'bar'
      #
      # @param const_name [String] a valid namespaced constant name
      # @param obj the value you wish to set that constant to
      def set_namespaced_constant_by_name(const_name, obj)
        names = const_name.split('::')
        names.shift if names.size > 1 && names.first.empty?

        namespace = names.size == 1 ? Object : Object.const_get(names[0...-1].join('::'))
        namespace.const_set names.last, obj
      end
    end
  end
end
