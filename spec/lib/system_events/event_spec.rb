require 'spec_helper'

describe SystemEvents::Event do
  class SystemEvents::Event::FooHandler
    def handle_call
      event.foo_handled!
    end
  end

  class SystemEvents::Event::Foo
    include SystemEvents::Event

    def call
      'bar'
    end

    def foo_handled!
      nil
    end
  end
  
  describe 'event #call workflow' do
    it 'invokes the handler class' do
      event = SystemEvents::Event::Foo.new
      expect(event).to receive(:foo_handled!).once

      event.call
    end

    it 'allows #call to return its own value' do
      expect(SystemEvents::Event::Foo.new.call).to eq('bar')
    end
  end
end
