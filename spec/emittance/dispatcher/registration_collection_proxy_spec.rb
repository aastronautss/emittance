# frozen_string_literal: true

require 'set'

require 'spec_helper'

RSpec.describe Emittance::Dispatcher::RegistrationCollectionProxy do
  let(:lookup_term) { :foo }
  let(:foo_collection) { [1, 2] }
  let(:bar_collection) { [1, 2, 3] }
  let(:mappings) { { foo: Set.new(foo_collection) } }
  subject { Emittance::Dispatcher::RegistrationCollectionProxy.new(lookup_term, mappings) }

  describe '#each' do
    let(:watcher) { double 'watcher', tick: true }

    it 'hits every element in one registration' do
      expect(watcher).to receive(:tick).exactly(foo_collection.length).times

      subject.each { |_| watcher.tick }
    end

    context 'with multiple mappings' do
      let(:mappings) { { foo: Set.new(foo_collection), bar: Set.new(bar_collection) } }

      it 'hits every element in all registrations' do
        sum = foo_collection.length + bar_collection.length
        expect(watcher).to receive(:tick).exactly(sum).times

        subject.each { |_| watcher.tick }
      end
    end
  end

  describe '#empty?' do
    let(:action) { subject.empty? }

    it 'returns false if there are mappings in one registration' do
      expect(action).to be(false)
    end

    context 'with one empty registration' do
      let(:mappings) { { foo: Set.new } }

      it 'returns true' do
        expect(action).to be(true)
      end
    end

    context 'with one empty registration and other non-empty registrations' do
      let(:mappings) { { foo: Set.new, bar: Set.new(bar_collection) } }

      it 'returns false' do
        expect(action).to be(false)
      end
    end

    context 'with multiple empty registrations' do
      let(:mappings) { { foo: Set.new, bar: Set.new } }

      it 'returns true' do
        expect(action).to be(true)
      end
    end

    context 'with multiple full registrations' do
      let(:mappings) { { foo: Set.new(foo_collection), bar: Set.new(bar_collection) } }

      it 'returns false' do
        expect(action).to be(false)
      end
    end
  end

  describe '#length' do
    let(:action) { subject.length }

    it 'returns the length of one registration' do
      expect(action).to eq(foo_collection.length)
    end

    context 'with multiple full registrations' do
      let(:mappings) { { foo: Set.new(foo_collection), bar: Set.new(bar_collection) } }

      it 'returns the sum of all collections' do
        expect(action).to eq(foo_collection.length + bar_collection.length)
      end
    end

    context 'with mixed full and empty registrations' do
      let(:mappings) { { foo: Set.new, bar: Set.new(bar_collection) } }

      it 'returns the sum of all collections' do
        expect(action).to eq(bar_collection.length)
      end
    end

    context 'with one empty registration' do
      let(:mappings) { { foo: Set.new } }

      it 'returns zero' do
        expect(action).to eq(0)
      end
    end

    context 'with multiple empty registrations' do
      let(:mappings) { { foo: Set.new, bar: Set.new } }

      it 'returns zero' do
        expect(action).to eq(0)
      end
    end
  end

  describe '#[]' do
    let(:idx) { 0 }
    let(:action) { subject[idx] }

    it 'returns the right value' do
      expect(action).to eq(foo_collection[idx])
    end
  end

  describe '#first' do
    let(:action) { subject.first }

    it 'returns the right value' do
      expect(action).to eq(foo_collection.first)
    end
  end

  describe '#last' do
    let(:action) { subject.last }

    it 'returns the right value' do
      expect(action).to eq(foo_collection.last)
    end
  end
end
