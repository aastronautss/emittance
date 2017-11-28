# @private
class SystemEvents::Event::EventBuilder
  KLASS_NAME_SUFFIX = 'Event'.freeze

  class << self
    def objects_to_klass(*args)
      return args[0] if pass_through?(args)

      klass_name_parts = args.map { |arg| klassable_name_for arg }
      klass_name = dress_up_klass_name klass_name_parts
      find_or_create_event_klass klass_name
    end

    def klass_to_identifier(klass)
      klass.to_sym
    end

    private

    def pass_through?(args)
      args.length == 1 && (args[0].is_a?(Class) && args[0] < SystemEvents::Event)
    end

    def klassable_name_for(obj)
      name_str = obj.to_s
      name_str = camel_case name_str
      name_str = clean_up_punctuation name_str

      name_str
    end

    def camel_case(str)
      str = str.sub(/^[a-z\d]*/) { $&.capitalize }
      str.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }
    end

    def clean_up_punctuation(str)
      str.gsub /[^A-Za-z0-9]/, ''
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
