# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Event do
  describe 'class methods' do
    describe '.add_identifier' do
      before do
        @previous_lookup = Emittance::Event.lookup_strategy
        Emittance::Event.lookup_strategy = :classical

        stub_const 'FooEvent', Class.new(Emittance::Event)
        stub_const 'BarEvent', Class.new(Emittance::Event)
      end

      after { Emittance::Event.lookup_strategy = @previous_lookup }

      subject { FooEvent }

      it 'sets the new identifier' do
        subject.add_identifier :my_new_foo
        expect(subject.identifiers).to include(:my_new_foo)
      end

      it 'raises for invalid identifiers' do
        expect { subject.add_identifier 5 }.to raise_error(Emittance::InvalidIdentifierError)
      end

      it 'raises when an identifier is already taken' do
        BarEvent.add_identifier :dont_take_me_please
        expect { subject.add_identifier :dont_take_me_please }.to raise_error(Emittance::IdentifierCollisionError)
      end

      it 'raises when a class already resolves to the identifier' do
        expect { BarEvent.add_identifier :foo }.to raise_error(Emittance::IdentifierCollisionError)
      end
    end
  end

  describe '#identifiers' do
    context 'with topical lookup strategy' do
      before do
        @previous_lookup = Emittance::Event.lookup_strategy
        Emittance::Event.lookup_strategy = :topical
      end

      after { Emittance::Event.lookup_strategy = @previous_lookup }

      subject { Emittance::Event.new(nil, Time.now, nil).tap { |event| event.topic = 'foo.bar' } }

      it "returns the event's topic" do
        expect(subject.identifiers).to eq(['foo.bar'])
      end
    end
  end
end
