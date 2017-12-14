# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Synchronous::Dispatcher do
  before do
    @previous_registrations = Emittance::Synchronous::Dispatcher.instance_variable_get '@registrations'
    Emittance::Synchronous::Dispatcher.instance_variable_set '@registrations', {}
  end

  after do
    Emittance::Synchronous::Dispatcher.instance_variable_set '@registrations', @previous_registrations
  end

  let(:emitter) { double 'emitter' }
  let(:timestamp) { Time.now }
  let(:payload) { 'hello' }
  let(:event) { FooEvent.new emitter, timestamp, payload }

  subject { Emittance::Synchronous::Dispatcher }

  describe '.register' do
    it 'stores a registration' do
      subject.register(:foo) { |_| 'bar' }

      expect(subject.instance_variable_get('@registrations')[FooEvent]).to_not be_empty
    end
  end

  describe '.process_event' do
    it 'runs the registered callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      subject.register(:foo) do
        tester.bar
      end

      subject.process_event event
    end

    it 'passes params into the callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      subject.register(:foo) do |event|
        expect(event.identifiers).to include(:foo)
        expect(event.timestamp).to be_a(Time)
        expect(event.payload).to eq('hello')

        tester.bar
      end

      subject.process_event event
    end
  end

  describe '.clear_registrations_for!' do
    let(:action) { subject.clear_registrations_for! :foo }

    it 'clears a registration' do
      subject.register(:foo) { 'bar' }

      action
      expect(subject.registrations_for(:foo)).to be_empty
    end

    it 'does not clear registrations for other identifiers' do
      subject.register(:foo) { 'bar' }
      subject.register(:bar) { 'baz' }

      action
      expect(subject.registrations_for(:bar)).to_not be_empty
    end
  end

  describe '.clear_registrations!' do
    let(:action) { subject.clear_registrations! }

    it 'clears a registration' do
      subject.register(:foo) { 'bar' }

      action
      expect(subject.registrations_for(:foo)).to be_empty
    end

    it 'clears multiple registrations' do
      subject.register(:foo) { 'bar' }
      subject.register(:bar) { 'baz' }

      action
      expect(subject.registrations_for(:foo)).to be_empty
      expect(subject.registrations_for(:bar)).to be_empty
    end
  end
end
