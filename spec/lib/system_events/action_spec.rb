require 'spec_helper'

class SystemEvents::Action::MyActionHandler
  def handle_call
    action.my_action_handled!
  end
end

class SystemEvents::Action::MyAction
  include SystemEvents::Action

  def call
    'bar'
  end

  def my_action_handled!
    'handled!'
  end
end

describe SystemEvents::Action do
  describe 'action #call workflow' do
    it 'invokes the handler class' do
      action = SystemEvents::Action::MyAction.new

      expect(action).to receive(:my_action_handled!).once

      action.call
    end

    it 'allows #call to return its own value' do
      expect(SystemEvents::Action::MyAction.new.call).to eq('bar')
    end
  end
end
