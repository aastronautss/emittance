# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Event do
  before do
    stub_const 'FooEvent', Class.new(Emittance::Event)
    stub_const 'BarEvent', Class.new(Emittance::Event)
  end

  context 'class methods' do
    subject { FooEvent }

    describe 'add_identifier' do
      it 'sets the new identifier' do
        subject.add_identifier :my_new_foo
        expect(subject.identifier).to eq(:my_new_foo)
      end

      it 'raises for invalid identifiers' do
        expect { subject.add_identifier 5 }.to raise_error(Emittance::InvalidIdentifierError)
      end

      it 'raises when an identifier is already taken' do
        BarEvent.add_identifier :dont_take_me_please
        expect { subject.add_identifier :dont_take_me_please }.to raise_error(Emittance::IdentifierTakenError)
      end

      it 'raises when a class already resolves to the identifier' do
        expect { BarEvent.add_identifier :foo }.to raise_error(Emittance::IdentifierTakenError)
      end
    end
  end
end
