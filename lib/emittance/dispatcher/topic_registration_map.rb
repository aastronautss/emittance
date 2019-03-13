require 'set'

module Emittance
  class Dispatcher
    ##
    # Tracks registrations for a set of topics.
    #
    # == Structure & Registration
    #
    # A +TopicRegistrationMap+ is structured like a hash, where the keys are topic parts, and the values are something
    # called a +Mapping+. A +Mapping+ is a struct containing a set of subscriptions for its immediate topic level, as
    # well as another +TopicRegistrationMap+. This forms a tree-like structure. For example, if we have a set of
    # subscriptions on the following topics (their index is denoted above each element for clarity:
    #
    #               #   0    1    2    3    4      5      6    7      8      9      10       11       12
    #   routing_key = ['*', '*', '*', '*', '*.b', '*.b', 'a', 'a.*', 'a.*', 'a.*', 'a.*.c', 'a.*.c', 'a.a']
    #
    # We could register them each using the {#register} method:
    #
    #   registrations = TopicRegistrationMap.new
    #
    #   routing_key.each_with_index do |routing_key, idx|
    #     registrations.register(routing_key, idx)
    #   end
    #
    # The resulting map would look like this:
    #
    #   root map:
    #     *:
    #       subscriptions: [0, 1, 2, 3]
    #       map:
    #         b:
    #           subscriptions: [4, 5]
    #     a:
    #       subscriptions: [6]
    #       map:
    #         *:
    #           subscriptions: [7, 8, 9]
    #           map:
    #             c:
    #               subscriptions: [10, 11]
    #         a:
    #           subscriptions: [12]
    #
    # == Lookup
    #
    # Suppose we publish to the topic +a.a+. We can use the {#[]} method to fetch all the subscriptions relevant to
    # that topic:
    #
    #   registrations['a.a'] # => [7, 8, 9, 12]
    #
    class TopicRegistrationMap
      Subscription = Struct.new(:routing_key, :registration)

      # @param root [TopicRegistrationMap] (private API)
      def initialize(root = nil)
        @root = root
      end

      # @private
      def root
        @root || self
      end

      # @private
      def mappings
        @mappings ||= new_mappings
      end

      # Looks up subscriptions whose registrations match the given topic.
      #
      # @param topic_or_event [#to_s, Emittance::Event] the topic or event for which you wish to look up subscriptions
      # @return [Enumerable] the set of subscriptions
      def [](topic_or_event)
        topic, head, tail, parts = process_routing_key(topic_or_event)

        items = parts.length == 1 ? my_subscriptions(head, original_lookup: topic) : child_subscriptions(head, tail)

        Result.new(root, topic, items)
      end

      # @private
      def subscriptions_for_exactly(topic_part, original_lookup:)
        Result.new(root, original_lookup, mappings[topic_part].subscriptions)
      end

      # @private
      def all_child_subscriptions_for_exactly(topic_part, original_lookup:)
        mappings.values.reduce(Result.new(root, original_lookup, Set.new)) do |result, mapping|
          result + mapping.map.subscriptions_for_exactly(topic_part, original_lookup: original_lookup)
        end
      end

      # Registers a subscription to the given routing key.
      #
      # @param routing_key [#to_s] the routing key that you wish to subscribe to
      # @param registration [Object] the registration you wish to store under that routing key
      # @param original_routing_key [#to_s] (private API)
      def register(routing_key, registration, original_routing_key: nil)
        routing_key, head, tail, parts = process_routing_key(routing_key)
        original_routing_key ||= routing_key

        mapping = mappings[head]

        if parts.length == 1
          mapping << Subscription.new(original_routing_key, registration)
        else
          mapping.map.register(tail, registration, original_routing_key: original_routing_key)
        end
      end

      # Clears registrations associated with a given routing key.
      #
      # @param routing_key [#to_s] the routing key the registrations for which you with to clear from this map
      def clear_registrations_for(routing_key)
        routing_key, head, tail, parts = process_routing_key(routing_key)

        mapping = mappings[head]

        if parts.length == 1
          mapping.subscriptions.clear
        else
          mapping.map.clear_registrations_for(tail)
        end
      end

      def clear
        @mappings = new_mappings
      end

      private

      def my_subscriptions(head, original_lookup:)
        mappings['#'].subscriptions +
          mappings['*'].subscriptions +
          mappings[head].subscriptions +
          mappings[head].map.subscriptions_for_exactly('#', original_lookup: original_lookup) +
          mappings['*'].map.subscriptions_for_exactly('#', original_lookup: original_lookup) +
          mappings['#'].map.subscriptions_for_exactly(head, original_lookup: original_lookup) +
          mappings['#'].map.subscriptions_for_exactly('*', original_lookup: original_lookup)
      end

      def child_subscriptions(head, tail)
        Result.new(root, tail, mappings['#'].subscriptions) +
          child_subscriptions_for_hash_on_tail(tail) +
          mappings['*'].map[tail] +
          mappings[head].map[tail]
      end

      def child_subscriptions_for_hash_on_tail(routing_key)
        original_routing_key = routing_key
        result = Result.new(root, original_routing_key)

        while parts_for_routing_key(routing_key).length > 0
          routing_key, _, tail, _ = process_routing_key(routing_key)
          result += Result.new(root, original_routing_key, mappings['#'].map[routing_key].items)

          routing_key = tail
        end

        result
      end

      def process_routing_key(routing_key)
        routing_key = normalize_routing_key(routing_key)
        parts = parts_for_routing_key(routing_key)
        tail = routing_key_for_parts(parts[1..-1])

        [routing_key, parts.first, tail, parts]
      end

      def normalize_routing_key(routing_key)
        if routing_key.is_a?(Emittance::Event)
          routing_key.topic
        elsif routing_key.to_s == '@all' # support for legacy special identifier
          '#'
        else
          routing_key
        end
      end

      def parts_for_routing_key(routing_key)
        routing_key.to_s.split('.')
      end

      def routing_key_for_parts(parts)
        parts.join('.')
      end

      def new_mappings
        Hash.new { |h, k| h[k] = Mapping.new(root) }
      end

      # @private
      class Mapping
        attr_reader :root_map

        def initialize(root_map)
          @root_map = root_map
        end

        def push(new_subscription)
          subscriptions << new_subscription
        end

        alias << push

        def subscriptions
          @subscriptions ||= Set.new
        end

        def map
          @map ||= TopicRegistrationMap.new(root_map)
        end
      end

      # @private
      class Result
        include Enumerable

        attr_reader :root_map, :lookup_key, :items

        def initialize(root_map, lookup_key, items = Set.new)
          @root_map = root_map
          @lookup_key = lookup_key
          @items = items
        end

        def each
          return enum_for(:each) unless block_given?

          items.each { |item| item.respond_to?(:registration) ? yield(item.registration) : yield(item) }
        end

        # Adds a subscription to the root mapping. This is set up all wonky in this manner with a (sort of) circular
        # reference because the original API was set up this way. This allows us to add subscriptions to the
        # collection itself.
        def push(new_subscription)
          root_map.register(lookup_key, new_subscription)
        end

        alias << push

        def +(other_collection)
          unless root_map == other_collection.root_map && lookup_key == other_collection.lookup_key
            raise ArgumentError, 'Cannot add two Results with different root_maps or lookup_keys'
          end

          self.class.new(root_map, lookup_key, items + other_collection.items)
        end

        def empty?
          items.empty?
        end

        def length
          items.length
        end

        alias size length
        alias count length

        def first
          items.first
        end

        def last
          items.last
        end

        def clear
          root_map.clear_registrations_for(lookup_key)
        end
      end
    end
  end
end
