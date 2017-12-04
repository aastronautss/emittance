require 'spec_helper'

RSpec.describe Emittance::Watcher do
  before do
    stub_const('Foo', Class.new { extend Emittance::Emitter })
    stub_const('Bar', Class.new { include Emittance::Watcher })
  end

  after { Emittance::Dispatcher.clear_registrations! }

  describe '#watch' do
    it 'watches for emissions' do
      tester = double 'tester'
      expect(tester).to receive(:test_me)

      my_bar = Bar.new
      my_bar.watch(:test_foo) { |_| tester.test_me }

      Foo.emit :test_foo, 'bar'
    end

    it 'passes the payload along' do
      tester = double('tester')
      expect(tester).to receive(:test_me).with(kind_of(Emittance::Event))

      my_bar = Bar.new
      my_bar.watch(:test_foo) { |event| tester.test_me(event) }

      Foo.emit :test_foo, 'bar'
    end

    it 'can take a method name as a param instead of a block' do
      my_bar = Bar.new
      my_bar.watch :test_foo, :foo_emitted

      expect(my_bar).to receive(:foo_emitted)

      Foo.emit :test_foo, 'bar'
    end
  end
end
