class Vssc::EntityProperty

  attr_reader :entity

  def initialize(entity, property_name, property, value=nil)
    @entity = entity
    @property_name = property_name
    @property = property
    @value = value || @entity.send(@property[:method])
  end

  # Returns Rails association for linked entity/collection.
  # Will return nil for value properties.
  def property_association
    @entity.class.reflect_on_association @property[:method]
  end

  # Returns inspector metadata for entity/collection linked by this property.
  # Will return nil for value properties.
  def associated_class_metadata
    association = property_association
    if association
      association.klass.inspector_metadata
    else
      nil
    end
  end

  def name
    metadata = associated_class_metadata
    if metadata and metadata.has_key? :preferred_name
      metadata[:preferred_name]
    elsif @property.has_key? :method
      @property[:method].to_s.humanize.titlecase
    else
      @property_name
    end
  end

  def value
    metadata = associated_class_metadata
    if metadata and metadata[:present_as_collection]
      unless @value.nil?
        @value.send metadata[:present_as_collection][:get]
      else
        []
      end
    elsif metadata and metadata[:present_as_value]
      @value.send metadata[:present_as_value][:get]
    else
      @value
    end
  end

  def property_identifier
    @property[:method]
  end

  # Classifies property as a singular value, a link to another entity, or a
  # collection of multiple entities.
  def classify_property
    association = property_association
    metadata = associated_class_metadata

    if not metadata or metadata.has_key? :present_as_value
      :value
    elsif association.collection? or metadata.has_key? :present_as_collection
      :collection
    else
      :entity
    end
  end

  def value_type
    unless [:value, :collection].include? classify_property
      raise "value_type should only be called on a value or collection property"
    end

    metadata = associated_class_metadata
    if metadata and metadata.has_key? :present_as_value
      metadata[:present_as_value][:type]
    else
      @property[:type]
    end
  end

  def entity_present?
    unless classify_property == :entity
      raise "entity_present? should only be called on an entity"
    end

    not @value.nil?
  end

  def enum_values
    unless classify_property == :value and value_type.included_modules.include? VsscEnum
      raise "enum_values should only be called on a enumerated value"
    end

    if @value and not value_type.values.uniq.include? @value
      Rails.logger.warn "Property #{name} on #{@entity.class}: value #{@value} does not match possible enumeration values, and will be ignored."
    end

    # uniq needed as of VEDaStore 1.0.4
    value_type.values.uniq.map do |enum_value|
      {:name => enum_value, :selected => @value == enum_value}
    end
  end

  # Lazily fetch value properties of child entity.
  def child_value_properties
    unless classify_property == :entity
      raise "child_value_properties should only be called on an entity property"
    end

    if @value.nil?
      raise "child_value_properties should not be called on nil entity"
    end

    unless instance_variable_defined? "@child_value_properties"
      @child_value_properties = @value.entity_properties.select do |p|
        p.classify_property == :value
      end
    end
    
    @child_value_properties
  end

end
