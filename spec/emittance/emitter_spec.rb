# froze_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Emitter do
  class Emittance::Emitter::Foo
    extend Emittance::Emitter

    def foo
      'bar'
    end
    emits_on :foo
  end

  describe '.emits_on' do
    it 'sends a message to the broker' do
      expect(Emittance::Broker).to receive(:process_event).with(kind_of Emittance::Event)

      Emittance::Emitter::Foo.new.foo
    end

    it 'doesn\t disrupt normal operation' do
      expect(Emittance::Emitter::Foo.new.foo).to eq('bar')
    end
  end

  describe '#emit' do
    it 'sends a message to the broker' do
      payload = ['hello', 'world']

      expect(Emittance::Broker).to receive(:process_event).with(kind_of Emittance::Event)

      Emittance::Emitter::Foo.emit :foo, payload
    end

    it 'can be called from an instance' do
      payload = ['hello', 'world']

      expect(Emittance::Broker).to receive(:process_event).with(kind_of Emittance::Event)

      Emittance::Emitter::Foo.new.emit 'foo', payload
    end
  end
end
