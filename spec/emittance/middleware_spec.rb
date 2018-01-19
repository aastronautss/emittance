# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Middleware do
  subject { Emittance::Middleware }

  let(:event) { double 'event', ping: :pong }

  before do
    @existing_registrations = Emittance::Middleware.instance_variable_get '@registered_middlewares'
    Emittance::Middleware.instance_variable_set '@registered_middlewares', []
  end

  after do
    Emittance::Middleware.instance_variable_set '@registered_middlewares', @existing_registrations
  end

  describe '.register' do
    let(:klass) { Class.new }
    let(:action) { subject.register klass }

    it 'adds to the list of registrations' do
      expect { action }.to change { subject.registered_middlewares.length }.by(1)
    end

    it 'adds the right thing to the registrations' do
      action
      expect(subject.registered_middlewares.last).to eq(klass)
    end
  end

  describe '.clear_registrations!' do
    let(:klass) { Class.new }
    let(:action) { subject.clear_registrations! }

    it 'removes all registrations' do
      Emittance::Middleware.register klass
      expect { action }.to change { subject.registered_middlewares.length }.by(-1)
      expect(subject.registered_middlewares).to be_empty
    end
  end

  describe '.up' do
    let(:action) { Emittance::Middleware.up(event) }

    it 'returns the event' do
      expect(action).to eq(event)
    end

    context 'with registrations' do
      let(:test_middleware) do
        Class.new(Emittance::Middleware) do
          def up
            event.instance_variable_set '@ping', :pong
            event.ping
            event
          end
        end
      end

      before do
        Emittance::Middleware.register(test_middleware)
      end

      it 'calls the middleware stack' do
        expect(event).to receive(:ping)
        action
        expect(event.instance_variable_get '@ping').to eq(:pong)
      end
    end
  end

  describe '.down' do
    let(:action) { Emittance::Middleware.down(event) }

    it 'returns the event' do
      expect(action).to eq(event)
    end

    context 'with registrations' do
      let(:test_middleware) do
        Class.new(Emittance::Middleware) do
          def down
            event.instance_variable_set '@ping', :pong
            event.ping
            event
          end
        end
      end

      before { Emittance::Middleware.register(test_middleware) }

      it 'calls the middleware stack' do
        expect(event).to receive(:ping)
        action
        expect(event.instance_variable_get '@ping').to eq(:pong)
      end
    end
  end

  describe '#up' do
    subject { Emittance::Middleware.new(event) }
    let(:action) { subject.up }

    it 'returns the event' do
      expect(action).to eq(event)
    end
  end

  describe '#down' do
    subject { Emittance::Middleware.new(event) }
    let(:action) { subject.down }

    it 'returns the event' do
      expect(action).to eq(event)
    end
  end
end
