# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Dispatcher do
  subject { Emittance::Dispatcher }

  describe '.process_event' do
    let(:event) { double 'event' }
    let(:action) { subject.process_event event }

    it 'raises an error' do
      expect { action }.to raise_error(NotImplementedError)
    end

    it 'calls the middleware' do
      expect { action }.to raise_error(NotImplementedError)
    end
  end

  describe '.register' do
    let(:identifier) { double 'identifier' }
    let(:action) { subject.register(identifier) }

    it 'raises an error' do
      expect { action }.to raise_error(NotImplementedError)
    end
  end

  describe '.register_method_call' do
    let(:identifier) { double 'identifier' }
    let(:object) { double 'object' }
    let(:method_name) { double 'method_name' }
    let(:action) { subject.register_method_call(identifier, object, method_name) }

    it 'raises an error' do
      expect { action }.to raise_error(NotImplementedError)
    end
  end
end
