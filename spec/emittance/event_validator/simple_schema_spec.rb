# frozen_string_literal: true

require 'spec_helper'
require 'emittance/event_validator/simple_schema'

RSpec.describe Emittance::EventValidator::SimpleSchema do
  subject { Emittance::EventValidator::SimpleSchema.new }

  describe '.build' do
    it 'takes and evaluates a block' do
      observer = double 'observer'
      expect(observer).to receive(:call)

      Emittance::EventValidator::SimpleSchema.build { observer.call }
    end

    it 'sets self to the new instance' do
      observer = double 'observer'
      expect(observer).to receive(:call).with(kind_of Emittance::EventValidator::SimpleSchema)

      Emittance::EventValidator::SimpleSchema.build { observer.call(self) }
    end
  end

  describe '#expected_keys' do
    it 'returns an enumerable' do
      expect(subject.expected_keys).to respond_to(:each)
    end

    it 'contains keys that are added' do
      subject.expected_keys << :key1

      expect(subject.expected_keys).to include(:key1)
    end
  end

  describe '#key' do
    it 'adds the key to the list of expected keys' do
      subject.key :key2

      expect(subject.expected_keys).to include(:key2)
    end
  end

  describe '#keys' do
    it 'adds the keys to the list of expected keys' do
      subject.keys :key3, :key4

      expect(subject.expected_keys).to include(:key3, :key4)
    end
  end

  describe '#call' do
    it 'is successful when there are no expected keys and the input is empty' do
      expect(subject.expected_keys).to be_empty #sanity check

      expect(subject.({})).to be_success
    end

    it 'is successful when there are no expected keys and the input is not empty' do
      expect(subject.expected_keys).to be_empty #sanity check

      expect(subject.(foo: :bar, baz: :quux)).to be_success
    end

    it 'is successful when the expected keys match the given keys exactly' do
      subject.key :key5

      expect(subject.(key5: :hello)).to be_success
    end

    it 'is successful when there are extra keys but still include the expected key' do
      subject.key :key6

      expect(subject.(key6: :hello, something: :else)).to be_success
    end

    it 'fails when there are expected keys but the input is empty' do
      subject.key :key7

      expect(subject.({})).to_not be_success
    end

    it 'fails when there are keys present in the input but not the expected key' do
      subject.key :key8

      expect(subject.(other: :stuff, that_is_not: :the_expected_key)).to_not be_success
    end
  end
end
