# frozen_string_literal: true

require 'set'

require 'emittance/dispatcher/registration_map'
require 'emittance/dispatcher/topic_registration_map'

module Emittance
  ##
  # Abstract class for dispatchers. Subclasses must implement the following class methods:
  #
  # - +._process_event+
  # - +._register+
  # - +._register_method_call+
  #
  # These methods can be private. These methods will have access to +.registrations_for+, which takes an identifier
  # and returns an enumerable object with each object registered to that identifier. These objects can be anything
  # you want, but typically represent the callback you would like to run whenever an event of a certain type is
  # emitted.
  #
  # == Example
  #
  # Suppose we have a simple dispatcher. We're not going to worry about method calls, so we're just going to focus on
  # implementing +._register+ and +._process_event+.
  #
  #   class SimpleDispatcher < Emittance::Dispatcher
  #     class << self
  #       private
  #
  #       # +._register+ takes the original identifier/topic, an optional params hash, and a block. To register the
  #       # callback, push it on to the collection returned by the +.registrations_for+ method. You can format the
  #       # callback in any way you like.
  #       def _register(identifier, _params = {}, &callback)
  #         registrations_for(event) << format_callback(callback)
  #         callback
  #       end
  #
  #       # +._process_event+ is simple -- we just need to fetch the registrations related to the event, and process
  #       # them. The registrations are returned in the exact same format as they were stored in +._register+. So, in
  #       # this case, we will get a set of +CallbackWrapper+ objects, each of which responds to +#call+.
  #       #
  #       # IMPORTANT: You also need to make sure that the +down+ middleware stack is called in the process.
  #       def _process_event(event)
  #         event = Emittance::Middleware.down(event)
  #         registrations_for(event).each { |registration| registration.call(event) }
  #       end
  #
  #       def format_callback(callback)
  #         CallbackWrapper.new(callback)
  #       end
  #     end
  #   end
  #
  class Dispatcher
    ROUTING_STRATEGIES = {
      classical: RegistrationMap,
      topical: TopicRegistrationMap
    }.freeze

    @routing_strategy = RegistrationMap

    class << self
      def routing_strategy
        @routing_strategy || ::Emittance::Dispatcher.instance_variable_get('@routing_strategy')
      end

      alias registration_router_klass routing_strategy

      def routing_strategy=(new_strategy_name)
        new_strategy =
          if new_strategy_name.is_a?(Module)
            new_strategy_name
          else
            ROUTING_STRATEGIES[new_strategy_name.to_sym]
          end

        raise ArgumentError, 'Could not find a routing strategy with that name' unless new_strategy

        @routing_strategy = new_strategy
      end

      # Calls the subclass's +_process_event+ method.
      def process_event(event)
        _process_event(event)
      end

      # Calls the subclass's +_register+ method.
      def register(identifier, params = {}, &callback)
        _register(identifier, params, &callback)
      end

      # Calls the subclass's +_register_method_call+ method.
      def register_method_call(identifier, object, method_name, params = {})
        _register_method_call(identifier, object, method_name, params)
      end

      # @param identifier the identifier the registrations for which you would like to look up
      # @return [RegistrationCollectionProxy] an enumerable containing all registrations for a given identifier
      def registrations_for(identifier)
        registrations[identifier]
      end

      # @return [RegistrationMap] the registrations
      def clear_registrations!
        registrations.clear
        registrations
      end

      # @param identifier the identifier the registrations for hwich you would like to clear
      # @return [RegistrationCollectionProxy] the cleared registration proxy
      def clear_registrations_for!(identifier)
        registrations_for(identifier).clear
      end

      private

      def registrations
        @registrations ||= registration_router_klass.new
      end

      def _process_event(_event)
        raise NotImplementedError
      end

      def _register(_identifier, _params, &_callback)
        raise NotImplementedError
      end

      def _register_method_call(_identifier, _object, _method_name, _params)
        raise NotImplementedError
      end
    end
  end
end
