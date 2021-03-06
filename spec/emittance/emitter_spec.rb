# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Emitter do
  describe '.emits_on' do
    it 'sends a message to the dispatcher' do
      expect(Emittance.dispatcher).to receive(:process_event).with(kind_of Emittance::Event)

      Emittance::SpecFixtures::FooEmitter.new.do_something
    end

    it 'doesn\t disrupt normal operation' do
      expect(Emittance::SpecFixtures::FooEmitter.new.do_something).to eq('return value')
    end
  end

  describe '#emit' do
    it 'sends a message to the dispatcher' do
      payload = ['hello', 'world']

      expect(Emittance.dispatcher).to receive(:process_event).with(kind_of Emittance::Event)

      Emittance::SpecFixtures::FooEmitter.emit :foo, payload: payload
    end

    it 'can be called from an instance' do
      payload = ['hello', 'world']

      expect(Emittance.dispatcher).to receive(:process_event).with(kind_of Emittance::Event)

      Emittance::SpecFixtures::FooEmitter.new.emit 'foo', payload: payload
    end
  end
end
