require 'spec_helper'

RSpec.describe Emittance::Event do
  before do
    stub_const 'FooEvent', Class.new(Emittance::Event)
    stub_const 'BarEvent', Class.new(Emittance::Event)
  end

  context 'class methods' do
    subject { FooEvent }

    describe 'identifier=' do
      it 'sets the new identifier' do
        subject.identifier = :my_new_foo
        expect(subject.identifier).to eq(:my_new_foo)
      end

      it 'raises for invalid identifiers' do
        expect { subject.identifier = 5 }.to raise_error(Emittance::InvalidIdentifierError)
      end

      it 'raises when an identifier is already taken' do
        BarEvent.identifier = :dont_take_me_please
        expect { subject.identifier = :dont_take_me_please }.to raise_error(Emittance::IdentifierTakenError)
      end
    end
  end
end
