# frozen_string_literal: true

module Emittance
  module Helpers
    ##
    # Some helpers for fetching, setting, and manipulating constants.
    #
    module ConstantHelpers
      # Since +Object#const_set+ does not support namespaced constant names, use this to set the constant to the
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
      # @return the object to which you assigned the namespaced constant
      def set_namespaced_constant_by_name(const_name, obj, namespace_filler_klass = Module)
        names = const_name.split('::')
        names.shift if names.size > 1 && names.first.empty?

        parent_names = names[0...-1]
        parent_namespace_name = names[0...-1].join('::')

        fill_in_namespace(parent_names, parent_namespace_name, namespace_filler_klass)

        namespace = parent_names.empty? ? Object : Object.const_get(parent_namespace_name)
        namespace.const_set names.last, obj
      end

      private

      def fill_in_namespace(parent_names, parent_namespace_name, namespace_filler_klass)
        set_namespaced_constant_by_name parent_namespace_name, namespace_filler_klass.new, namespace_filler_klass \
          unless parent_names.empty? || Object.const_defined?(parent_namespace_name)
      end
    end
  end
end

# class Foo
#   extend Emittance::Helpers::ConstantHelpers
# end
