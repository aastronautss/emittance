require 'spec_helper'

describe SystemEvents::Emitter do
  class Foo
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

      Foo.new.foo
    end

    it 'doesn\t disrupt normal operation' do
      expect(Foo.new.foo).to eq('bar')
    end
  end

  describe '#emit' do
    it 'sends a message to the broker' do
      payload = ['hello', 'world']

      expect(SystemEvents::Broker).to(
        receive(:process_event).with('foo', kind_of(Time), Foo, ['hello', 'world'])
      )

      Foo.emit 'foo', *payload
    end

    it 'can be called from an instance' do
      payload = ['hello', 'world']

      expect(SystemEvents::Broker).to(
        receive(:process_event).with('foo', kind_of(Time), kind_of(Foo), ['hello', 'world'])
      )

      Foo.new.emit 'foo', *payload
    end
  end
end
