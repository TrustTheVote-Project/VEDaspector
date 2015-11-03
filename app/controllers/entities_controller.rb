class EntitiesController < ApplicationController

  def initialize
    super
    @linked_entity_num_shown_properties = 10

    @collection_page_size = 30
    @linked_collection_page_size = 10
  end

  ### Shared Methods

  def lookup_vssc_class(name)
    VsscEntity::ENTITY_CLASSES.find { |klass| klass.name.demodulize == name }
  end

  # Returns Ruby class for a viewable VSSC entity type, or nil.
  def lookup_entity_type(entity_name)
    # TODO: whitelist specific classes?
    lookup_vssc_class(entity_name.titleize.delete(' ').singularize) or
      lookup_vssc_class(entity_name.titleize.delete(' '))
  end

  def assign_entity_type!
    input_entity_type = params[:entity_type]
    @entity_type = lookup_entity_type input_entity_type
    raise "Invalid entity type: #{input_entity_type}" unless @entity_type
  end

  def assign_entity!
    entity_id = params[:entity_id]
    @entity = @entity_type.find(entity_id)
    @parent_entity = nil
    raise "Invalid entity: #{entity_id}" unless @entity
  end

  # Validates and assigns parent entity, and parent property instance variables.
  # @raise [Exception] on validation error
  def assign_parent_entity!
    parent_comps = params[:parent].split('-')
    raise "Invalid parent parameter #{params[:parent]}" unless parent_comps.size == 3
    input_parent_type, parent_id, property_name = parent_comps

    parent_type = lookup_entity_type input_parent_type
    raise "Invalid parent entity type: #{input_parent_type}" unless parent_type

    @parent_entity = parent_type.find parent_id
    raise "Invalid parent entity: #{parent_id}" unless @parent_entity

    @parent_property = @parent_entity.entity_property property_name
    raise "Invalid parent property: #{property_name}" unless @parent_property
  end

  def assign_new_entity!
    @entity = @entity_type.new
    if params.has_key? :parent
      assign_parent_entity!
    else
      @parent_entity = nil
    end
  end

  def assign_collection_property!
    collection_name = params[:collection]
    @collection = @entity.entity_property collection_name.to_sym
    @base_collection_url = view_context.collection_view_link @collection
    @current_page = (params[:page_number] || 1).to_i

    total_pages = (@collection.value.size / @collection_page_size).ceil
    total_pages = [1, total_pages].max

    if @current_page < 1 || @current_page > total_pages
      return redirect_to @base_collection_url
    end

    raise "Invalid collection '#{collection_name}' for #{@entity_type}" unless @collection
  end

  ### Routes

  def index
    redirect_to '/election_reports'
  end

  def list
    assign_entity_type!

    @is_root_entity = @entity_type == Vssc::ElectionReport
    @entities = @entity_type.all
  end

  ### Entity Actions

  def show
    assign_entity_type!
    assign_entity!
  end

  def create
    assign_entity_type!
    assign_new_entity!
  end

  def edit
    assign_entity_type!
    assign_entity!
  end

  def update
    assign_entity_type!
    if params.has_key? :entity_id
      assign_entity!
    else
      assign_new_entity!
    end

    @entity.update_and_save! params[:entity], parent_property: @parent_property
    redirect_to view_context.entity_view_link(@entity)
  end

  def delete
    assign_entity_type!
    assign_entity!

    @entity.destroy

    redirect_to '/'
  end

  def entity_action
    assign_entity_type!
    assign_entity!

    action = params[:entity_action]

    if @entity.has_entity_action? action
      @entity.send(action, self)
    else
      raise "Unexpected action '#{action}' for #{@entity}"
    end
  end

  def collection_list
    assign_entity_type!
    assign_entity!
    assign_collection_property!
  end

  def collection_insert
    assign_entity_type!
    assign_entity!

    render text: "TODO"
  end

  def collection_insert_save
    render text: "TODO"
  end

end
