# frozen_string_literal: true

module Emittance
  class Event
  end
end

module Emittance
  ##
  # Since events don't need to be dynamically generated when using topics, we essentially want to stub out all of the
  # class creation and registration logic.
  #
  module TopicLookup
    DEFAULT_EVENT_KLASS = Emittance::Event

    class << self
      attr_writer :event_klass

      def identifiers_for_klass(_klass, event = nil)
        raise ArgumentError, 'Cannot generate identifiers without an event' unless event

        [event.topic]
      end

      def register_identifier(klass, identifier)
        # no op
      end

      def find_event_klass(*_identifiers)
        event_klass
      end

      private

      def event_klass
        @event_klass ||= DEFAULT_EVENT_KLASS
      end
    end
  end
end
