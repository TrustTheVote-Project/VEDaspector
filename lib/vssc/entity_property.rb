class Vssc::EntityProperty

  attr_reader :entity, :property_definition, :reference_name

  def initialize(entity, property_definition, reference_name)
    @entity = entity
    @property_definition = property_definition
    @reference_name = reference_name
    @value = @entity.send(@property_definition[:method])
  end

  # THe Rails association for the linked entity or collection if one exists.
  # @return [ActiveRecord::Association, nil]
  def property_association
    @entity.class.reflect_on_association @property_definition[:method]
  end

  # The inspector metadata of the associated class if present.
  # @return [Hash, nil]
  def associated_class_metadata
    association = property_association
    if association
      association.klass.inspector_metadata
    else
      nil
    end
  end

  # The name of the property, suitable for presentation to the user.
  # @return [String]
  def name
    metadata = associated_class_metadata
    if metadata and metadata.has_key? :preferred_name
      metadata[:preferred_name]
    else
      @property_definition[:method].to_s.humanize.titlecase
    end
  end

  # @return The property's value. Can be nil.
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

  # A stable identifier for this property.
  # @return [Symbol]
  def property_identifier
    @property_definition[:method]
  end

  # Classifies property as a singular value, a link to another entity, or a
  # collection of multiple entities.
  # @return [Symbol]
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

  # @return [Class, String] The type of this property's value.
  def value_type
    metadata = associated_class_metadata
    if metadata and metadata.has_key? :present_as_value
      metadata[:present_as_value][:type]
    else
      @property_definition[:type]
    end
  end

  # @raise [Exception] If this is not an enumeration property.
  # @return [Hash]
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
  # @raise [Exception] If this is not an entity property.
  # @return [Array<Vssc::EntityProperty>] The linked entity's child properties
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
