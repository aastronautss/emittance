# frozen_string_literal: true

RSpec.describe Emittance::Helpers::ConstantHelpers do
  describe '#set_namespaced_constant_by_name' do
    let(:const_name) { 'MyTest' }
    let(:value) { :bar }
    let(:klass) { Class.new { extend Emittance::Helpers::ConstantHelpers } }
    let(:action) { klass.set_namespaced_constant_by_name const_name, value }

    before { stub_const 'Object', Class.new }

    context 'when setting to the base namespace' do
      it 'defines the constant' do
        action

        expect(Object.const_defined?(const_name)).to be(true)
      end

      it 'sets the right value' do
        action

        expect(Object.const_get(const_name)).to eq(value)
      end
    end

    context 'when adding to an existing namespace' do
      let(:const_name) { 'MyTest::Foo' }

      before { Object.const_set 'MyTest', Module.new }

      it 'defines the constant under that namespace' do
        action

        expect(Object.const_defined?(const_name)).to be(true)
      end

      it 'sets the right value' do
        action

        expect(Object.const_get(const_name)).to eq(value)
      end
    end

    context 'when adding to a new namespace' do
      let(:const_name) { 'MyOtherTest::Bar' }

      it 'creates a new namespace parent' do
        action

        expect(Object.const_defined?('MyOtherTest')).to be(true)
      end

      it 'creates the new class underneath that new parent' do
        action

        expect(Object.const_defined?('MyOtherTest::Bar')).to be(true)
      end
    end

    context 'when adding a deeply nested namespace' do
      let(:const_name) { 'MyDeepNamespace::MyNextLevelNamespace::MyOtherLevelNamespace::ThisIsALittleRidiculous::Foo' }

      it 'creates all those namespaces' do
        action

        expect(Object.const_defined?(const_name)).to be(true)
      end
    end
  end
end
