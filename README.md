[![Build Status](https://travis-ci.org/aastronautss/emittance.svg?branch=master)](https://travis-ci.org/aastronautss/emittance)

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

Coming soon!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aastronauts/emittance.
