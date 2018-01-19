# frozen_string_literal: true

require 'spec_helper'
require 'emittance/middleware/logging'

RSpec.describe Emittance::Middleware::Logging do
  let(:logger_double) { double 'logger', info: nil }
  subject { Emittance::Middleware::Logging }

  before do
    @prior_middleware = Emittance::Middleware.instance_variable_get '@registered_middlewares'
    Emittance::Middleware.instance_variable_set '@registered_middlewares', [subject]

    @prior_logger = Emittance::Middleware::Logging.current_logger
    Emittance::Middleware::Logging.current_logger = logger_double

    Emittance::SpecFixtures::FooWatcher.watch(:foo) { nil }
  end

  after do
    Emittance::Middleware::Logging.current_logger = @prior_logger
    Emittance::Middleware.instance_variable_set '@registered_middlewares', @prior_middleware
  end

  describe '#up' do
    let(:action) { Emittance::SpecFixtures::FooEmitter.new.emit_foo }

    it 'sends something to logger' do
      expect(logger_double).to receive(:info)

      action
    end
  end
end
