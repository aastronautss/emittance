require 'spec_helper'

RSpec.describe Emittance::Dispatcher do
  before do
    stub_const 'Emittance::Dispatcher::FooEvent', Class.new(Emittance::Event)
    stub_const 'Emittance::Dispatcher::BarEvent', Class.new(Emittance::Event)

    @previous_registrations = Emittance::Dispatcher.instance_variable_get '@registrations'
    Emittance::Dispatcher.instance_variable_set '@registrations', {}
  end

  after do
    Emittance::Dispatcher.instance_variable_set '@registrations', @previous_registrations
  end

  let(:emitter) { double 'emitter' }
  let(:timestamp) { Time.now }
  let(:payload) { 'hello' }
  let(:event) { Emittance::Dispatcher::FooEvent.new emitter, timestamp, payload }

  subject { Emittance::Dispatcher }

  describe '.register' do
    it 'stores a registration' do
      subject.register(:emittance_dispatcher_foo) { |_| 'bar' }

      expect(subject.instance_variable_get('@registrations')[:emittance_dispatcher_foo]).to_not be_empty
    end
  end

  describe '.process_event' do
    it 'runs the registered callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      subject.register(:emittance_dispatcher_foo) do
        tester.bar
      end

      subject.process_event event
    end

    it 'passes params into the callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      subject.register(:emittance_dispatcher_foo) do |event|
        expect(event.identifier).to eq(:emittance_dispatcher_foo)
        expect(event.timestamp).to be_a(Time)
        expect(event.payload).to eq('hello')

        tester.bar
      end

      subject.process_event event
    end
  end

  describe '.clear_registrations_for!' do
    let(:action) { subject.clear_registrations_for! :emittance_dispatcher_foo }

    it 'clears a registration' do
      subject.register(:emittance_dispatcher_foo) { 'bar' }

      action
      expect(subject.registrations_for(:emittance_dispatcher_foo)).to be_empty
    end

    it 'does not clear registrations for other identifiers' do
      subject.register(:emittance_dispatcher_foo) { 'bar' }
      subject.register(:emittance_dispatcher_bar) { 'baz' }

      action
      expect(subject.registrations_for(:emittance_dispatcher_bar)).to_not be_empty
    end
  end

  describe '.clear_registrations!' do
    let(:action) { subject.clear_registrations! }

    it 'clears a registration' do
      subject.register(:emittance_dispatcher_foo) { 'bar' }

      action
      expect(subject.registrations_for(:emittance_dispatcher_foo)).to be_empty
    end

    it 'clears multiple registrations' do
      subject.register(:emittance_dispatcher_foo) { 'bar' }
      subject.register(:emittance_dispatcher_bar) { 'baz' }

      action
      expect(subject.registrations_for(:emittance_dispatcher_foo)).to be_empty
      expect(subject.registrations_for(:emittance_dispatcher_bar)).to be_empty
    end
  end
end
