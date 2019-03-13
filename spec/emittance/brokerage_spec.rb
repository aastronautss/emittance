require 'spec_helper'

RSpec.describe Emittance::Brokerage do
  let(:broker1) { Class.new(Emittance::Broker) }
  let(:broker2) { Class.new(Emittance::Broker) }
  subject { Emittance::Brokerage }

  before do
    @old_default = subject.default_broker
    @old_brokers = subject.brokers_in_use
    subject.instance_variable_set('@default_broker', nil)
    subject.instance_variable_set('@brokers_in_use', Set.new)
  end

  after do
    subject.instance_variable_set('@brokers_in_use', @old_brokers)
    subject.instance_variable_set('@default_broker', @old_default)
  end

  def mock_registry!
    registry = double 'registry'

    allow(subject).to receive(:registry).and_return(registry)
    allow(registry).to receive(:fetch).with(:broker1).and_return(broker1)
    allow(registry).to receive(:fetch).with(:broker2).and_return(broker2)
  end

  describe '.send_event' do
    let(:middleware) { double 'middleware' }
    let(:event) { double 'event' }
    let(:action) { subject.send_event(event, middleware: middleware) }

    before { allow(middleware).to receive(:up).and_return(event) }

    context 'with no registered brokers' do
      it 'calls the middleware stack' do
        expect(middleware).to receive(:up).and_return(event)

        action
      end
    end

    context 'with one registered broker' do
      before { subject.brokers_in_use << broker1 }

      it 'calls process_event on the broker' do
        expect(broker1).to receive(:process_event).with(event)

        action
      end
    end

    context 'with multiple registered brokers' do
      before do
        subject.brokers_in_use << broker1
        subject.brokers_in_use << broker2
      end

      it 'calls process_event on all brokers' do
        expect(broker1).to receive(:process_event).with(event)
        expect(broker2).to receive(:process_event).with(event)

        action
      end
    end
  end

  describe '.brokers_in_use' do
    it 'is defined' do
      expect {subject.brokers_in_use }.to_not raise_error
    end
  end

  describe '.find_broker' do
    it 'returns the default broker when nil is passed in' do
      subject.brokers_in_use << broker1
      subject.default_broker = broker1

      expect(subject.find_broker(nil)).to eq(broker1)
    end

    it 'returns the broker when the broker itself is passed in' do
      subject.brokers_in_use << broker1

      expect(subject.find_broker(broker1)).to eq(broker1)
    end

    it 'returns nil when it does not find a broker' do
      subject.brokers_in_use << broker1

      expect(subject.find_broker(:foobar)).to be_nil
    end

    it 'returns the broker itself when an Emittance::Broker subclass is passed in' do
      expect(subject.find_broker(broker2)).to eq(broker2)
    end
  end

  describe '.broker_in_use?' do
    it 'returns false when a non-in-use broker is passed in' do
      expect(subject.broker_in_use?(broker1)).to be(false)
    end

    it 'returns true when an in-use broker is passed in' do
      subject.brokers_in_use << broker1

      expect(subject.broker_in_use?(broker1)).to be(true)
    end

    context 'when passing in a registered symbol' do
      before { mock_registry! }

      it 'returns false when the associated broker is not in use' do
        expect(subject.broker_in_use?(:broker1)).to be(false)
      end

      it 'returns true when the associated broker is in use' do
        subject.brokers_in_use << broker1

        expect(subject.broker_in_use?(:broker1)).to be(true)
      end
    end
  end

  describe '.use_broker' do
    before { mock_registry! }

    it 'adds a broker to the list of brokers in use' do
      subject.use_broker :broker1

      expect(subject.brokers_in_use).to include(broker1)
    end

    it 'can add multiple brokers' do
      subject.use_broker :broker1
      subject.use_broker :broker2

      expect(subject.brokers_in_use).to include(broker1)
      expect(subject.brokers_in_use).to include(broker2)
    end

    it 'sets the broker to the default if it is the first broker being added' do
      expect(subject.brokers_in_use).to be_empty # sanity check

      subject.use_broker :broker1

      expect(subject.default_broker).to eq(broker1)
    end

    it 'does not reset the default broker if it is not the first broker being added' do
      subject.use_broker :broker1
      subject.use_broker :broker2

      expect(subject.default_broker).to eq(broker1)
    end
  end

  describe '.default_broker=' do
    before { mock_registry! }

    it 'raises an error when the broker is not in use' do
      expect { subject.default_broker = :broker1 }.to raise_error(Emittance::Brokerage::BrokerNotInUseError)
    end

    it 'sets the defaut_broker' do
      subject.use_broker :broker1
      subject.use_broker :broker2

      expect(subject.default_broker).to eq(broker1) # sanity check

      subject.default_broker = :broker2

      expect(subject.default_broker).to eq(broker2)
    end
  end

  describe '.dispatcher_for' do
    let(:dispatcher) { double 'dispatcher' }
    before do
      allow(broker1).to receive(:dispatcher).and_return(dispatcher)
      mock_registry!
    end

    it "returns the default broker's dispatcher when nil is passed in" do
      subject.use_broker :broker1

      expect(subject.dispatcher_for(nil)).to eq(dispatcher)
    end

    it 'is aliased as .dispatcher' do
      subject.use_broker :broker1

      expect(subject.dispatcher).to eq(dispatcher)
    end

    it 'returns the correct dispatcher when a symbol is passed' do
      expect(subject.dispatcher_for(:broker1)).to eq(dispatcher)
    end

    it 'returns the dispatcher associated to the broker when the broker itself is passed' do
      expect(subject.dispatcher_for(broker1)).to eq(dispatcher)
    end
  end

  describe '.enable!' do
    before { @was_enabled = subject.enabled? }
    after { subject.instance_variable_set('@enabled', @was_enabled) }

    it 'turns the enabled flag on' do
      subject.enable!

      expect(subject).to be_enabled
    end
  end

  describe '.disable!' do
    before { @was_enabled = subject.enabled? }
    after { subject.instance_variable_set('@enabled', @was_enabled) }

    it 'turns the enabled flag off' do
      subject.disable!

      expect(subject).to_not be_enabled
    end
  end
end
