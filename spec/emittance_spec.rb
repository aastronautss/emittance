# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance do
  after { Emittance.enable! }

  describe 'enabling and disabling' do
    it 'returns true when enabled' do
      Emittance.enable!

      expect(Emittance.enabled?).to be(true)
    end

    it 'returns false when disabled' do
      Emittance.disable!

      expect(Emittance.enabled?).to be(false)
    end
  end

  describe '.use_middleware' do
    let(:middleware) { Class.new(Emittance::Middleware) }
    let(:action) { Emittance.use_middleware middleware }

    it 'delegates' do
      expect(Emittance::Middleware).to receive(:register).with([middleware])

      action
    end
  end

  describe '.clear_middleware!' do
    let(:action) { Emittance.clear_middleware! }

    it 'delegates' do
      expect(Emittance::Middleware).to receive(:clear_registrations!)

      action
    end
  end

  describe 'interface contracts' do
    specify { expect(Emittance::Middleware).to respond_to(:register).with(1).argument }
    specify { expect(Emittance::Middleware).to respond_to(:clear_registrations!) }
  end
end
