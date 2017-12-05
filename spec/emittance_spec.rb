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
end
