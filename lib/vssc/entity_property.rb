class Vssc::EntityProperty

  attr_reader :entity, :property_definition, :reference_name

  # @param [VsscEntity] the object the property is defined on
  # @param [Hash] the property definition taken from VEDaStore's VsscFunctions
  # @param [String] the name of the property on the entity. may not match the
  #                 property's method name.
  def initialize(entity, property_definition, reference_name)
    @entity = entity
    @property_definition = property_definition
    @reference_name = reference_name

    method_name = @property_definition[:method]
    if @entity.respond_to? method_name
      @value = @entity.send method_name
    else
      Rails.logger.warn "Warning: #{entity} doesn't implement #{method_name}: for property '#{reference_name}'"
    end
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
      unless @value.nil?
        @value.send metadata[:present_as_value][:get]
      else
        nil
      end
    else
      @value
    end
  end

  # @param [Any] the value to add
  def value=(value)
    method_name = "#{@property_definition[:method]}=".to_sym
    @entity.send(method_name, value)
    @value = value
  end


  # @param [Any] the value to append.
  # @raise [Exception] if property is not a collection.
  def append_value(value)
    unless collection?
      raise "#{self}: append_value can only be called on a collection, not on a #{classify_property}"
    end

    # TODO: should handle serialize as Array cases

    if present_as_collection?
      metadata = associated_class_metadata
      if @value.nil?
        self.value = property_association.klass.new
      end
      backing_collection = @value.send metadata[:present_as_collection][:get]
      backing_collection << value
    else
      @entity.send(@property_definition[:method]) << value
    end
  end

  # The method name of the property.
  # @return [Symbol]
  def property_identifier
    @property_definition[:method]
  end

  # A complete identifier for this property including the parent's type,
  # the parent's id, and the name of the property.
  # @return [String]
  def full_property_identifier
    "#{@entity.entity_type_identifier}-#{@entity.id}-#{property_identifier}"
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

  # @return [Boolean] is property a simple, inline value
  def value?
    classify_property == :value
  end

  # @return [Boolean] is property a linked entity
  def entity?
    classify_property == :entity
  end

  # @return [Boolean] is property a collection
  def collection?
    classify_property == :collection
  end

  # Returns whether property links to a 'passthrough' entity, aka a facade for a
  # backing collection property.
  # @return [Boolean]
  def present_as_collection?
    metadata = associated_class_metadata
    metadata and metadata.has_key? :present_as_collection
  end

  # @return [Class, String] The type of this property's value.
  def value_type
    metadata = associated_class_metadata
    if metadata and metadata.has_key? :present_as_value
      metadata[:present_as_value][:type]
    elsif present_as_collection?
      backing_collection_method = metadata[:present_as_collection][:get]
      backing_association = property_association.klass.reflect_on_association backing_collection_method
      backing_association.klass
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
