module Emittance
  module Helpers
    module StringHelpers
      def snake_case(str)
        str.gsub(/::/, '_')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end

      def camel_case(str)
        str = str.sub(/^[a-z\d]*/) { $&.capitalize }
        str.gsub(%r{(?:_|(\/))([a-z\d]*)}) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
      end
    end
  end
end
