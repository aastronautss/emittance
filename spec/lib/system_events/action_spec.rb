require 'spec_helper'

describe SystemEvents::Action do
  class SystemEvents::Action::FooHandler
    def handle_call
      event.foo_handled!
    end
  end

  class SystemEvents::Action::Foo
    include SystemEvents::Action

    def call
      'bar'
    end

    def foo_handled!
      nil
    end
  end

  describe 'event #call workflow' do
    it 'invokes the handler class' do
      event = SystemEvents::Action::Foo.new
      expect(event).to receive(:foo_handled!).once

      event.call
    end

    it 'allows #call to return its own value' do
      expect(SystemEvents::Action::Foo.new.call).to eq('bar')
    end
  end
end
