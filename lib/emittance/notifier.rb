# frozen_string_literal: true

module Emittance
  ##
  # Like +Emittance::Action+, this is a convenience module that you can mix-in to any class that provides a shortuct
  # for a common pattern. An object (usually, a class) that mixes in +Emittance::Notifier+ will watch for all events
  # and call the method on that object with the same name as the event's identifier. For example:
  #
  #   class MyNotifier
  #     extend Emittance::Notifier
  #
  #     def self.something_happened(event)
  #       puts 'something definitely happened!'
  #     end
  #   end
  #
  # Whenever an event whose identifiers include +something_happened+ is emitted, +MyNotifier.something_happened+ will
  # be invoked.
  #
  #   foo.emit :something_happened
  #   # Prints:
  #   # something definitely happened!
  #
  #   foo.emit :something_else_happened
  #   # (nothing)
  #
  # Notice that (1) +MyNotifier+ doesn't need to explicitly listen to `:something_happened`, and (2) no errors or
  # anything occur when an event is emitted for which +MyNotifier+ doesn't have a method defined.
  #
  module Notifier
    # @private
    class << self
      def extended(extender)
        extender.extend Emittance::Watcher

        extender.watch :@all, :_emittance_handle_event
      end
    end

    private

    def _emittance_handle_event(event)
      identifiers = event.identifiers
      identifiers.each do |identifier|
        formatted_identifier = _emittance_format_identifier(identifier)
        send(formatted_identifier) if respond_to?(formatted_identifier)
      end
    end

    def _emittance_format_identifier(identifier)
      identifier.to_s.split('/').last
    end
  end
end
