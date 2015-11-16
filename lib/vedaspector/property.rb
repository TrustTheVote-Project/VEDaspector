class Vedaspector::Property

  BOOLEAN_TYPE = 'xsd:boolean'
  DATETIME_TYPE = 'xsd:dateTime'
  DATE_TYPE = 'xsd:date'

  STRING_COLLECTION_TYPE = 'string_collection'


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
      Rails.logger.warn "#{self}: #{entity} doesn't implement '#{method_name}'"
    end
  end

  def to_s
    "#{@entity.class}::#{@reference_name}"
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
    else
      @value
    end
  end

  # Assigns a new value for the property.
  # @param [Any] the value to set.
  # @raise [Exception] if called on a collection.
  def value=(new_value)
    if serialized_property?
      new_value = new_value.reject {|s| s.empty? }
    end

    if collection?
      raise "#{self}: Unable to call value= for collection. Use 'append_value' instead."
    end
    
    setter_method = "#{@property_definition[:method]}=".to_sym

    if present_as_value?
      store_method = associated_class_metadata[:present_as_value][:store]

      if @value.nil?
        @value = property_association.klass.new
        @entity.send setter_method, @value
      end

      @value.send store_method, new_value
      @value.save!
    else
      @entity.send(setter_method, new_value)
      @value = new_value
    end
  end


  # @param [Any] the value to append.
  # @raise [Exception] if property is not a collection.
  def append_value(value)
    unless collection?
      raise "#{self}: append_value can only be called on a collection, not on a #{classify_property}"
    end

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

    if not metadata or present_as_value?
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

  # Whether property links to an entity that should be shown as though
  # it were an inline value of the parent entity.
  # @return [Boolean]
  def present_as_value?
    metadata = associated_class_metadata
    metadata and metadata.has_key? :present_as_value
  end

  # Whether property links to an entity that should be shown as an inline value.
  # @return [Boolean]
  def present_as_collection?
    metadata = associated_class_metadata
    metadata and metadata.has_key? :present_as_collection
  end

  # Whether property is a serialized property. A serialized property
  # is an arbitrarily complex value stored in an entity's column.
  # Only serialized Arrays of Strings are currently supported.
  # @return [Boolean] if property is a serialized property
  def serialized_property?
    if @entity.has_attribute? property_identifier
      column = @entity.column_for_attribute property_identifier

      # This introspects Rails columns to determine if the property is a serialized array.
      cast_type = column.cast_type
      if cast_type && cast_type.is_a?(ActiveRecord::Type::Serialized)
        unless cast_type.coder.object_class == Array
          Rails.logger.warn "#{self}: only Arrays are supported in serialized properties"
          return false
        end
        return true
      end
    end
    false
  end

  # @return [Class, String] the type of this property's value.
  def value_type
    metadata = associated_class_metadata
    if present_as_collection?
      backing_collection_method = metadata[:present_as_collection][:get]
      backing_association = property_association.klass.reflect_on_association backing_collection_method
      backing_association.klass
    else
      association = property_association
      if association
        property_association.klass
      elsif serialized_property?
        Vedaspector::Property::STRING_COLLECTION_TYPE
      else
        @property_definition[:type]
      end
    end
  end

  # @return [Boolean] is this an enumeration property
  def is_enum_value?
    value_type.respond_to? :included_modules and value_type.included_modules.include? Vedaspace::Enum
  end

  # @raise [Exception] if this is not an enumeration property.
  # @return [Hash]
  def enum_values
    unless is_enum_value?
      raise "enum_values should only be called on a enumerated value"
    end

    if @value and not value_type.values.uniq.include? @value
      Rails.logger.warn "Property #{name} on #{@entity.class}: value #{@value} does not match possible enumeration values, and will be ignored."
    end

    # uniq needed as of VEDaStore 1.1.1
    value_type.values.uniq.map do |enum_value|
      {:name => enum_value, :selected => @value == enum_value}
    end
  end

  # Fetch value properties of child entity.
  # @raise [Exception] if this is not an entity property.
  # @return [Array<Vedaspector::Property>] the linked entity's child properties
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
