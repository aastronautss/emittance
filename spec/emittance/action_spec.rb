# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Action do
  describe 'action #call workflow' do
    it 'invokes the handler class' do
      action = Emittance::SpecFixtures::FooAction.new

      expect(action).to receive(:foo_action_handled!).once

      action.call
    end

    it 'allows #call to return its own value' do
      expect(Emittance::SpecFixtures::FooAction.new.call).to eq('bar')
    end
  end
end
