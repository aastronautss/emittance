# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::EventLookup do
  before do
    stub_const 'Foo', Class.new
    stub_const 'Bar', Class.new
    stub_const 'Foo::Baz', Class.new
    stub_const 'FooBar', Class.new
    stub_const 'FooEvent', Class.new(Emittance::Event)
    stub_const 'FooBarEvent', Class.new(Emittance::Event)
    stub_const 'FooBazEvent', Class.new(Emittance::Event)
  end

  after do
    Emittance::EventLookup::Registry.clear_registrations!
  end

  describe '.find_event_klass' do
    context 'with one argument' do
      it 'passes a "one-word" class straight through' do
        value = Emittance::EventLookup.find_event_klass(Foo)
        expect(value).to eq(FooEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'passes a "two-word" class straight through' do
        value = Emittance::EventLookup.find_event_klass(FooBar)
        expect(value).to eq(FooBarEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'leaves Event classes unchanged' do
        value = Emittance::EventLookup.find_event_klass(FooEvent)
        expect(value).to eq(FooEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'converts a snake-cased symbol to a camel-cased class' do
        value = Emittance::EventLookup.find_event_klass(:foo)
        expect(value).to eq(FooEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'converts a multi-word snake-cased symbol to a camel-cased class' do
        value = Emittance::EventLookup.find_event_klass(:foo_bar)
        expect(value).to eq(FooBarEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'creates a class where none existed' do
        value = Emittance::EventLookup.find_event_klass(:foo_bar_bar)
        expect(value).to eq(FooBarBarEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'removes bangs and question marks' do
        value_1 = Emittance::EventLookup.find_event_klass(:foo!)
        value_2 = Emittance::EventLookup.find_event_klass(:bar?)

        expect(value_1).to eq(FooEvent)
        expect(value_2).to eq(BarEvent)

        expect(value_1 < Emittance::Event).to be(true)
        expect(value_2 < Emittance::Event).to be(true)
      end

      it 'doesn\'t care about crazy characters or names' do
        weird_identifier = '*()&/Foo, Bar!@!&&&&'
        value = Emittance::EventLookup.find_event_klass(weird_identifier)
        expect(value).to eq(FooBarEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'can handle namespaced objects' do
        value = Emittance::EventLookup.find_event_klass(Foo::Baz)
        expect(value).to eq(FooBazEvent)
        expect(value < Emittance::Event).to be(true)
      end
    end

    context 'with multiple arguments' do
      it 'passes multiple "one-word" classes straight through' do
        value = Emittance::EventLookup.find_event_klass(Foo, Bar)
        expect(value).to eq(FooBarEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'creates a class where none existed' do
        value = Emittance::EventLookup.find_event_klass(Foo, Bar, Foo)
        expect(value).to eq(FooBarFooEvent)
        expect(value < Emittance::Event).to be(true)
      end

      it 'can take mixed types' do
        value = Emittance::EventLookup.find_event_klass(Foo, :bar)
        expect(value).to eq(FooBarEvent)
        expect(value < Emittance::Event).to be(true)
      end
    end
  end

  describe '.identifiers_for_klass' do
    it 'converts a one-word class to a symbol' do
      value = Emittance::EventLookup.identifiers_for_klass(FooEvent)
      expect(value).to eq(:foo)
    end

    it 'converts a multi-word class to a symbol' do
      value = Emittance::EventLookup.identifiers_for_klass(FooBarEvent)
      expect(value).to eq(:foo_bar)
    end
  end
end
