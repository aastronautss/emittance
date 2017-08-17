require 'spec_helper'

describe SystemEvents::Broker do
  describe '.register' do
    it 'stores a registration' do
      SystemEvents::Broker.register('foo') { |_| puts 'bar' }

      expect(SystemEvents::Broker.instance_variable_get('@registrations')[:foo]).to be_present
    end
  end

  describe '.process_event' do
    it 'runs the registered callback' do
      SystemEvents::Broker.register('foo') { |_| puts 'bar' }
    end
  end
end
