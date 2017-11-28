require 'spec_helper'

describe SystemEvents::Emitter do
  class SystemEvents::Emitter::Foo
    extend SystemEvents::Emitter

    def foo
      'bar'
    end
    emits_on :foo
  end

  before do
    SystemEvents.disable
  end

  describe '.emits_on' do
    it 'sends a message to the broker' do
      expect(SystemEvents::Broker).to receive(:process_event).with(kind_of SystemEvents::Event)

      SystemEvents::Emitter::Foo.new.foo
    end

    it 'doesn\t disrupt normal operation' do
      expect(SystemEvents::Emitter::Foo.new.foo).to eq('bar')
    end
  end

  describe '#emit' do
    it 'sends a message to the broker' do
      payload = ['hello', 'world']

      expect(SystemEvents::Broker).to receive(:process_event).with(kind_of SystemEvents::Event)

      SystemEvents::Emitter::Foo.emit :foo, payload
    end

    it 'can be called from an instance' do
      payload = ['hello', 'world']

      expect(SystemEvents::Broker).to receive(:process_event).with(kind_of SystemEvents::Event)

      SystemEvents::Emitter::Foo.new.emit 'foo', payload
    end
  end
end
