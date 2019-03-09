# frozen_string_literal: true

module Emittance
  ##
  # The clearinghouse for brokers. Registers brokers, and decides which broker to use when sent an event. First point of
  # contact for event propagation.
  #
  module Brokerage
    class BrokerNotInUseError < StandardError; end

    @enabled = true

    class << self
      attr_reader :default_broker

      # Sends an event to all brokers that are in-use.
      #
      # @param event [Emittance::Event] the event object
      def send_event(event, middleware: Emittance::Middleware)
        return nil unless enabled?

        event = middleware.up(event)
        brokers_in_use.each { |broker| broker.process_event(event) }
      end

      # @return [Set<Emittance::Broker>]
      def brokers_in_use
        @brokers_in_use ||= Set.new
      end

      # Normalizes broker input in order to provide an interface that allows either a {Emittance::Broker} subclass _or_
      # its identifier to be passed in to a method.
      #
      # @param broker [Class, Symbol, nil] either a broker or its identifier
      def find_broker(broker)
        if brokers_in_use.include?(broker) || (broker.is_a?(Class) && broker <= Emittance::Broker)
          broker
        elsif broker.nil?
          default_broker
        else
          registry.fetch(broker)
        end
      end

      # Checks if a broker is in use in this brokerage.
      #
      # @return [Boolean] true if broker is in use, false otherwise
      def broker_in_use?(broker)
        broker = find_broker(broker)

        brokers_in_use.include?(broker)
      end

      # Adds a broker to the list of {Emittance::Broker} subclasses available. The first broker to be added becomes the
      # default broker.
      #
      # @param broker [Class, Symbol] the symbol you have registered the broker to
      def use_broker(broker)
        broker = find_broker(broker)

        brokers_in_use << broker
        self.default_broker = broker unless default_broker
      end

      # Sets the default broker. If the watcher does not specify the broker, this will be the broker that gets
      def default_broker=(broker)
        broker = find_broker(broker)
        raise BrokerNotInUseError, 'Default broker must be in use' unless broker_in_use?(broker)

        @default_broker = broker
      end

      # If you have created your own broker, this method adds it to the available pool of brokers.
      #
      # Emittance::Brokerage.register_broker MyBroker, :mine
      #
      # @param broker [Class] the broker you would like to register
      # @param identifier [Symbol] the symbol you would like use to point to your registered broker
      def register_broker(broker, identifier)
        registry.register broker, identifier
      end

      def dispatcher_for(broker = nil)
        broker = find_broker(broker)
        broker.dispatcher
      end

      alias dispatcher dispatcher_for

      # @return [Module] the registry containing all broker registrations
      def registry
        Emittance::Brokerage::Registry
      end

      # Enables event propagation.
      def enable!
        self.enabled = true
      end

      # Disables event propagation.
      def disable!
        self.enabled = false
      end

      # @return [Boolean] true if event propagation is enabled, false otherwise
      def enabled?
        enabled
      end

      private

      attr_accessor :enabled
    end

    # @private
    module Registry
      @brokers = {}

      class << self
        attr_reader :brokers

        def register(broker, symbol)
          brokers[symbol.to_sym] = broker
        end

        def fetch(broker_id)
          brokers[broker_id.to_sym]
        end
      end
    end
  end
end
