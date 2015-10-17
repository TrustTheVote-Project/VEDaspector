module EntitiesHelper

    def entity_type_title(entity_type, pluralize: false)
        entity_name = entity_type.name.demodulize 
        entity_name = entity_name.pluralize if pluralize
        entity_name.underscore.split('_').join(' ').titleize
    end

    def view_entity_link(entity)
        entity_type = entity.class.name.demodulize.pluralize.underscore
        return "/#{entity_type}/#{entity.id}"
    end

    # Returns plaintext string describing entity
    def title_string(entity)
        if entity.respond_to? :inspector_title_string
            entity.inspector_title_string
        else
            logger.warn "No inspector_title_string method defined for #{entity.class.name}. Using class name."
            entity.class.name
        end
    end

    # Renders list of entity's displayable elements and attributes.
    def render_entity_properties(entity)
        properties = Vssc::EntityProperty.extract_properties(entity)
        grouped_properties = properties.group_by &:classify_property

        locals = {
            entity: entity,
            values: grouped_properties[:value],
            entities: grouped_properties[:entity],
            collections: grouped_properties[:collection]
        }

        render partial: "properties", locals: locals
    end

end
