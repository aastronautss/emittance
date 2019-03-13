require 'spec_helper'

RSpec.describe Emittance::Dispatcher::TopicRegistrationMap do
  subject { Emittance::Dispatcher::TopicRegistrationMap.new }

  describe 'with explicit registration and retrieval' do
    it 'retrieves a single-level record' do
      subject.register('a', 1)

      expect(subject['a'].length).to eq(1)
    end

    it 'can take an event with a topic' do
      event = double 'event', topic: 'a'
      subject.register('a', 1)

      expect(subject['a']).to contain_exactly(1)
    end

    it 'retrieves a single-level subscription record' do
      subject.register('a', 1)

      expect(subject['a'].first).to respond_to(:routing_key)
      expect(subject['a'].first).to respond_to(:registration)
    end

    it 'retrieves the correct single-level routing key' do
      subject.register('a', 1)

      expect(subject['a'].first.routing_key).to eq('a')
    end

    it 'retrieves the correct single-level registration' do
      subject.register('a', 1)

      expect(subject['a'].first.registration).to eq(1)
    end

    it 'filters out the non-matches on a single level routing key' do
      subject.register('a', 1)
      subject.register('b', 2)

      expect(subject['a'].length).to eq(1)
    end

    it 'retrieves only the matches on a single-level routing key' do
      subject.register('a', 1)
      subject.register('b', 2)

      expect(subject['a'].first.routing_key).to eq('a')
      expect(subject['a'].first.registration).to eq(1)
    end

    it 'correctly misses a single-level routing key that has not been registered' do
      subject.register('a', 1)

      expect(subject['b']).to be_empty
    end

    it 'correctly misses a multi-level routing key that has not been registered' do
      subject.register('a', 1)

      expect(subject['a.a']).to be_empty
    end

    it 'retrieves a multi-level record' do
      subject.register('a.a', 11)

      expect(subject['a.a'].length).to eq(1)
    end

    it 'retrieves the correct subscription from a multi-level record' do
      subject.register('a.a', 11)

      expect(subject['a.a'].first.registration).to eq(11)
    end

    it 'filters out single-level matches when a multi-level record is queried for' do
      subject.register('a', 1)
      subject.register('a.a', 11)

      expect(subject['a.a'].length).to eq(1)
    end

    it 'retrieves the correct subscription when single-level subscriptions and multi-level subscriptions are stored' do
      subject.register('a', 1)
      subject.register('a.a', 11)

      expect(subject['a.a'].first.registration).to eq(11)
    end

    it 'correctly filters out multi-level subscriptions when the first level of the routing key matches' do
      subject.register('a.a', 11)
      subject.register('a.b', 21)

      expect(subject['a.a'].length).to eq(1)
      expect(subject['a.a'].first.registration).to eq(11)
    end
  end

  describe 'with wildcard registration and retrieval' do
    it 'retrieves a single-level wildcard subscription for a simple routing key' do
      subject.register('*', 0)

      expect(subject['a'].length).to eq(1)
      expect(subject['a'].first.registration).to eq(0)
    end

    it 'correctly misses a single-level wildcard subscription on a multi-level lookup' do
      subject.register('*', 0)

      expect(subject['a.a']).to be_empty
    end

    it 'correctly misses a multi-level wildcard subscription on a single-level lookup' do
      subject.register('*.a', 10)

      expect(subject['a']).to be_empty
    end

    it 'retrieves a multi-level wildcard subscription on a multi-level lookup' do
      subject.register('*.a', 10)

      expect(subject['b.a'].length).to eq(1)
      expect(subject['b.a'].first.registration).to eq(10)
      expect(subject['b.a'].first.routing_key).to eq('*.a')
    end

    it 'filters out the correct multi-level wildcard subscriptions' do
      subject.register('*.a', 10)
      subject.register('b.*', 2)
      subject.register('c.*', 3)

      expect(subject['c.a'].length).to eq(2)
      expect(subject['c.a']).to contain_exactly(10, 3)
    end
  end

  describe 'with hash subscriptions' do
    it 'retrieves with a single-level lookup' do
      subject.register('#', 'x')

      expect(subject['a']).to contain_exactly('x')
    end

    it 'retrieves a single-level hash subscription with a two-level lookup' do
      subject.register('#', 'x')

      expect(subject['a.b']).to contain_exactly('x')
    end

    it 'retrieves a single-level hash subscription with a several-level lookup' do
      subject.register('#', 'x')

      expect(subject['a.b.c.d.e']).to contain_exactly('x')
    end

    it 'retrieves a second-level hash subscription with a single-level lookup' do
      subject.register('a.#', '1x')

      expect(subject['a']).to contain_exactly('1x')
    end

    it 'retrieves a second-level hash subscription with a two-level lookup' do
      subject.register('a.#', '1x')

      expect(subject['a.a']).to contain_exactly('1x')
    end

    it 'retrieves a second-level hash subscription with a several-level lookup' do
      subject.register('a.#', '1x')

      expect(subject['a.b.c.d.e']).to contain_exactly('1x')
    end

    it 'retrieves a second-level hash subscription on a first-level wildcard subscription with a single-level lookup' do
      subject.register('*.#', '0x')

      expect(subject['a']).to contain_exactly('0x')
    end

    it 'retrieves a second-level hash subscription on a first-level wildcard subscription with a two-level lookup' do
      subject.register('*.#', '0x')

      expect(subject['a.b']).to contain_exactly('0x')
    end

    it 'retrieves a second-level hash subscription on a first-level wildcard subscription with a multi-level lookup' do
      subject.register('*.#', '0x')

      expect(subject['a.b.c.d.e']).to contain_exactly('0x')
    end

    it 'retrieves a first-level hash subscription with a second-level name on a single-level lookup' do
      subject.register('#.a', 'x1')

      expect(subject['a']).to contain_exactly('x1')
    end

    it 'retrieves a first-level hash subscription with a second-level name on a two-level lookup' do
      subject.register('#.a', 'x1')

      expect(subject['a.a']).to contain_exactly('x1')
    end

    it 'retrieves a first-level hash subscription with a second-level name on a several-level lookup' do
      subject.register('#.a', 'x1')

      expect(subject['d.c.b.a']).to contain_exactly('x1')
    end

    it 'retrieves an nth-level hash subscription with an (n-1)-level lookup' do
      subject.register('a.b.#', '12x')

      expect(subject['a.b']).to contain_exactly('12x')
    end

    it 'retrieves an nth-level hash subscription with an n-level lookup' do
      subject.register('a.b.#', '12x')

      expect(subject['a.b.c']).to contain_exactly('12x')
    end

    it 'retrieves an nth-level hash subscription with a multi-level lookup' do
      subject.register('a.b.#', '12x')

      expect(subject['a.b.c.d.e.f.g']).to contain_exactly('12x')
    end

    it 'misses an nth-level hash subscription with a multi-level lookup' do
      subject.register('a.b.#', '12x')

      expect(subject['a.a.b.c']).to be_empty
    end

    it 'misses an nth-level hash subscription with an (n-1)-level lookup' do
      subject.register('a.b.#', '12x')

      expect(subject['a.a']).to be_empty
    end

    it 'misses an nth-level hash subscription with an n-level lookup' do
      subject.register('a.b.#', '12x')

      expect(subject['a.a.b']).to be_empty
    end
  end

  describe 'with a complicated multi-level subscription setup' do
    before do
      subject.register('#', 'x')
      subject.register('*', '0')
      subject.register('a', '1')
      subject.register('b', '2')

      subject.register('*.*', '00')
      subject.register('*.a', '01')
      subject.register('*.b', '02')

      subject.register('#.a', 'x1')
      subject.register('#.*', 'x0')

      subject.register('a.*', '10')
      subject.register('a.a', '11')
      subject.register('a.b', '12')
      subject.register('a.#', '1x')

      subject.register('b.*', '20')
      subject.register('b.a', '21')
      subject.register('b.b', '22')

      subject.register('*.*.a', '001')
      subject.register('*.a.*', '010')
      subject.register('a.*.*', '100')
      subject.register('*.*.#', '00x')

      subject.register('b.a.*', '210')
      subject.register('*.b.a', '021')
    end

    it 'gets all single-level lookups correct' do
      expect(subject['a']).to contain_exactly('x', 'x0', 'x1', '1x', '0', '1')
      expect(subject['b']).to contain_exactly('x', 'x0', '0', '2')
    end

    it 'gets all two-level lookups correct' do
      expect(subject['a.b']).to contain_exactly('x', 'x0', '1x', '00', '02', '10', '12', '00x')
      expect(subject['b.b']).to contain_exactly('x', 'x0', '00', '02', '20', '22', '00x')
    end

    it 'gets all three-level lookups correct' do
      expect(subject['a.b.a']).to contain_exactly('x', 'x0', 'x1', '1x', '001', '100', '021', '00x')
    end
  end
end
