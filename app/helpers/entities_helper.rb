module EntitiesHelper

  ### Display Helpers

  # Returns plaintext description of entity's type for display.
  # @return [String]
  def entity_type_title(entity_type, pluralize: false)
    entity_name = entity_type.name.demodulize
    entity_name = entity_name.pluralize if pluralize
    entity_name.underscore.split('_').join(' ').titleize
  end

  # Returns plaintext description of entity for display.
  # @return [String]
  def entity_title_string(entity)
    if entity.respond_to? :inspector_title_string
      entity.inspector_title_string
    else
      logger.warn "No inspector_title_string method defined for #{entity.class.name}. Using class name."
      entity.class.name
    end
  end

  ### Entity Links

  def entity_type_create_link(entity_class, parent_property: nil)
    if parent_property
      "/#{entity_class.entity_type_identifier}/new?parent=#{parent_property.full_property_identifier}"
    else
      "/#{entity_class.entity_type_identifier}/new"
    end
  end

  def entity_view_link(entity)
    "/#{entity.entity_type_identifier}/#{entity.id}"
  end

  def entity_action_link(entity, action)
    "/#{entity.entity_type_identifier}/#{entity.id}/#{action}"
  end

  def collection_view_link(collection)
    entity_type = collection.entity.entity_type_identifier
    "/#{entity_type}/#{collection.entity.id}/collection/#{collection.property_identifier}"
  end

  def collection_add_link(collection)
    entity_type = collection.entity.entity_type_identifier
    "/#{entity_type}/#{collection.entity.id}/collection/#{collection.property_identifier}/new"
  end

  ### Rendering

  # Renders list of entity's displayable elements and attributes.
  def render_entity_properties(entity)
    grouped_properties = entity.entity_properties.group_by &:classify_property

    locals = {
      entity: entity,
      values: grouped_properties[:value],
      child_entities: grouped_properties[:entity],
      collections: grouped_properties[:collection]
    }

    render partial: "properties", locals: locals
  end

  # Renders list of entity's displayable elements and attributes.
  def render_entity_editor_form(entity)
    grouped_properties = entity.entity_properties.group_by &:classify_property

    locals = {
      entity: entity,
      values: grouped_properties[:value],
      child_entities: grouped_properties[:entity],
      collections: grouped_properties[:collection]
    }

    render partial: "edit_properties", locals: locals
  end

  def render_property_editor(property)
    value_type = property.value_type

    if value_type == String
      render partial: "editors/text", locals: { prop: property }
    elsif value_type == Fixnum
      # TODO: handle numeric validation
      render partial: "editors/text", locals: { prop: property }
    elsif value_type == VsscConstants::DATETIME_TYPE
      render partial: "editors/datetime", locals: { prop: property }
    elsif value_type == VsscConstants::DATE_TYPE
      render partial: "editors/date", locals: { prop: property }
    elsif value_type == VsscConstants::BOOLEAN_TYPE
      render partial: "editors/boolean", locals: { prop: property }
    elsif value_type.respond_to? :included_modules and value_type.included_modules.include? VsscEnum
      render partial: "editors/enum", locals: { prop: property }
    else
      logger.warn "No property editor provided for property #{property.property_identifier} of type #{value_type}. Defaulting to string editor."
      render partial: "editors/text", locals: { prop: property }
    end
  end

end
