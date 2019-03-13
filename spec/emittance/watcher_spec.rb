# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Watcher do
  before do
    stub_const('Foo', Class.new { extend Emittance::Emitter })
    stub_const('Bar', Class.new { include Emittance::Watcher })
  end

  after { Emittance.dispatcher.clear_registrations! }

  describe '#watch' do
    it 'watches for emissions' do
      tester = double 'tester'
      expect(tester).to receive(:test_me)

      my_bar = Bar.new
      my_bar.watch(:test_foo) { |_| tester.test_me }

      Foo.emit :test_foo, payload: 'bar'
    end

    it 'passes the payload along' do
      tester = double('tester')
      expect(tester).to receive(:test_me).with(kind_of(Emittance::Event))

      my_bar = Bar.new
      my_bar.watch(:test_foo) { |event| tester.test_me(event) }

      Foo.emit :test_foo, payload: 'bar'
    end

    it 'can take a method name as a param instead of a block' do
      my_bar = Bar.new
      my_bar.watch :test_foo, :foo_emitted

      expect(my_bar).to receive(:foo_emitted)

      Foo.emit :test_foo, payload: 'bar'
    end

    context 'with multiple brokers' do
      let(:dispatcher1) { double 'dispatcher', process_event: nil }
      let(:dispatcher2) { double 'dispatcher', process_event: nil }
      let(:broker1) { double 'broker1', process_event: nil, dispatcher: dispatcher1 }
      let(:broker2) { double 'broker2', process_event: nil, dispatcher: dispatcher2 }

      before do
        @previous_brokers = Emittance::Brokerage::Registry.instance_variable_get('@brokers')
        Emittance::Brokerage::Registry.instance_variable_set('@brokers', {})

        Emittance::Brokerage.register_broker(broker1, :broker1)
        Emittance::Brokerage.register_broker(broker2, :broker2)
      end

      after { Emittance::Brokerage::Registry.instance_variable_set('@brokers', @previous_brokers) }

      it 'can watch on a specific broker' do
        expect(dispatcher1).to receive(:register).with(:something_happened, kind_of(Hash))
        expect(dispatcher2).to receive(:register).with(:something_happened, kind_of(Hash))

        bar1 = Bar.new

        bar1.watch(:something_happened, broker: :broker1) { |event| print event.payload }
        bar1.watch(:something_happened, broker: :broker2) { |event| print event.payload }
      end
    end

  end
end
