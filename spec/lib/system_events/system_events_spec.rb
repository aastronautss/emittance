require 'spec_helper'

describe SystemEvents::Broker do
  subject { SystemEvents::Broker }

  describe '.register' do
    it 'stores a registration' do
      SystemEvents::Broker.register('foo') { |_| puts 'bar' }

      expect(SystemEvents::Broker.instance_variable_get('@registrations')[:foo]).to be_present
    end
  end

  describe '.process_event' do
    after { SystemEvents::Broker.clear_registrations! }

    it 'runs the registered callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      SystemEvents::Broker.register('foo') do
        tester.bar
      end

      SystemEvents::Broker.process_event 'foo', Time.now
    end

    it 'passes params into the callback' do
      tester = double('tester')
      expect(tester).to receive(:bar)

      SystemEvents::Broker.register('foo') do |identifier, timestamp, emitter, payload|
        expect(identifier).to be_a(Symbol)
        expect(timestamp).to be_a(Time)
        expect(payload).to be_a(Array)

        tester.bar
      end

      SystemEvents::Broker.process_event 'foo', Time.now
    end
  end

  describe '.clear_registrations_for!' do
    let(:action) { subject.clear_registrations_for! 'foo' }
    after { SystemEvents::Broker.clear_registrations! }

    it 'clears a registration' do
      SystemEvents::Broker.register('foo') { puts 'bar' }

      action
      expect(SystemEvents::Broker.registrations_for('foo')).to be_empty
    end

    it 'does not clear registrations for other identifiers' do
      SystemEvents::Broker.register('foo') { puts 'bar' }
      SystemEvents::Broker.register('bar') { puts 'baz' }

      action
      expect(SystemEvents::Broker.registrations_for('bar')).to_not be_empty
    end
  end

  describe '.clear_registrations!' do
    let(:action) { subject.clear_registrations! }

    it 'clears a registration' do
      SystemEvents::Broker.register('foo') { puts 'bar' }

      action
      expect(SystemEvents::Broker.registrations_for('foo')).to be_empty
    end

    it 'clears multiple registrations' do
      SystemEvents::Broker.register('foo') { puts 'bar' }
      SystemEvents::Broker.register('bar') { puts 'baz' }

      action
      expect(SystemEvents::Broker.registrations_for('foo')).to be_empty
      expect(SystemEvents::Broker.registrations_for('bar')).to be_empty
    end
  end
end

describe SystemEvents::Emitter do
  before do
    class Foo
      extend SystemEvents::Emitter
    end
  end

  describe '#emit' do
    it 'sends a message to the broker' do
      identifier = 'foo'
      payload = ['hello', 'world']

      expect(SystemEvents::Broker).to receive(:process_event)
      Foo.emit 'foo', payload
    end
  end
end

describe SystemEvents::Watcher do
  before do
    class Foo
      extend SystemEvents::Emitter
    end

    class Bar
      include SystemEvents::Watcher
    end
  end

  after { SystemEvents::Broker.clear_registrations! }

  describe '#watch' do
    it 'watches for emissions' do
      tester = double('tester')
      expect(tester).to receive(:test_me)

      my_bar = Bar.new
      my_bar.watch('test_foo') { |_| tester.test_me }

      Foo.emit 'test_foo'
    end

    it 'passes the payload along' do
      tester = double('tester')
      payload_1 = 'hello'
      payload_2 = 'world'
      expect(tester).to receive(:test_me).with(Foo, payload_1, payload_2)

      my_bar = Bar.new
      my_bar.watch('test_foo') { |identifier, timestamp, emitter, payload| tester.test_me(emitter, *payload) }

      Foo.emit 'test_foo', payload_1, payload_2
    end
  end
end
