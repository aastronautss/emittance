# @private
class SystemEvents::Event::EventBuilder
  KLASS_NAME_SUFFIX = 'Event'.freeze

  class << self
    def objects_to_klass(*args)
      klass_name_parts = args.map { |arg| klass_name_for arg }
      klass_name = dress_up_klass_name klass_name_parts
      find_or_create_event_klass klass_name
    end

    def klass_to_identifier(klass)
      klass.to_sym
    end

    private

    def klass_name_for(obj)
      obj.to_s
    end

    def dress_up_klass_name(klass_name_parts)
      "#{klass_name_parts.join}#{KLASS_NAME_SUFFIX}"
    end

    def find_or_create_event_klass(klass_name)
      unless Object.const_defined? klass_name
        create_event_klass klass_name
      end

      Object.const_get klass_name
    end

    def create_event_klass(klass_name)
      new_klass = Class.new(SystemEvents::Event)
      Object.const_set klass_name, new_klass
    end
  end
end
