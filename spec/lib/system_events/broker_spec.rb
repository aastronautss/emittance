require 'spec_helper'

describe SystemEvents::Broker do
  subject { SystemEvents::Broker }

  describe '.register' do
    it 'stores a registration' do
      subject.register('foo') { |_| puts 'bar' }

      expect(subject.instance_variable_get('@registrations')['foo']).to be_present
    end
  end

  describe '.process_event' do
    after { subject.clear_registrations! }

    it 'runs the registered callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      subject.register('foo') do
        tester.bar
      end

      subject.process_event 'foo', Time.now
    end

    it 'passes params into the callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      subject.register('foo') do |identifier, timestamp, emitter, payload|
        expect(identifier).to eq('foo')
        expect(timestamp).to be_a(Time)
        expect(payload).to be_a(Array)

        tester.bar
      end

      subject.process_event 'foo', Time.now
    end
  end

  describe '.clear_registrations_for!' do
    let(:action) { subject.clear_registrations_for! 'foo' }
    after { subject.clear_registrations! }

    it 'clears a registration' do
      subject.register('foo') { puts 'bar' }

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
