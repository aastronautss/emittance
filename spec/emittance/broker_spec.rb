# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Broker do
  describe '.process_event' do
    it 'raises an error when not subclassed' do
      expect { Emittance::Broker.process_event(:foo) }.to raise_error(NotImplementedError)
    end
  end
end
