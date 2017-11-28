require 'spec_helper'

describe SystemEvents::Watcher do
  before do
    stub_const('Foo', Class.new { extend SystemEvents::Emitter })
    stub_const('Bar', Class.new { include SystemEvents::Watcher })
  end

  after { SystemEvents::Broker.clear_registrations! }

  describe '#watch' do
    it 'watches for emissions' do
      tester = double('tester')
      expect(tester).to receive(:test_me)

      my_bar = Bar.new
      my_bar.watch(:test_foo) { |_| tester.test_me }

      Foo.emit :test_foo, 'bar'
    end

    it 'passes the payload along' do
      tester = double('tester')
      expect(tester).to receive(:test_me).with(kind_of(SystemEvents::Event))

      my_bar = Bar.new
      my_bar.watch(:test_foo) { |event| tester.test_me(event) }

      Foo.emit :test_foo, 'bar'
    end
  end
end
