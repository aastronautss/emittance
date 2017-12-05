# froze_string_literal: true

require 'spec_helper'

class Emittance::Action::MyAction
  include Emittance::Action

  def call
    'bar'
  end

  def my_action_handled!
    'handled!'
  end
end

class Emittance::Action::MyActionHandler
  def handle_call
    action.my_action_handled!
  end
end

RSpec.describe Emittance::Action do
  describe 'action #call workflow' do
    it 'invokes the handler class' do
      action = Emittance::Action::MyAction.new

      expect(action).to receive(:my_action_handled!).once

      action.call
    end

    it 'allows #call to return its own value' do
      expect(Emittance::Action::MyAction.new.call).to eq('bar')
    end
  end
end
