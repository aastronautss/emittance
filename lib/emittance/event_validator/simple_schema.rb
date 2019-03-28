# frozen_string_literal: true

module Emittance
  class EventValidator
    ##
    #  @private
    #
    class SimpleSchema
      # @private
      module Success
        class << self
          def success?
            true
          end

          def failure?
            false
          end
        end
      end

      # @private
      module Failure
        class << self
          def success?
            false
          end

          def failure?
            true
          end
        end
      end

      class << self
        def build(&blk)
          new.tap { |schema| schema.instance_eval(&blk) }
        end
      end

      def expected_keys
        @expected_keys ||= Set.new
      end

      # Queries

      def call(object)
        expected_keys.all? { |key| object.key?(key) } ? Success : Failure
      end

      # DSL

      def key(key_name)
        expected_keys << key_name
      end

      def keys(*key_names)
        expected_keys.merge(key_names)
      end
    end
  end
end
