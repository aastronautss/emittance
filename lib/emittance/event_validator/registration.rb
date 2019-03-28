# frozen_string_literal: true

require 'emittance/event_validator/simple_schema'

module Emittance
  class EventValidator
    ##
    #  @private
    #
    class Registration
      @schema_builder = SimpleSchema

      attr_reader :schema

      class << self
        attr_accessor :schema_builder
      end

      def initialize(schema = nil, &schema_evaluator)
        @schema = schema || build_schema(schema_evaluator)
      end

      def valid_for_event?(event)
        schema.(event.payload).success?
      end

      private

      def build_schema(evaluator)
        schema_builder.build(&evaluator)
      end

      def schema_builder
        self.class.schema_builder
      end
    end
  end
end
