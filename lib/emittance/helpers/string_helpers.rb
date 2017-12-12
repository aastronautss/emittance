# frozen_string_literal: true

module Emittance
  module Helpers
    ##
    # Some helper methods to mix in for the purposes of manipulating strings.
    #
    module StringHelpers
      # Snake case the string, like Rails' +String#underscore+ method. As such, strings that look like namespaced
      # constants will have the namespace resolver operators replaced with +/+ characters, rather than underscores.
      # For example: +'Foo::BarBaz'+ becomes +'foo/bar_baz'+.
      #
      # @param str [String] the string you wish to convert
      # @return [String] a new string that is the snake-cased version of the old string
      def snake_case(str)
        str.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end

      # Camel case the string, like Rails' +String#classify+ method. This essentially works like the inverse of
      # +snake_case+, so +'foo/bar_baz'+ becomes +'Foo::BarBaz'+. There is one one notable exception:
      #
      #   camel_case(snake_case('APIFoo'))
      #   # => 'ApiFoo'
      #
      # As such, be mindful when naming your classes.
      #
      # @param str [String] the string you wish to convert
      # @return [String] a new string converted to camel case.
      def camel_case(str)
        str = str.sub(/^[a-z\d]*/) { $&.capitalize }
        str = str.gsub(%r{(?:_|(\/))([a-z\d]*)}) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
        str.gsub(%r{\/}, '::')
      end

      # Strip all characters that can't go into a constant name.
      def clean_up_punctuation(str)
        str.gsub(%r{[^A-Za-z\d\_\:\/]}, '')
      end
    end
  end
end
