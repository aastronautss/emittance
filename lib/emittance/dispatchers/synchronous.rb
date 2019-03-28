# frozen_string_literal: true

module Emittance
  class Synchronous
    ##
    # The synchronous dispatcher. Runs callbacks one-by-one, in series.
    #
    class Dispatcher < Emittance::Dispatcher
      class << self
        private

        def _process_event(event)
          registrations_for(event).each do |registration|
            event = Emittance::Middleware.down(event)
            registration.(event)
          end
        end

        def _register(identifier, _params = {}, &callback)
          registrations = registrations_for identifier
          registrations << callback
          callback
        end

        def _register_method_call(identifier, object, method_name, _params = {})
          register identifier, &lambda_for_method_call(object, method_name)
        end

        def lambda_for_method_call(object, method_name)
          ->(event) { object.send method_name, event }
        end
      end
    end
  end
end
