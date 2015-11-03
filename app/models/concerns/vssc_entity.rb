module VsscEntity
  extend ActiveSupport::Concern

  ENTITY_CLASSES = []

  # Unlike ActiveSupport::Concern's included block, this logic
  # needs to be executed for both parent and child classes.
  def self.included(base)
    unless ENTITY_CLASSES.include? base
      ENTITY_CLASSES << base
    else
      Rails.logger.warn "VsscEntity has been included multiple times in #{base}"
    end

    class << base; attr_accessor :inspector_metadata end
    if base.inspector_metadata.nil?
      base.inspector_metadata = {}
    else
      Rails.logger.warn "#{base}.inspector_metadata has already been set"
    end
  end


  def entity_type_identifier
    self.class.entity_type_identifier
  end

  # Looks up an entity's property by the method used to access it.
  # @return [Vssc::EntityProperty, nil] the given property, or nil
  def entity_property(property_identifier)
    property_identifier = property_identifier.to_sym
    entity_properties.find { |p| p.property_identifier == property_identifier }
  end

  # Returns all entity properties, set with fresh values.
  # @return [Array<Vssc::EntityProperty] the returned properties
  def entity_properties
    # Note: Properties could be cached if EntityProperty instances didn't store their value.
    properties = []

    properties += elements.map do |name, element|
      Vssc::EntityProperty.new(self, element, name)
    end.compact

    properties += xml_attributes.map do |name, attribute|
      Vssc::EntityProperty.new(self, attribute, name)
    end.compact

    if self.class.text_node_method
      property_definition = { method: self.class.text_node_method, type: String }
      properties << Vssc::EntityProperty.new(self, property_definition, self.class.text_node_method.to_sym)
    end

    properties
  end

  def update_and_save!(params, parent_property: nil)
    params.each do |key, value|
      association = self.class.reflect_on_association key

      setter_method = "#{key}=".to_sym

      if association and association.collection?
        raise "Unable to set value for collection #{key}"
      elsif association
        unless association.klass.inspector_metadata.has_key? :present_as_value
          raise "Unable to set value for linked entity #{key}"
        end

        present_as_value = association.klass.inspector_metadata[:present_as_value]
        store_method = present_as_value[:store]

        linked_entity = send key.to_sym
        if linked_entity.nil?
          linked_entity = association.klass.new
          linked_entity.send store_method, value
          send setter_method, linked_entity
        else
          linked_entity.send store_method, value
        end
      else
        if respond_to? setter_method
          send setter_method, value
        else
          Rails.logger.warn "Unable to call #{setter_method}: on #{self}: method not defined"
        end
      end
    end

    self.save!

    if parent_property
      parent_property.value = self
      parent_property.entity.save!
    end
  end

  def entity_actions
    actions = [
      {:title => "Edit", :action => 'edit', :button_class => 'btn-default'},
      {:title => "Delete", :action => '', :button_class => 'btn-danger delete-button'},
    ]

    if self.class.inspector_metadata.has_key? :entity_actions
      actions = self.class.inspector_metadata[:entity_actions] + actions
    end

    actions
  end

  def has_entity_action?(action, ignore_base_actions=true)
    if ignore_base_actions
      if self.class.inspector_metadata.has_key? :entity_actions
        self.class.inspector_metadata[:entity_actions].any? { |a| a[:action] == action }
      else
        false
      end
    else
      entity_actions.any? { |a| a[:action] == action }
    end
  end

  ### Customization Methods

  module ClassMethods

    # Returns a standardized, lowercase string identifier for this entity class.
    # Used in URLs and logging.
    # @return [String]
    def entity_type_identifier
      name.demodulize.pluralize.underscore
    end

    def preferred_name(name)
      inspector_metadata[:preferred_name] = name
    end

    # Allow entity to be presented as a simple value type.
    def present_as_value(**options)
      if not options[:type]
        raise "Missing required type parameter"
      elsif not options[:get]
        raise "Missing required getter parameter"
      elsif not options[:store]
        raise "Missing required setter parameter"
      end

      inspector_metadata[:present_as_value] = options
    end

    # Allow entity to be presented as a collection.
    def present_as_collection(collection_method)
      inspector_metadata[:present_as_collection] = {get: collection_method}
    end

    def entity_action(**options)
      if not options[:title]
        raise "Missing required title parameter"
      elsif not options[:action]
        raise "Missing required getter parameter"
      end

      inspector_metadata[:entity_actions] ||= []
      inspector_metadata[:entity_actions] << options
    end

  end

end
