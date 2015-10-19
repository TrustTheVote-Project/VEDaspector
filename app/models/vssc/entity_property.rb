class Vssc::EntityProperty

    attr_reader :value

    def initialize(entity, property_name, property, value=nil)
        @entity = entity
        @property_name = property_name
        @property = property
        @value = value || @entity.send(@property[:method])
    end

    def name
        if @property.has_key? :method
            @property[:method].to_s.humanize.titlecase
        else
            @property_name
        end
    end

    def rendered_content
        case @value
        when Vssc::InternationalizedText
            @value.preferred_language_text
        else
            @value
        end
    end

    # Classifies property as a singular value, a link to another entity, or a
    # collection of multiple entities.
    def classify_property
        case @value
        # Hardcode InternationalizedText as value for inspection purposes.
        when Vssc::InternationalizedText
            :value
        when ActiveRecord::Associations::CollectionProxy
            :collection
        when ActiveRecord::Base
            :entity
        else
            :value
        end
    end

    # Lazily fetch value properties of child entity.
    def child_value_properties
        unless classify_property == :entity
            raise "child_value_properties should only be called on an entity property" 
        end

        unless instance_variable_defined? "@child_value_properties"
            @child_value_properties = Vssc::EntityProperty.extract_properties(@value).select do |p|
                p.classify_property == :value
            end
        end
        
        @child_value_properties
    end

    def collection_value_type
        unless classify_property == :collection
            raise "collection_value_type should only be called on a collection property" 
        end

        @property[:type]
    end

    def self.extract_properties(entity)
        properties = []

        properties += entity.elements.map do |name, element|
            Vssc::EntityProperty.new(entity, name, element)
        end.compact

        properties += entity.xml_attributes.map do |name, attribute|
            Vssc::EntityProperty.new(entity, name, attribute)
        end.compact 

        if entity.class.text_node_method
            text_value = entity.send entity.class.text_node_method
            if text_value
                properties << Vssc::EntityProperty.new(entity, entity.class.text_node_method.to_s, {}, text_value)
            end
        end

        properties
    end

end
