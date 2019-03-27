# frozen_string_literal: true

require 'spec_helper'
require 'emittance/event_validator'

RSpec.describe Emittance::EventValidator do
  let(:registration_1) { double 'registration_1' }
  let(:registration_2) { double 'registration_2' }
  let(:validation_map) { double 'validation_map' }
  let(:registrations) { [registration_1] }

  subject { Emittance::EventValidator.new(validation_map) }

  describe '#register' do
    before { allow(validation_map).to receive(:register) }

    it 'passes a registraiton object to the validation map' do
      expect(validation_map).to receive(:register).with(
        'some_identifier', kind_of(Emittance::EventValidator::Registration)
      )

      subject.register('some_identifier', 'some schema')
    end

    it 'can take a block instead of a validation map' do
      expect(validation_map).to receive(:register).with(
        'some_identifier', kind_of(Emittance::EventValidator::Registration)
      )

      subject.register('some_identifier') { |_foo| }
    end
  end

  describe '#valid_for_event?' do
    let(:event) { double 'event', identifiers: ['identifier_1'] }

    before do
      allow(validation_map).to receive(:[]).and_return(registrations)
    end

    it 'returns true when one registration is return that is valid for the event' do
      allow(registration_1).to receive(:valid_for_event?).with(event).and_return(true)

      expect(subject.valid_for_event?(event)).to be(true)
    end

    context 'when multiple registrations return true' do
      let(:registrations) { [registration_1, registration_2] }

      before { registrations.each { |reg| allow(reg).to receive(:valid_for_event?).with(event).and_return(true) } }

      it 'returns true' do
        expect(subject.valid_for_event?(event)).to be(true)
      end
    end

    context 'when a single registration returns false' do
      before { allow(registration_1).to receive(:valid_for_event?).with(event).and_return(false) }

      it 'returns false' do
        expect(subject.valid_for_event?(event)).to be(false)
      end
    end

    context 'when multiple regisrations return false' do
      let(:registrations) { [registration_1, registration_2] }

      before { registrations.each { |reg| allow(reg).to receive(:valid_for_event?).with(event).and_return(false) } }

      it 'returns false' do
        expect(subject.valid_for_event?(event)).to be(false)
      end
    end

    context 'when multiple registrations have mixed outputs' do
      let(:registrations) { [registration_1, registration_2] }

      before do
        allow(registration_1).to receive(:valid_for_event?).with(event).and_return(true)
        allow(registration_2).to receive(:valid_for_event?).with(event).and_return(false)
      end

      it 'returns false' do
        expect(subject.valid_for_event?(event)).to be(false)
      end
    end
  end

  describe 'interface contracts' do
    specify { expect(Emittance::Dispatcher::TopicRegistrationMap.new).to respond_to(:register).with(2).arguments }
    specify { expect(Emittance::Dispatcher::TopicRegistrationMap.new).to respond_to(:[]).with(1).argument }

    specify { expect(Emittance::Dispatcher::RegistrationMap.new).to respond_to(:register).with(2).arguments }
    specify { expect(Emittance::Dispatcher::RegistrationMap.new).to respond_to(:[]).with(1).argument }

    specify do
      expect(Emittance::EventValidator::Registration.new('the schema')).to(
        respond_to(:valid_for_event?).with(1).argument
      )
    end
  end
end
