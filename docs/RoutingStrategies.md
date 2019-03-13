# @title Routing Strategies

# Routing Strategies

Emittance can be configured to use one of several "routing strategies." A routing strategy is a way in which an event is identified so that watchers can decide which events they wish to subscribe to. All routing strategies encapsulate the same following basic ideas:

1. Events have one or more "identifiers." These identifiers are meant to express the "type" of event that was emitted, such as `order_completed`, or `user_logged_in`.
2. Watchers can choose the identifier(s) they wish to subscribe to. Some routing strategies can even allow a watcher to watch for multiple kinds of events with a single identifier. For instance, if we are using the `:topical` routing strategy, we can watch for the identifier `posts.*`, and be able to receive events with the identifier `posts.create` and `posts.destroy`.

## Routing Strategy Architecture

All routing strategies encompass two procedures: the creation of an event, and the registration/retrieval of watcher subscriptions. If you wish to create your own routing strategy, then you must implement both.

### Event Lookup & Creation

Event lookup is a residual feature of the "classical" routing strategy, which created a separate class for a given event identifier. This might eventually be removed in later versions, but for now a routing strategy must provide an object or class that implements three methods: `.identifiers_for_klass`, `.find_event_klass`, and `.register_identifier`.

`.identifiers_for_klass` takes an event class and (optionally) an event object, returning a list of identifiers for that given class. In the future this workflow will be simplified, but for now it is how an event's identifier is determined.

`.find_event_klass` takes an identifier or set of identifiers, returning the relevant event class for those identifiers. With future lookup strategies, this will be unnecessary being that all events will have the same class.

`.register_identifier` adds an identifier to a given event class. This is essentially a no-op with future lookup strategies, but the idea is that a given event type can have multiple identifiers.

### Subscription Registration & Identifier Routing

The primary purpose of a routing strategy is to facilitate the registration and retrieval of subscriptions given a specific event identifier. A routing strategy provides a class the instances of which serve to store subscriptions and route queries. Such a class must implement four instance methods: `#register`, `#[]`, `#clear_registrations_for`, and `#clear`.

`#register` takes an identifier and a subscription object (subscriptions can be anything) and stores the pair for later retrieval.

`#[]` takes an identifier and returns an enumerable collection of subscriptions relevant to that particular identifier. The rules for which subscriptions are returned are up to the author. This method should also return an object which can also be used to add a subscription to the parent registry using the `#<<` method.

```ruby
subscriptions = my_regisration_map['some_identifier']
subscriptions << another_subscription
```

`#clear_registrations_for` takes an identifier and clears all subscriptions relevant to that identifier.

`#clear` clears all subscriptions.
