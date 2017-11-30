# @private
class Emittance::Event::EventBuilder
  KLASS_NAME_SUFFIX = 'Event'.freeze

  class << self
    def objects_to_klass(*objs)
      klass = nil

      klass ||= pass_klass_through(*objs)
      klass ||= find_by_custom_identifier(*objs)
      klass ||= generate_event_klass(*objs)

      klass
    end

    def klass_to_identifier(klass)
      identifier_str = klass.name
      identifier_str = undress_klass_name identifier_str
      identifier_str = snake_case identifier_str

      identifier_str.to_sym
    end

    private

    def pass_klass_through(*objs)
      objs.length == 1 && objs[0].is_a?(Class) && objs[0] < Emittance::Event ? objs[0] : nil
    end

    def find_by_custom_identifier(*objs)
      if objs.length == 1
        CustomIdentifiers.event_klass_for objs[0]
      else
        nil
      end
    end

    def generate_event_klass(*objs)
      klass_name_parts = objs.map { |obj| klassable_name_for obj }
      klass_name = dress_up_klass_name klass_name_parts
      find_or_create_event_klass klass_name
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

    def snake_case(str)
      str.gsub(/::/, '_')
        .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        .gsub(/([a-z\d])([A-Z])/,'\1_\2')
        .tr("-", "_")
        .downcase
    end

    def clean_up_punctuation(str)
      str.gsub /[^A-Za-z\d]/, ''
    end

    def dress_up_klass_name(klass_name_parts)
      "#{klass_name_parts.join}#{KLASS_NAME_SUFFIX}"
    end

    def undress_klass_name(klass_name_str)
      klass_name_str.gsub /#{KLASS_NAME_SUFFIX}$/, ''
    end

    def find_or_create_event_klass(klass_name)
      unless Object.const_defined? klass_name
        create_event_klass klass_name
      end

      Object.const_get klass_name
    end

    def create_event_klass(klass_name)
      new_klass = Class.new(Emittance::Event)
      Object.const_set klass_name, new_klass
    end
  end

  class CustomIdentifiers
    class InvalidIdentifierError < StandardError; end

    @mappings = {}

    class << self
      def mapping_esists?(identifier)
        !!@mappings[identifier]
      end

      def event_klass_for(identifier)
        @mappings[identifier]
      end

      def set(identifier, event_klass)
        raise InvalidIdentifierError unless identifier.is_a?(Symbol)
        @mappings[identifier] = event_klass
      end
    end
  end
end
