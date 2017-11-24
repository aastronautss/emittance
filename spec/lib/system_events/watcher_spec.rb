describe SystemEvents::Watcher do
  class Foo
    extend SystemEvents::Emitter
  end

  class Bar
    include SystemEvents::Watcher
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
