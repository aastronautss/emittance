# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Notifier do
  let(:subject) { Emittance::SpecFixtures::FooNotifier }

  it 'calls methods of the same name as the event\'s identifier' do
    expect(Emittance::SpecFixtures::FooNotifier).to receive(:foo).with(kind_of Emittance::Event)

    Emittance::SpecFixtures::FooEmitter.new.emit_foo
  end
end
