# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Middleware do
  subject { Emittance::Middleware }

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

  describe '.up' do
    let(:test_middleware) do
      Class.new(Emittance::Middleware) do
        def up
          event.instance_variable_set '@ping', :pong
          event.ping
          event
        end
      end
    end
    let(:event) { double 'event', ping: :pong }
    let(:action) { Emittance::Middleware.up(event) }

    before { Emittance::Middleware.register(test_middleware) }

    it 'calls the middleware stack' do
      expect(event).to receive(:ping)
      action
      expect(event.instance_variable_get '@ping').to eq(:pong)
    end
  end
end
