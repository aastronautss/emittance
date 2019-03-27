# frozen_string_literal: true

require 'spec_helper'
require 'emittance/event_validator/registration'

RSpec.describe Emittance::EventValidator::Registration do
  let(:schema_builder) { double 'schema_builder' }

  before do
    @previous_schema_builder = Emittance::EventValidator::Registration.schema_builder
    Emittance::EventValidator::Registration.schema_builder = schema_builder
  end

  after { Emittance::EventValidator::Registration.schema_builder = @previous_schema_builder }

  describe '#initialize' do
    it 'takes a schema object directly' do
      schema = double 'schema'

      expect(Emittance::EventValidator::Registration.new(schema).schema).to eq(schema)
    end

    it 'does not call the builder when taking a schema object directly' do
      schema = double 'schema'

      expect(schema_builder).to_not receive(:build)

      Emittance::EventValidator::Registration.new(schema)
    end

    it 'calls the builder when a block is passed' do
      expect(schema_builder).to receive(:build).and_return(double 'schema')

      Emittance::EventValidator::Registration.new { 'hello' }
    end

    it 'sets the schema to whatever the builder returns' do
      schema = double 'schema'
      allow(schema_builder).to receive(:build).and_return(schema)

      expect(Emittance::EventValidator::Registration.new { 'stuff' }.schema).to eq(schema)
    end
  end

  describe '#valid_for_event?' do
    let(:success_result) { double 'success_result', success?: true }
    let(:failure_result) { double 'failure_result', success?: false }
    let(:schema) { double 'schema' }
    let(:event) { double 'event', payload: 'a payload' }

    subject { Emittance::EventValidator::Registration.new(schema) }

    it 'returns true with a successful result' do
      allow(schema).to receive(:call).with(event.payload).and_return(success_result)

      expect(subject.valid_for_event?(event)).to be(true)
    end

    it 'returns false with an unsuccessful result' do
      allow(schema).to receive(:call).with(event.payload).and_return(failure_result)

      expect(subject.valid_for_event?(event)).to be(false)
    end
  end

  describe 'interface contracts' do
    specify { expect(Emittance::EventValidator::SimpleSchema).to respond_to(:build).with(0).arguments }
    specify { expect(Emittance::EventValidator::SimpleSchema.new).to respond_to(:call).with(1).argument }

    specify { expect(Emittance::Event.new(nil, nil, nil)).to respond_to(:payload).with(0).arguments }
  end
end
