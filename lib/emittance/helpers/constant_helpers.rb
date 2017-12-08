module Emittance
  module Helpers
    module ConstantHelpers
      def set_namespaced_constant_by_name(const_name, obj)
        names = const_name.split('::')
        names.shift if names.size > 1 && names.first.empty?

        namespace = names.size == 1 ? Object : Object.const_get(names[0...-1].join('::'))
        namespace.const_set names.last, obj
      end
    end
  end
end
