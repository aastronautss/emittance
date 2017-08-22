require 'spec_helper'

describe SystemEvents::Broker do
  describe '.register' do
    it 'stores a registration' do
      SystemEvents::Broker.register('foo') { |_| puts 'bar' }

      expect(SystemEvents::Broker.instance_variable_get('@registrations')[:foo]).to be_present
    end
  end

  describe '.process_event' do
    after { SystemEvents::Broker.clear_registrations! }

    it 'runs the registered callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      SystemEvents::Broker.register('foo') do
        tester.bar
      end

      SystemEvents::Broker.process_event 'foo', Time.now
    end

    it 'passes params into the callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      SystemEvents::Broker.register('foo') do |identifier, timestamp, payload|
        expect(identifier).to be_a(Symbol)
        expect(timestamp).to be_a(Time)
        expect(payload).to be_a(Array)

        tester.bar
      end

      SystemEvents::Broker.process_event 'foo', Time.now
    end
  end
end
