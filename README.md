[![Build Status](https://travis-ci.org/aastronautss/emittance.svg?branch=master)](https://travis-ci.org/aastronautss/emittance) [![Maintainability](https://api.codeclimate.com/v1/badges/b5900e32c5a385c96c95/maintainability)](https://codeclimate.com/github/aastronautss/emittance/maintainability)

# Emittance

Emittance is a flexible eventing library that provides a clean interface for both emitting and capturing events. It follows the following workflow:

1. Objects (and therefore, classes) can emit events, identified by a symbol.
2. Events are objects that know who emitted them. Their
3. Objects (and therefore, classes) can watch for events that get emitted.

Per this pattern, objects are responsible for knowing what events they want to listen to. While this is pragmatically the same as a "push"-style message system (watchers don't need to go check a topic themselves), the semantics are a little different.

I created this library because I was dissatisfied with the options currently available, and I wanted to see if I could make something that I would enjoy using.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'emittance'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install emittance

## Usage

If you want a class and its instances to be able to emit events, have it extend `Emittance::Emitter`.

```ruby
class Foo
  extend Emittance::Emitter
end
```

Emitters can emit events like so:

```ruby
my_foo = Foo.new
my_foo.emit :something_happened
Foo.emit :something_else_happened # Classes who extended Emitter can also emit events!
```

As you can see, event types are identified by a symbol. More on that later. You can also pass in an optional payload, which can be any object:

```ruby
my_foo.emit :something_happened, "Here's a payload!"
```

The above examples are cool, but it's generally a better idea to have an object emit its own events:

```ruby
class Foo
  extend Emittance::Emitter

  def make_something_happen
    emit :something_happened, "Here's a payload!"
  end
end

my_foo = Foo.new
my_foo.make_something_happen
```

What happens with these events? Watchers are objects that capture these event emissions. You can set up a watcher by including or extending `Emittance::Watcher`:

```ruby
class Bar
  extend Emittance::Watcher
end
```

To watch for these events, you can just call the `watch` method, which takes the symbol identifier and a block that serves as a callback:

```ruby
Bar.watch :something_happened do |event|
  puts 'Something definitely happened!'
  puts event.identifier.inspect
  puts event.payload
end

my_foo.make_something_happen
# prints:
# Something definitely happened!
# :something_happened
# Here's a payload!
```

Note that the block gets passed an "event" object, which has some attributes. See the docs for more details.

You can also make `watch` call a method:

```ruby
class Bar
  extend Emittance::Watcher

  def self.greet(event)
    puts 'Hello, something must have happened!'
    puts event.identifier.inspect
    puts event.payload
  end
end

Bar.watch :something_happened, :greet

my_foo.make_something_happen
# prints:
# Hello, something must have happened!
# :something_happened
# Here's a payload!
```

Those are the basics--for more info, check the docs!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aastronautss/emittance.
