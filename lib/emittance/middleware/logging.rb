# frozen_string_literal: true

require 'logger'

module Emittance
  class Middleware
    ##
    # Middleware for logging events
    #
    class Logging < Emittance::Middleware
      @current_logger = Logger.new(STDOUT)

      class << self
        attr_accessor :current_logger
      end

      def up
        current_logger.info event_log_str

        event
      end

      private

      def current_logger
        self.class.current_logger
      end

      def event_log_str
        "Emittance: #{event.identifiers.last.inspect} event emitted."
      end
    end
  end
end
