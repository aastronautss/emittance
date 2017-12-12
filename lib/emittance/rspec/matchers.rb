# frozen_string_literal: true

require 'emittance'

require 'rspec/expectations'
require 'rspec/mocks'

RSpec::Matchers.define :emit do |expected_identifier|
  def event_with_identifier(identifier)
    event_klass = Emittance::EventLookup.find_event_klass(identifier)

    satisfy { |expected_identifier| event_klass.identifiers.include? expected_identifier }
  end

  match do |emitter|
    emitter.is_a?(Emittance::Emitter::ClassAndInstanceMethods) &&
      receive(:emit).with(event_with_identifier(expected_identifier), anything)
  end

  chain :and_propagate do

  end

  failure_message do |emitter|
    "expected that #{emitter} would emit an event identified by #{expected_identifier}, but did not"
  end

  failure_message_when_negated do |emitter|
    "expected that #{emitter} would not emit an event identified by #{expected_identifier}, but it did"
  end
end
