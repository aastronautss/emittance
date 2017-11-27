require 'spec_helper'

describe SystemEvents::Event::EventBuilder do
  before do
    stub_const 'Foo', Class.new
    stub_const 'Bar', Class.new
    stub_const 'FooBaz', Class.new
    stub_const 'FooEvent', Class.new(SystemEvents::Event)
    stub_const 'FooBarEvent', Class.new(SystemEvents::Event)
  end

  describe 'objects_to_klass' do
    context 'with one argument' do
      it 'passes a "one-word" class straight through' do
        value = SystemEvents::Event::EventBuilder.objects_to_klass(Foo)
        expect(value).to eq(FooEvent)
        expect(value < SystemEvents::Event).to be(true)
      end
    end

    context 'with multiple arguments' do
      it 'passes multiple "one-word" classes straight through' do
        value = SystemEvents::Event::EventBuilder.objects_to_klass(Foo, Bar)
        expect(value).to eq(FooBarEvent)
        expect(value < SystemEvents::Event).to be(true)
      end

      it 'creates a class where none existed' do
        value = SystemEvents::Event::EventBuilder.objects_to_klass(Foo, Bar, Foo)
        expect(value).to eq(FooBarFooEvent)
        expect(value < SystemEvents::Event).to be(true)
      end
    end
  end
end
