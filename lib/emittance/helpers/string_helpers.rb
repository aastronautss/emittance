# frozen_string_literal: true

module Emittance
  module Helpers
    ##
    # Some helper methods to mix in for the purposes of manipulating strings.
    #
    module StringHelpers
      # Snake case the string, like Rails' +String#underscore+ method.
      def snake_case(str)
        str.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end

      # Camel case the string, like Rails' +String#classify+ method.
      def camel_case(str)
        str = str.sub(/^[a-z\d]*/) { $&.capitalize }
        str = str.gsub(%r{(?:_|(\/))([a-z\d]*)}) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
        str.gsub(%r{\/}, '::')
      end

      # Strip all characters that can't go into a constant name.
      def clean_up_punctuation(str)
        str.gsub(/[^A-Za-z\d\_\:]/, '')
      end
    end
  end
end
