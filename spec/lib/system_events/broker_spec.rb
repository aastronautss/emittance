require 'spec_helper'

describe SystemEvents::Broker do
  before { stub_const 'SystemEvents::Broker::FooEvent', Class.new(SystemEvents::Event) }

  let(:emitter) { double 'emitter' }
  let(:timestamp) { Time.now }
  let(:payload) { 'hello' }
  let(:event) { SystemEvents::Broker::FooEvent.new emitter, timestamp, payload }

  subject { SystemEvents::Broker }

  describe '.register' do
    it 'stores a registration' do
      subject.register('foo') { |_| 'bar' }

      expect(subject.instance_variable_get('@registrations')[:system_events_broker_foo]).to be_present
    end
  end

  describe '.process_event' do
    after { subject.clear_registrations! }

    it 'runs the registered callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      subject.register(:system_events_broker_foo) do
        tester.bar
      end

      subject.process_event event
    end

    it 'passes params into the callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      subject.register(:system_events_broker_foo) do |event|
        expect(event.identifier).to eq(:system_events_broker_foo)
        expect(event.timestamp).to be_a(Time)
        expect(event.payload).to eq('hello')

        tester.bar
      end

      subject.process_event event
    end
  end

  describe '.clear_registrations_for!' do
    let(:action) { subject.clear_registrations_for! :system_events_broker_foo }
    after { subject.clear_registrations! }

    it 'clears a registration' do
      subject.register(:system_events_broker_foo) { 'bar' }

      action
      expect(subject.registrations_for('foo')).to be_empty
    end

    it 'does not clear registrations for other identifiers' do
      subject.register('foo') { puts 'bar' }
      subject.register('bar') { puts 'baz' }

      action
      expect(subject.registrations_for('bar')).to_not be_empty
    end
  end

  describe '.clear_registrations!' do
    let(:action) { subject.clear_registrations! }

    it 'clears a registration' do
      subject.register('foo') { puts 'bar' }

      action
      expect(subject.registrations_for('foo')).to be_empty
    end

    it 'clears multiple registrations' do
      subject.register('foo') { puts 'bar' }
      subject.register('bar') { puts 'baz' }

      action
      expect(subject.registrations_for('foo')).to be_empty
      expect(subject.registrations_for('bar')).to be_empty
    end
  end
end
